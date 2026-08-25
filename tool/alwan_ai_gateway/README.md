# بوابة ألوان AI الآمنة

هذه خدمة مرجعية صغيرة بلا مكتبات خارجية. تحفظ مفاتيح OpenAI وGemini في
الخادم، وتمنع تضمينها في تطبيق Flutter أو ملف APK أو JavaScript الخاص بالويب.

## التشغيل المحلي

يتطلب Node.js 20 أو أحدث. عرّف المتغيرات التالية في بيئة الخادم:

- `OPENAI_API_KEY`: مفتاح OpenAI.
- `GEMINI_API_KEY`: مفتاح Gemini API.
- `ALLOWED_ORIGIN`: نطاق واجهة الويب، مثل `https://alwan.fm`.
- `PORT`: اختياري، والقيمة الافتراضية `8787`.
- `OPENAI_CHAT_MODEL`: اختياري، والقيمة الافتراضية `chat-latest`.

ثم شغّل:

```powershell
node tool/alwan_ai_gateway/server.mjs
```

وابنِ التطبيق مع عنوان الخادم المنشور:

```powershell
flutter build apk --dart-define=ALWAN_AI_BASE_URL=https://ai.example.com
flutter build web --dart-define=ALWAN_AI_BASE_URL=https://ai.example.com
```

يمكن فحص الجاهزية من `GET /health`. توفر الخدمة نقاط الدردشة والرد الصوتي،
وتوليد الصور، وتوليد الموسيقى، وإصدار رمز قصير العمر لاتصال OpenAI Realtime.

## ملاحظات النشر

- استخدم HTTPS فقط في الإنتاج.
- اجعل `ALLOWED_ORIGIN` نطاق الويب الفعلي بدل `*`.
- لا تضع المفاتيح في `--dart-define`؛ عنوان البوابة فقط هو الذي يوضع هناك.
- ملفات الصور والصوت الكبيرة يفضّل رفعها إلى تخزين كائنات وإرجاع رابط مؤقت
  بدل إرجاع Base64 عند نقل الخدمة إلى الإنتاج واسع الاستخدام.
