import { createHash } from "node:crypto";
import { createServer } from "node:http";

const port = Number.parseInt(process.env.PORT ?? "8787", 10);
const allowedOrigin = process.env.ALLOWED_ORIGIN ?? "*";
const openAiKey = process.env.OPENAI_API_KEY ?? "";
const geminiKey = process.env.GEMINI_API_KEY ?? "";
const requestLimit = 30;
const requestWindowMs = 60_000;
const requestsByClient = new Map();

const server = createServer(async (request, response) => {
  setCors(response);

  if (request.method === "OPTIONS") {
    response.writeHead(204);
    response.end();
    return;
  }

  const url = new URL(request.url ?? "/", `http://${request.headers.host}`);
  if (request.method === "GET" && url.pathname === "/health") {
    sendJson(response, 200, {
      ok: true,
      openai: Boolean(openAiKey),
      gemini: Boolean(geminiKey),
    });
    return;
  }

  if (request.method !== "POST") {
    sendJson(response, 405, { message: "Method not allowed" });
    return;
  }

  const clientId = privacySafeClientId(request);
  if (!takeRateLimit(clientId)) {
    sendJson(response, 429, { message: "طلبات كثيرة، حاول بعد دقيقة." });
    return;
  }

  try {
    const body = await readJson(request);
    if (url.pathname === "/v1/assistant/chat") {
      await handleChat(response, body, clientId);
      return;
    }
    if (url.pathname === "/v1/assistant/images") {
      await handleImage(response, body);
      return;
    }
    if (url.pathname === "/v1/assistant/music") {
      await handleMusic(response, body);
      return;
    }
    if (url.pathname === "/v1/assistant/realtime/token") {
      await handleRealtimeToken(response, clientId);
      return;
    }
    sendJson(response, 404, { message: "Endpoint not found" });
  } catch (error) {
    console.error(error);
    const status = error instanceof HttpError ? error.status : 500;
    sendJson(response, status, {
      message:
        status >= 500
          ? "تعذر إكمال طلب ألوان AI حاليًا."
          : error.message,
    });
  }
});

async function handleChat(response, body, clientId) {
  requireKey(openAiKey, "OPENAI_API_KEY");
  const message = requiredPrompt(body.message);
  const model = process.env.OPENAI_CHAT_MODEL ?? "chat-latest";
  const openAiResponse = await fetchJson("https://api.openai.com/v1/responses", {
    method: "POST",
    headers: openAiHeaders(clientId),
    body: JSON.stringify({
      model,
      instructions:
        "أنت ألوان AI، مساعد عربي داخل تطبيق إذاعة ألوان. أجب بالعربية بوضوح واختصار، واستخدم بحث الويب عند الحاجة للمعلومات المتغيرة.",
      input: message,
      tools: [{ type: "web_search" }],
      safety_identifier: clientId,
    }),
  });

  const text = extractOpenAiText(openAiResponse);
  if (!text) throw new HttpError(502, "لم يصل رد نصي من ChatGPT.");

  let audioBase64;
  if (body.voiceReply === true) {
    const speech = await fetchBinary("https://api.openai.com/v1/audio/speech", {
      method: "POST",
      headers: openAiHeaders(clientId),
      body: JSON.stringify({
        model: process.env.OPENAI_SPEECH_MODEL ?? "tts-1",
        voice: process.env.OPENAI_VOICE ?? "alloy",
        input: text,
        response_format: "mp3",
      }),
    });
    audioBase64 = Buffer.from(speech).toString("base64");
  }

  sendJson(response, 200, {
    text,
    ...(audioBase64
      ? { audioBase64, mimeType: "audio/mpeg", title: "رد ألوان AI" }
      : {}),
  });
}

async function handleImage(response, body) {
  requireKey(geminiKey, "GEMINI_API_KEY");
  const prompt = requiredPrompt(body.prompt);
  const interaction = await callGemini({
    model: "gemini-3.1-flash-image",
    input: prompt,
    response_format: {
      type: "image",
      mime_type: "image/png",
      aspect_ratio: body.aspectRatio ?? "1:1",
      image_size: body.imageSize ?? "1K",
    },
  });
  const image = extractGeminiBlock(interaction, "image");
  if (!image?.data) throw new HttpError(502, "لم تصل صورة من Gemini.");
  sendJson(response, 200, {
    text: extractGeminiText(interaction) || "تم إنشاء الصورة بنجاح.",
    imageBase64: image.data,
    mimeType: image.mime_type ?? "image/png",
  });
}

async function handleMusic(response, body) {
  requireKey(geminiKey, "GEMINI_API_KEY");
  const prompt = requiredPrompt(body.prompt);
  const model = body.fullSong === false
    ? "lyria-3-clip-preview"
    : "lyria-3-pro-preview";
  const interaction = await callGemini({
    model,
    input: prompt,
    response_format: { type: "audio" },
  });
  const audio = extractGeminiBlock(interaction, "audio");
  if (!audio?.data) throw new HttpError(502, "لم يصل ملف صوتي من Lyria.");
  sendJson(response, 200, {
    text: extractGeminiText(interaction) || "تم إنشاء الأغنية بنجاح.",
    audioBase64: audio.data,
    mimeType: audio.mime_type ?? "audio/mpeg",
    title: body.fullSong === false ? "موسيقى ألوان AI" : "أغنية ألوان AI",
  });
}

