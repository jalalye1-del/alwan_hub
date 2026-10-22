'use client';

import { useAudioStore } from '@/lib/audioStore';

const STREAM_URL = 'https://s9.voscast.com:9617/stream';

export default function AlwanHero() {
  const { play, currentTrack, isPlaying, isLoading } = useAudioStore();

  const handleListenLive = () => {
    if (currentTrack?.url === STREAM_URL && isPlaying) {
      return;
    }
    play({
      id: 'alwan-live',
      title: 'صباحكم ألوان',
      subtitle: 'البث المباشر',
      url: STREAM_URL,
      imageUrl: '/images/alwan-logo.png',
      isLiveStream: true,
      presenterName: 'عمار معصار',
      programImage: '/images/alwan-logo.png',
      category: 'إذاعة ألوان',
    });
  };

  const isCurrentLive = currentTrack?.url === STREAM_URL;

  return (
    <section className="relative overflow-hidden min-h-[700px]" style={{ backgroundColor: '#0a0a1a' }}>
      {/* Layer 1: Bokeh/Bubble Background (Bottom Layer) */}
      <div className="absolute inset-0 w-full h-full">
        <img
          src="/images/main-bg.png"
          alt="خلفية الواجهة الرئيسية"
          className="w-full h-full object-cover"
          style={{ display: 'block' }}
        />
      </div>

      {/* Layer 2: 3D Mic & Presenters - Shifted Right 15% */}
      <div className="absolute inset-0 w-full h-full flex items-center justify-center pointer-events-none z-[1]">
        <img
          src="/images/3d-mic-full.png"
          alt="المذيعون والميكروفون"
          className="w-[90%] h-[90%] object-contain object-center translate-x-[13%]"
          style={{ display: 'block' }}
        />
      </div>

      {/* Layer 3: White Gradient Overlay - from "المزيد" in header to end of banner */}
      <div className="absolute top-0 right-[55%] w-[55%] h-full pointer-events-none z-[2]"
        style={{
          background: 'linear-gradient(to left, rgba(255,255,255,0) 0%, rgba(255,255,255,0.3) 15%, rgba(255,255,255,0.6) 40%, rgba(255,255,255,0.8) 70%, rgba(255,255,255,0.9) 100%)'
        }}
      />

      {/* Layer 4: Main Content (Top Layer) */}
      <div className="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8 z-10">
        <div className="flex items-stretch gap-6 min-h-[600px]">
          
          {/* RIGHT SECTION - Empty space for presenters */}
          <div className="hidden lg:block lg:w-[35%]" />

          {/* CENTER SECTION - Text, Stats, Buttons - Moved Left 10% more from current */}
          <div className="flex-1 flex flex-col justify-center space-y-6 max-w-sm -translate-x-[24%] translate-y-[4%]">
            {/* Title */}
            <div className="space-y-2">
              <h2 className="text-2xl font-black text-[#E35335] drop-shadow-lg">
                البث المباشر
              </h2>
              <h1 className="text-5xl font-black text-[#1D00CD] leading-tight drop-shadow-lg">
                ألـــوان <span className="text-3xl">FM 88.7</span>
              </h1>
              <p className="text-xl text-[#E35335] font-black drop-shadow-lg">
                ألوان تنبض بالحياة
              </p>
            </div>

            {/* Stats - Single horizontal row */}
            <div className="flex items-center gap-2 flex-nowrap">
              <div className="flex items-center gap-2 bg-white/95 backdrop-blur-sm px-3 py-2.5 rounded-xl border border-gray-200 shadow-lg flex-shrink-0">
                <svg className="w-5 h-5 text-[#1D00CD]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
                </svg>
                <div>
                  <div className="text-[10px] text-gray-500 font-bold">جودة</div>
                  <div className="flex items-center gap-1">
                    <span className="text-sm font-black text-gray-900">عالية</span>
                    <span className="bg-[#1D00CD] text-white text-[9px] px-1.5 py-0.5 rounded font-black">HD</span>
                  </div>
                </div>
              </div>

              <div className="flex items-center gap-2 bg-white/95 backdrop-blur-sm px-3 py-2.5 rounded-xl border border-gray-200 shadow-lg flex-shrink-0">
                <svg className="w-5 h-5 text-[#1D00CD]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" />
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" />
                </svg>
                <div>
                  <div className="text-[10px] text-gray-500 font-bold">البث من</div>
                  <div className="text-sm font-black text-gray-900">صنعاء</div>
                </div>
              </div>

              <div className="flex items-center gap-2 bg-white/95 backdrop-blur-sm px-3 py-2.5 rounded-xl border border-gray-200 shadow-lg flex-shrink-0">
                <svg className="w-5 h-5 text-[#1D00CD]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 11a7 7 0 01-7 7m0 0a7 7 0 01-7-7m7 7v4m0 0H8m4 0h4m-4-8a3 3 0 01-3-3V5a3 3 0 116 0v6a3 3 0 01-3 3z" />
                </svg>
                <div>
                  <div className="text-[10px] text-gray-500 font-bold">عدد المستمعين</div>
                  <div className="text-sm font-black text-gray-900">12,258</div>
                </div>
              </div>
            </div>

            {/* Action Buttons - Shifted Left 1.5% */}
            <div className="flex items-center gap-3 -translate-x-[1.5%]">
              {/* Heart - Blue background */}
              <button className="w-12 h-12 rounded-full bg-[#1D00CD] text-white flex items-center justify-center hover:bg-[#1200A8] transition-colors shadow-xl flex-shrink-0">
                <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z" />
                </svg>
              </button>

              {/* Listen Now Button */}
              <button
                onClick={handleListenLive}
                className={`px-8 py-4 rounded-2xl font-black text-lg transition-all shadow-xl whitespace-nowrap ${
                  isCurrentLive && isPlaying
                    ? 'bg-[#1D00CD] text-white'
                    : 'bg-[#1D00CD] text-white hover:bg-[#1200A8]'
                }`}
              >
                {isLoading && isCurrentLive ? (
                  <span className="flex items-center gap-2">
                    <svg className="w-5 h-5 animate-spin" fill="none" viewBox="0 0 24 24">
                      <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" />
                      <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z" />
                    </svg>
                    جاري التحميل...
                  </span>
                ) : (
                  'الدردشة الآن'
                )}
              </button>

              {/* Share - Blue background like heart */}
              <button className="w-12 h-12 rounded-full bg-[#1D00CD] text-white flex items-center justify-center hover:bg-[#1200A8] transition-colors shadow-xl flex-shrink-0">
                <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8.684 13.342C8.886 12.938 9 12.482 9 12c0-.482-.114-.938-.316-1.342m0 2.684a3 3 0 110-2.684m0 2.684l6.632 3.316m-6.632-6l6.632-3.316m0 0a3 3 0 105.367-2.684 3 3 0 00-5.367 2.684zm0 9.316a3 3 0 105.368 2.684 3 3 0 00-5.368-2.684z" />
                </svg>
              </button>
            </div>

            {/* Glass Cards - News & Horoscope (Horizontal, 80mm x 17mm each) - 8% down */}
            <div className="flex items-center gap-3 flex-wrap translate-y-[8%]" style={{ position: 'relative', zIndex: 1 }}>
              {/* Trending News Card - 80mm x 17mm */}
              <div className="relative overflow-hidden rounded-xl bg-white/40 backdrop-blur-xl border border-white/50 px-2 py-1 shadow-[0_4px_20px_rgba(167,139,250,0.3)] hover:shadow-[0_8px_30px_rgba(167,139,250,0.5)] transition-all duration-300 cursor-pointer" style={{ width: '80mm', height: '17mm', maxWidth: '302px', maxHeight: '64px', flexShrink: 0 }}>
                <div className="absolute top-0 right-0 w-8 h-8 bg-gradient-to-br from-purple-400/30 to-pink-400/30 rounded-full blur-lg -translate-y-1/2 translate-x-1/2" />
                <div className="relative flex items-center gap-1.5 h-full">
                  <div className="w-7 h-7 rounded-lg bg-gradient-to-br from-red-500 to-orange-500 flex items-center justify-center shadow-lg flex-shrink-0">
                    <svg className="w-3.5 h-3.5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 20H5a2 2 0 01-2-2V6a2 2 0 012-2h10a2 2 0 012 2v1m2 13a2 2 0 01-2-2V7m2 13a2 2 0 002-2V9a2 2 0 00-2-2h-2m-4-3H9M7 16h6M7 8h6v4H7V8z" />
                    </svg>
                  </div>
                  <div>
                    <h3 className="text-[9px] font-black text-gray-900 leading-tight whitespace-nowrap">الأخــبـــار الـــرائــجـــة</h3>
                  </div>
                </div>
              </div>

              {/* Daily Horoscope Card - 80mm x 17mm */}
              <div className="relative overflow-hidden rounded-xl bg-white/40 backdrop-blur-xl border border-white/50 px-2 py-1 shadow-[0_4px_20px_rgba(167,139,250,0.3)] hover:shadow-[0_8px_30px_rgba(167,139,250,0.5)] transition-all duration-300 cursor-pointer" style={{ width: '80mm', height: '17mm', maxWidth: '302px', maxHeight: '64px', flexShrink: 0 }}>
                <div className="absolute top-0 right-0 w-8 h-8 bg-gradient-to-br from-indigo-400/30 to-purple-400/30 rounded-full blur-lg -translate-y-1/2 translate-x-1/2" />
                <div className="relative flex items-center gap-1.5 h-full">
                  <div className="w-7 h-7 rounded-lg bg-gradient-to-br from-indigo-500 to-purple-600 flex items-center justify-center shadow-lg flex-shrink-0">
                    <svg className="w-3.5 h-3.5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M11.049 2.927c.3-.921 1.603-.921 1.902 0l1.519 4.674a1 1 0 00.95.69h4.915c.969 0 1.371 1.24.588 1.81l-3.976 2.888a1 1 0 00-.363 1.118l1.518 4.674c.3.922-.755 1.688-1.538 1.118l-3.976-2.888a1 1 0 00-1.176 0l-3.976 2.888c-.783.57-1.838-.197-1.538-1.118l1.518-4.674a1 1 0 00-.363-1.118l-3.976-2.888c-.784-.57-.38-1.81.588-1.81h4.914a1 1 0 00.951-.69l1.519-4.674z" />
                    </svg>
                  </div>
                  <div>
                    <h3 className="text-[9px] font-black text-gray-900 leading-tight whitespace-nowrap">الأبــــراج الــيـــومــيـــة</h3>
                  </div>
                </div>
              </div>
            </div>
          </div>

          {/* LEFT SECTION - Banner at Far Left - Shifted Left 30% */}
          <div className="hidden lg:flex flex-shrink-0 -translate-x-[30%]">
            <div className="w-72 h-[522px] rounded-3xl overflow-hidden shadow-2xl border-4 border-white relative">
              {/* Orange/Yellow Background */}
              <div className="absolute inset-0 bg-gradient-to-b from-[#FA9E0D] to-[#FFA800]" />
              {/* Girl Image */}
              <img
                src="https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=400&q=80"
                alt="Listener"
                className="relative w-full h-full object-cover"
                style={{ mixBlendMode: 'multiply' }}
              />
            </div>
          </div>
        </div>
      </div>

      {/* Wave Pattern at Bottom */}
      <div className="absolute bottom-0 left-0 right-0 h-40 pointer-events-none z-10">
        <svg viewBox="0 0 1440 120" className="w-full h-full" preserveAspectRatio="none">
          <path
            fill="#60A5FA"
            fillOpacity="0.3"
            d="M0,40 C180,90 360,10 540,40 C720,70 900,10 1080,40 C1260,70 1380,20 1440,40 L1440,120 L0,120 Z"
          />
          <path
            fill="#3B82F6"
            fillOpacity="0.2"
            d="M0,60 C240,100 480,20 720,60 C960,100 1200,20 1440,60 L1440,120 L0,120 Z"
          />
        </svg>
      </div>
    </section>
  );
}
