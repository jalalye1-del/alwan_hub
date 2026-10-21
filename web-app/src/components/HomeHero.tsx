'use client';

import { useAudioStore } from '@/lib/audioStore';

const STREAM_URL = 'https://s9.voscast.com:9617/stream';

export default function HomeHero() {
  const { play, currentTrack, isPlaying, isLoading } = useAudioStore();

  const handleListenLive = () => {
    if (currentTrack?.url === STREAM_URL && isPlaying) {
      return;
    }
    play({
      id: 'alwan-live',
      title: 'إذاعة ألوان FM',
      subtitle: 'البث المباشر',
      url: STREAM_URL,
      imageUrl: '/images/splash_logo.png',
      isLiveStream: true,
      presenterName: 'يبث الآن',
      category: 'إذاعة ألوان',
    });
  };

  const isCurrentLive = currentTrack?.url === STREAM_URL;

  return (
    <section className="relative overflow-hidden">
      {/* Background */}
      <div className="absolute inset-0 alwan-gradient" />
      <div className="absolute inset-0 bg-[url('https://images.unsplash.com/photo-1478737270239-2f02b77fc618?auto=format&fit=crop&w=1920&q=80')] bg-cover bg-center opacity-10" />
      <div className="absolute inset-0 bg-gradient-to-l from-transparent via-black/20 to-black/40" />

      {/* Content */}
      <div className="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-16 sm:py-24 lg:py-32">
        <div className="grid lg:grid-cols-2 gap-8 lg:gap-12 items-center">
          {/* Text Content */}
          <div className="text-white space-y-6">
            <div className="inline-flex items-center gap-2 px-4 py-2 bg-white/10 backdrop-blur-sm rounded-full border border-white/20">
              <span className="live-indicator text-[10px]">LIVE</span>
              <span className="text-sm font-medium">البث المباشر الآن</span>
            </div>

            <h1 className="text-4xl sm:text-5xl lg:text-6xl font-bold leading-tight">
              ألوان
              <span className="block text-amber-300 mt-2">تنبض بالحياة</span>
            </h1>

            <p className="text-lg sm:text-xl text-white/80 max-w-lg leading-relaxed">
              منصة إعلامية صوتية متكاملة — بث مباشر، برامج حصرية، بودكاست، كتب صوتية، استراحة موسيقية، ألعاب تفاعلية والمزيد
            </p>

            <div className="flex flex-wrap gap-4">
              <button
                onClick={handleListenLive}
                className={`inline-flex items-center gap-3 px-8 py-4 rounded-2xl font-bold text-lg transition-all ${
                  isCurrentLive && isPlaying
                    ? 'bg-red-500 text-white shadow-lg shadow-red-500/30'
                    : 'bg-white text-alwan-primary hover:bg-gray-100 shadow-xl'
                }`}
              >
                {isLoading && isCurrentLive ? (
                  <svg className="w-6 h-6 animate-spin" fill="none" viewBox="0 0 24 24">
                    <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" />
                    <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z" />
                  </svg>
                ) : isPlaying && isCurrentLive ? (
                  <svg className="w-6 h-6" fill="currentColor" viewBox="0 0 24 24">
                    <rect x="6" y="4" width="4" height="16" rx="1" />
                    <rect x="14" y="4" width="4" height="16" rx="1" />
                  </svg>
                ) : (
                  <svg className="w-6 h-6" fill="currentColor" viewBox="0 0 24 24">
                    <path d="M8 5v14l11-7z" />
                  </svg>
                )}
                {isPlaying && isCurrentLive ? 'يُبث الآن' : 'استمع مباشرة'}
              </button>

              <a
                href="#programs"
                className="inline-flex items-center gap-2 px-6 py-4 rounded-2xl font-bold text-lg text-white bg-white/10 backdrop-blur-sm border border-white/20 hover:bg-white/20 transition-all"
              >
                تصفح البرامج
                <svg className="w-5 h-5 rotate-180" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17 8l4 4m0 0l-4 4m4-4H3" />
                </svg>
              </a>
            </div>

            {/* Stats */}
            <div className="flex gap-8 pt-4">
              <div>
                <div className="text-3xl font-bold text-amber-300">30+</div>
                <div className="text-sm text-white/60">إذاعة</div>
              </div>
              <div>
                <div className="text-3xl font-bold text-amber-300">12</div>
                <div className="text-sm text-white/60">تصنيف</div>
              </div>
              <div>
                <div className="text-3xl font-bold text-amber-300">24/7</div>
                <div className="text-sm text-white/60">بث مباشر</div>
              </div>
            </div>
          </div>

          {/* Visual Element */}
          <div className="hidden lg:flex justify-center">
            <div className="relative">
              {/* Main circle */}
              <div className={`w-80 h-80 rounded-full alwan-gradient flex items-center justify-center shadow-2xl ${isPlaying && isCurrentLive ? 'animate-pulse' : ''}`}>
                <div className="w-72 h-72 rounded-full bg-white/10 backdrop-blur-sm flex items-center justify-center border border-white/20">
                  <div className="text-center space-y-3">
                    <div className="w-24 h-24 mx-auto rounded-full bg-white/20 flex items-center justify-center">
                      <span className="text-5xl">📻</span>
                    </div>
                    <div className="text-white">
                      <div className="text-lg font-bold">إذاعة ألوان FM</div>
                      <div className="text-sm text-white/70">البث المباشر</div>
                    </div>
                    {isPlaying && isCurrentLive && (
                      <div className="flex items-center justify-center gap-1">
                        {[...Array(5)].map((_, i) => (
                          <div
                            key={i}
                            className="w-1 bg-amber-300 rounded-full animate-pulse"
                            style={{
                              height: `${Math.random() * 20 + 10}px`,
                              animationDelay: `${i * 0.15}s`,
                            }}
                          />
                        ))}
                      </div>
                    )}
                  </div>
                </div>
              </div>

              {/* Floating elements */}
              <div className="absolute -top-4 -right-4 w-16 h-16 bg-amber-400 rounded-2xl flex items-center justify-center shadow-lg rotate-12 animate-bounce" style={{ animationDuration: '3s' }}>
                <span className="text-2xl">🎙️</span>
              </div>
              <div className="absolute -bottom-4 -left-4 w-16 h-16 bg-green-400 rounded-2xl flex items-center justify-center shadow-lg -rotate-12 animate-bounce" style={{ animationDuration: '4s' }}>
                <span className="text-2xl">🎧</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