async function handleRealtimeToken(response, clientId) {
  requireKey(openAiKey, "OPENAI_API_KEY");
  const token = await fetchJson(
    "https://api.openai.com/v1/realtime/client_secrets",
    {
      method: "POST",
      headers: openAiHeaders(clientId),
      body: JSON.stringify({
        session: {
          type: "realtime",
          model: "gpt-realtime-2.1",
          audio: { output: { voice: process.env.OPENAI_VOICE ?? "marin" } },
        },
      }),
    },
  );
  sendJson(response, 200, token);
}

async function callGemini(body) {
  return fetchJson(
    "https://generativelanguage.googleapis.com/v1beta/interactions",
    {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "x-goog-api-key": geminiKey,
      },
      body: JSON.stringify(body),
    },
  );
}

function extractOpenAiText(payload) {
  if (typeof payload.output_text === "string") return payload.output_text.trim();
  for (const item of payload.output ?? []) {
    for (const content of item.content ?? []) {
      if (content.type === "output_text" && typeof content.text === "string") {
        return content.text.trim();
      }
    }
  }
  return "";
}

function extractGeminiBlock(payload, type) {
  for (const step of payload.steps ?? []) {
    if (step.type !== "model_output") continue;
    for (const content of step.content ?? []) {
      if (content.type === type && typeof content.data === "string") {
        return content;
      }
    }
  }
  return null;
}

function extractGeminiText(payload) {
  const parts = [];
  for (const step of payload.steps ?? []) {
    if (step.type !== "model_output") continue;
    for (const content of step.content ?? []) {
      if (content.type === "text" && typeof content.text === "string") {
        parts.push(content.text);
      }
    }
  }
  return parts.join("\n").trim();
}

async function fetchJson(url, options) {
  const response = await fetch(url, options);
  const payload = await response.json().catch(() => ({}));
  if (!response.ok) {
    const message =
      payload?.error?.message ?? payload?.message ?? `Upstream error ${response.status}`;
    throw new HttpError(response.status, message);
  }
  return payload;
}

async function fetchBinary(url, options) {
  const response = await fetch(url, options);
  if (!response.ok) {
    const payload = await response.json().catch(() => ({}));
    throw new HttpError(
      response.status,
      payload?.error?.message ?? `Upstream error ${response.status}`,
    );
  }
  return response.arrayBuffer();
}

function openAiHeaders(clientId) {
  return {
    Authorization: `Bearer ${openAiKey}`,
    "Content-Type": "application/json",
    "OpenAI-Safety-Identifier": clientId,
  };
}

function requiredPrompt(value) {
  if (typeof value !== "string" || !value.trim()) {
    throw new HttpError(400, "النص مطلوب.");
  }
  if (value.length > 8_000) throw new HttpError(413, "النص طويل جدًا.");
  return value.trim();
}

function requireKey(value, name) {
  if (!value) throw new HttpError(503, `إعداد ${name} غير موجود على الخادم.`);
}

async function readJson(request) {
  const chunks = [];
  let size = 0;
  for await (const chunk of request) {
    size += chunk.length;
    if (size > 1_000_000) throw new HttpError(413, "حجم الطلب كبير جدًا.");
    chunks.push(chunk);
  }
  try {
    return JSON.parse(Buffer.concat(chunks).toString("utf8") || "{}");
  } catch {
    throw new HttpError(400, "JSON غير صالح.");
  }
}

function privacySafeClientId(request) {
  const forwarded = String(request.headers["x-forwarded-for"] ?? "").split(",")[0];
  const raw = forwarded || request.socket.remoteAddress || "unknown";
  return createHash("sha256").update(raw).digest("hex");
}

function takeRateLimit(clientId) {
  const now = Date.now();
  const current = requestsByClient.get(clientId);
  if (!current || now - current.startedAt >= requestWindowMs) {
    requestsByClient.set(clientId, { startedAt: now, count: 1 });
    return true;
  }
  current.count += 1;
  return current.count <= requestLimit;
}

function setCors(response) {
  response.setHeader("Access-Control-Allow-Origin", allowedOrigin);
  response.setHeader("Access-Control-Allow-Headers", "Content-Type");
  response.setHeader("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
  response.setHeader("Vary", "Origin");
}

function sendJson(response, status, body) {
  response.writeHead(status, { "Content-Type": "application/json; charset=utf-8" });
  response.end(JSON.stringify(body));
}

class HttpError extends Error {
  constructor(status, message) {
    super(message);
    this.status = status;
  }
}

server.listen(port, "0.0.0.0", () => {
  console.log(`Alwan AI gateway listening on http://0.0.0.0:${port}`);
});
