'use client';

import { useAudioStore } from '@/lib/audioStore';
import { useState, useEffect } from 'react';

const STREAM_URL = 'https://s9.voscast.com:9617/stream';

export default function AlwanPlayer() {
  const {
    currentTrack,
    isPlaying,
    isLoading,
    volume,
    isRecording,
    recordingDuration,
    play,
    togglePlayPause,
    setVolume,
    startRecording,
    stopRecording,
  } = useAudioStore();

  const [isVolumeExpanded, setIsVolumeExpanded] = useState(false);
  const [isExpanded, setIsExpanded] = useState(false);

  // Auto-load live stream on mount
  useEffect(() => {
    if (!currentTrack) {
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
    }
  }, []);

  const formatTime = (seconds: number): string => {
    const mins = Math.floor(seconds / 60);
    const secs = Math.floor(seconds % 60);
    return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  };

  const handleRecordToggle = () => {
    if (isRecording) {
      stopRecording();
    } else {
      startRecording();
    }
  };

  const displayTrack = currentTrack || {
    title: 'صباحكم ألوان',
    presenterName: 'عمار معصار',
    imageUrl: '/images/alwan-logo.png',
    isLiveStream: true,
    category: 'إذاعة ألوان',
  };

  return (
    <div className="fixed left-0 right-0 z-50 bg-white border-t-2 border-[#1D00CD] shadow-2xl" style={{ bottom: '8vh' }}>
      {/* Recording Banner - REMOVED from here, now inline */}

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex items-center justify-between h-22 gap-4">
          {/* Left Section - Logo + Live Badge */}
          <div className="flex items-center gap-3 flex-shrink-0">
            <img
              src="/images/alwan-logo-new.png"
              alt="إذاعة ألوان 88.7 FM"
              className="h-14 w-auto"
            />
            {displayTrack.isLiveStream && (
              <span className="bg-[#E35335] text-white text-xs px-3 py-1.5 rounded-full font-black flex items-center gap-1.5 shadow-lg">
                <span className="w-2 h-2 bg-white rounded-full animate-pulse" />
                مباشر الآن
              </span>
            )}
          </div>

          {/* Center-Left - Presenter + Info */}
          <div className="flex items-center gap-4">
            {/* Presenter Photo */}
            <div className="w-16 h-16 rounded-full overflow-hidden border-[3px] border-[#1D00CD] flex-shrink-0 shadow-lg bg-white p-0.5">
              <img
                src="https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&w=150&q=80"
                alt="Presenter"
                className="w-full h-full rounded-full object-cover"
              />
            </div>

            {/* Track Info */}
            <div>
              <h3 className="text-base font-black text-gray-900">
                {displayTrack.title}
              </h3>
              <p className="text-sm text-gray-500 font-bold">
                {displayTrack.presenterName}
              </p>
            </div>

            {/* Quality Badge */}
            <div className="hidden md:flex items-center gap-2 text-sm text-gray-500 bg-gray-50 px-4 py-2 rounded-xl">
              <svg className="w-5 h-5 text-[#1D00CD]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.066 2.573c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.573 1.066c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.066-2.573c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z" />
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
              </svg>
              <span className="font-black">جودة البث</span>
            </div>

            {/* Waveform Visualization */}
            {isPlaying && (
              <div className="hidden lg:flex items-center gap-0.5 h-10">
                {[...Array(20)].map((_, i) => (
                  <div
                    key={i}
                    className="w-1 bg-[#1D00CD] rounded-full waveform-bar"
                    style={{
                      height: `${20 + Math.random() * 80}%`,
                      animationDelay: `${i * 0.05}s`,
                      animationDuration: '0.5s',
                    }}
                  />
                ))}
              </div>
            )}
          </div>

          {/* Right Section - Controls */}
          <div className="flex items-center gap-2">
            {/* Record Button + Timer (Inline) */}
            <div className="flex items-center gap-2">
              <button
                onClick={handleRecordToggle}
                className={`w-11 h-11 rounded-full flex items-center justify-center transition-all ${
                  isRecording
                    ? 'bg-[#E35335] text-white shadow-lg'
                    : 'bg-gray-100 text-gray-600 hover:bg-red-50 hover:text-[#E35335]'
                }`}
                title={isRecording ? 'إيقاف التسجيل' : 'بدء التسجيل'}
              >
                {isRecording ? (
                  <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
                    <rect x="6" y="6" width="12" height="12" rx="2" />
                  </svg>
                ) : (
                  <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
                    <circle cx="12" cy="12" r="6" />
                  </svg>
                )}
              </button>
              {/* Recording Timer - Inline next to button */}
              {isRecording && (
                <span className="text-sm font-black text-[#E35335] font-mono whitespace-nowrap">
                  {formatTime(recordingDuration)}
                </span>
              )}
            </div>

            {/* Previous */}
            <button className="w-11 h-11 rounded-full bg-[#1D00CD] text-white flex items-center justify-center hover:bg-[#1200A8] transition-colors">
              <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
                <path d="M6 6h2v12H6zm3.5 6l8.5 6V6z" />
              </svg>
            </button>

            {/* Play/Pause */}
            <button
              onClick={togglePlayPause}
              className="w-14 h-14 rounded-full bg-[#1D00CD] text-white flex items-center justify-center hover:bg-[#1200A8] transition-colors shadow-xl"
            >
              {isLoading ? (
                <svg className="w-6 h-6 animate-spin" fill="none" viewBox="0 0 24 24">
                  <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" />
                  <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z" />
                </svg>
              ) : isPlaying ? (
                <svg className="w-7 h-7" fill="currentColor" viewBox="0 0 24 24">
                  <rect x="6" y="4" width="4" height="16" rx="1" />
                  <rect x="14" y="4" width="4" height="16" rx="1" />
                </svg>
              ) : (
                <svg className="w-7 h-7 mr-[-2px]" fill="currentColor" viewBox="0 0 24 24">
                  <path d="M8 5v14l11-7z" />
                </svg>
              )}
            </button>

            {/* Next */}
            <button className="w-11 h-11 rounded-full bg-[#1D00CD] text-white flex items-center justify-center hover:bg-[#1200A8] transition-colors">
              <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
                <path d="M6 18l8.5-6L6 6v12zM16 6v12h2V6h-2z" />
              </svg>
            </button>

            {/* Favorite */}
            <button className="w-11 h-11 rounded-full bg-[#1D00CD] text-white flex items-center justify-center hover:bg-[#1200A8] transition-colors">
              <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z" />
              </svg>
            </button>

            {/* Volume */}
            <div className="relative">
              <button
                onClick={() => setIsVolumeExpanded(!isVolumeExpanded)}
                className="w-11 h-11 rounded-full bg-[#1D00CD] text-white flex items-center justify-center hover:bg-[#1200A8] transition-colors"
              >
                <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15.536 8.464a5 5 0 010 7.072m2.828-9.9a9 9 0 010 12.728M5.586 15H4a1 1 0 01-1-1v-4a1 1 0 011-1h1.586l4.707-4.707C10.923 3.663 12 4.109 12 5v14c0 .891-1.077 1.337-1.707.707L5.586 15z" />
                </svg>
              </button>
              {isVolumeExpanded && (
                <div className="absolute bottom-14 left-1/2 -translate-x-1/2 bg-white rounded-xl shadow-2xl border border-gray-200 p-4 w-40">
                  <input
                    type="range"
                    min="0"
                    max="1"
                    step="0.01"
                    value={volume}
                    onChange={(e) => setVolume(parseFloat(e.target.value))}
                    className="w-full h-2 bg-gray-200 rounded-lg appearance-none cursor-pointer accent-[#1D00CD]"
                  />
                  <div className="text-center text-xs text-gray-500 mt-2 font-black">
                    {Math.round(volume * 100)}%
                  </div>
                </div>
              )}
            </div>

            {/* Volume Slider - Horizontal */}
            <div className="hidden lg:flex items-center w-32">
              <input
                type="range"
                min="0"
                max="1"
                step="0.01"
                value={volume}
                onChange={(e) => setVolume(parseFloat(e.target.value))}
                className="w-full h-1.5 bg-gray-200 rounded-lg appearance-none cursor-pointer accent-[#1D00CD]"
              />
            </div>

            {/* Expand Button */}
            <button
              onClick={() => setIsExpanded(!isExpanded)}
              className="w-11 h-11 rounded-full bg-[#1D00CD] text-white flex items-center justify-center hover:bg-[#1200A8] transition-colors"
              title="توسيع المشغل"
            >
              <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 8V4m0 0h4M4 4l5 5m11-1V4m0 0h-4m4 0l-5 5M4 16v4m0 0h4m-4 0l5-5m11 5l-5-5m5 5v-4m0 4h-4" />
              </svg>
            </button>
          </div>
        </div>
      </div>

      {/* Expanded Player Modal - Professional Design */}
      {isExpanded && (
        <div className="fixed inset-0 z-[60] flex items-center justify-center bg-black/50 backdrop-blur-sm" onClick={() => setIsExpanded(false)}>
          <div
            className="bg-white rounded-3xl shadow-2xl w-[90%] max-w-md p-8 relative overflow-hidden"
            onClick={(e) => e.stopPropagation()}
          >
            {/* Close Button */}
            <button
              onClick={() => setIsExpanded(false)}
              className="absolute top-4 left-4 w-10 h-10 rounded-full bg-gray-100 text-gray-600 flex items-center justify-center hover:bg-gray-200 transition-colors z-10"
            >
              <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>

            {/* Vinyl Record Image */}
            <div className="flex justify-center mb-6">
              <div className="relative">
                <div className="w-44 h-44 rounded-full bg-gradient-to-br from-gray-800 to-gray-900 p-2 shadow-2xl">
                  <div className="w-full h-full rounded-full overflow-hidden border-4 border-gray-700">
                    <img
                      src={displayTrack.imageUrl || '/images/alwan-logo-new.png'}
                      alt={displayTrack.title}
                      className="w-full h-full object-cover"
                    />
                  </div>
                </div>
                {/* Center dot */}
                <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-4 h-4 rounded-full bg-gray-900 border-2 border-gray-600" />
              </div>
            </div>

            {/* Category Badge */}
            <div className="flex justify-center mb-3">
              <span className="bg-purple-600 text-white text-xs px-4 py-1.5 rounded-full font-black">
                {displayTrack.isLiveStream ? 'بث مباشر' : displayTrack.category || 'ملف صوتي'}
              </span>
            </div>

            {/* Title */}
            <h2 className="text-2xl font-black text-gray-900 text-center mb-2">
              {displayTrack.title}
            </h2>

            {/* Artist/Location */}
            <p className="text-base text-purple-600 font-bold text-center mb-4">
              {displayTrack.presenterName}
              {displayTrack.isLiveStream && <span className="text-gray-400 mx-2">—</span>}
              {displayTrack.isLiveStream && 'صنعاء'}
            </p>

            {/* Live Badge or Duration */}
            <div className="flex justify-center mb-4">
              {displayTrack.isLiveStream ? (
                <span className="text-green-600 font-black text-sm">بث مباشر</span>
              ) : (
                <div className="flex items-center gap-2 text-gray-500">
                  <span className="text-sm font-bold">🎵</span>
                  <span className="text-sm font-bold">{displayTrack.category}</span>
                  <span className="text-sm font-bold">•</span>
                  <span className="text-sm font-bold font-mono">00:00 / 05:49</span>
                </div>
              )}
            </div>

            {/* Quality Badge for Radio */}
            {displayTrack.isLiveStream && (
              <div className="flex justify-center mb-4">
                <div className="bg-gray-50 border border-gray-200 rounded-full px-4 py-2 flex items-center gap-2">
                  <svg className="w-5 h-5 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 11a7 7 0 01-7 7m0 0a7 7 0 01-7-7m7 7v4m0 0H8m4 0h4m-4-8a3 3 0 01-3-3V5a3 3 0 116 0v6a3 3 0 01-3 3z" />
                  </svg>
                  <span className="text-sm font-black text-gray-700">جودة البث: 128k HD</span>
                  <span className="text-xs text-gray-400">(الجودة ثابتة للبث)</span>
                </div>
              </div>
            )}

            {/* Progress Bar (for files) */}
            {!displayTrack.isLiveStream && (
              <div className="mb-4">
                <div className="w-full bg-gray-200 rounded-full h-1.5">
                  <div className="bg-purple-600 h-1.5 rounded-full" style={{ width: '0%' }} />
                </div>
                <div className="flex justify-between text-xs text-gray-400 mt-1 font-mono">
                  <span>00:00</span>
                  <span>05:49</span>
                </div>
              </div>
            )}

            {/* Speed Controls (for files) */}
            {!displayTrack.isLiveStream && (
              <div className="flex justify-center items-center gap-3 mb-4">
                <span className="text-sm text-gray-500 font-bold">السرعة:</span>
                {['0.75x', '1x', '1.25x', '1.5x', '2x'].map((speed) => (
                  <button
                    key={speed}
                    className={`w-10 h-10 rounded-full text-sm font-black transition-colors ${
                      speed === '1x'
                        ? 'bg-purple-600 text-white'
                        : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
                    }`}
                  >
                    {speed}
                  </button>
                ))}
              </div>
            )}

            {/* Recording Status */}
            {isRecording && (
              <div className="bg-red-50 border-2 border-[#E35335] rounded-2xl p-4 mb-4">
                <div className="flex items-center justify-center gap-3">
                  <span className="w-3 h-3 bg-[#E35335] rounded-full animate-pulse" />
                  <span className="text-lg font-black text-[#E35335]">تسجيل جارٍ</span>
                  <span className="text-2xl font-black text-gray-900 font-mono">
                    {formatTime(recordingDuration)}
                  </span>
                </div>
              </div>
            )}

            {/* Controls */}
            <div className="flex items-center justify-center gap-4 mb-4">
              {/* Heart */}
              <button className="w-12 h-12 rounded-full bg-gray-100 text-gray-600 flex items-center justify-center hover:bg-red-50 hover:text-red-500 transition-colors">
                <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z" />
                </svg>
              </button>

              {/* Previous */}
              <button className="w-12 h-12 rounded-full bg-gray-100 text-gray-600 flex items-center justify-center hover:bg-gray-200 transition-colors">
                <svg className="w-6 h-6" fill="currentColor" viewBox="0 0 24 24">
                  <path d="M6 6h2v12H6zm3.5 6l8.5 6V6z" />
                </svg>
              </button>

              {/* Play/Pause - Large Purple */}
              <button
                onClick={togglePlayPause}
                className="w-16 h-16 rounded-full bg-purple-600 text-white flex items-center justify-center hover:bg-purple-700 transition-colors shadow-xl"
              >
                {isLoading ? (
                  <svg className="w-8 h-8 animate-spin" fill="none" viewBox="0 0 24 24">
                    <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" />
                    <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z" />
                  </svg>
                ) : isPlaying ? (
                  <svg className="w-8 h-8" fill="currentColor" viewBox="0 0 24 24">
                    <rect x="6" y="4" width="4" height="16" rx="1" />
                    <rect x="14" y="4" width="4" height="16" rx="1" />
                  </svg>
                ) : (
                  <svg className="w-8 h-8 mr-[-2px]" fill="currentColor" viewBox="0 0 24 24">
                    <path d="M8 5v14l11-7z" />
                  </svg>
                )}
              </button>

              {/* Next */}
              <button className="w-12 h-12 rounded-full bg-gray-100 text-gray-600 flex items-center justify-center hover:bg-gray-200 transition-colors">
                <svg className="w-6 h-6" fill="currentColor" viewBox="0 0 24 24">
                  <path d="M6 18l8.5-6L6 6v12zM16 6v12h2V6h-2z" />
                </svg>
              </button>

              {/* Record */}
              <button
                onClick={handleRecordToggle}
                className={`w-12 h-12 rounded-full flex items-center justify-center transition-all ${
                  isRecording
                    ? 'bg-[#E35335] text-white animate-pulse'
                    : 'bg-gray-100 text-gray-600 hover:bg-red-50 hover:text-[#E35335]'
                }`}
              >
                {isRecording ? (
                  <svg className="w-6 h-6" fill="currentColor" viewBox="0 0 24 24">
                    <rect x="6" y="6" width="12" height="12" rx="2" />
                  </svg>
                ) : (
                  <svg className="w-6 h-6" fill="currentColor" viewBox="0 0 24 24">
                    <circle cx="12" cy="12" r="6" />
                  </svg>
                )}
              </button>
            </div>

            {/* Volume Slider */}
            <div className="flex items-center gap-3 px-4">
              <svg className="w-5 h-5 text-gray-400 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15.536 8.464a5 5 0 010 7.072m2.828-9.9a9 9 0 010 12.728M5.586 15H4a1 1 0 01-1-1v-4a1 1 0 011-1h1.586l4.707-4.707C10.923 3.663 12 4.109 12 5v14c0 .891-1.077 1.337-1.707.707L5.586 15z" />
              </svg>
              <input
                type="range"
                min="0"
                max="1"
                step="0.01"
                value={volume}
                onChange={(e) => setVolume(parseFloat(e.target.value))}
                className="w-full h-1.5 bg-gray-200 rounded-lg appearance-none cursor-pointer accent-purple-600"
              />
              <svg className="w-5 h-5 text-gray-400 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15.536 8.464a5 5 0 010 7.072m2.828-9.9a9 9 0 010 12.728M5.586 15H4a1 1 0 01-1-1v-4a1 1 0 011-1h1.586l4.707-4.707C10.923 3.663 12 4.109 12 5v14c0 .891-1.077 1.337-1.707.707L5.586 15z" />
              </svg>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
