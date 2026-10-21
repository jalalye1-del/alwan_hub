'use client';

import { useAudioStore } from '@/lib/audioStore';
import { useState } from 'react';

export default function AudioPlayer() {
  const {
    currentTrack,
    isPlaying,
    isLoading,
    volume,
    isRecording,
    recordingDuration,
    togglePlayPause,
    setVolume,
    stop,
    startRecording,
    stopRecording,
  } = useAudioStore();

  const [isVolumeExpanded, setIsVolumeExpanded] = useState(false);
  const [showRecordConfirm, setShowRecordConfirm] = useState(false);

  if (!currentTrack) return null;

  const formatTime = (seconds: number): string => {
    const hrs = Math.floor(seconds / 3600);
    const mins = Math.floor((seconds % 3600) / 60);
    const secs = Math.floor(seconds % 60);
    if (hrs > 0) {
      return `${hrs}:${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
    }
    return `${mins}:${secs.toString().padStart(2, '0')}`;
  };

  const handleRecordToggle = () => {
    if (isRecording) {
      stopRecording();
      // In production, this would save the recording
    } else {
      setShowRecordConfirm(true);
      setTimeout(() => {
        startRecording();
        setShowRecordConfirm(false);
      }, 300);
    }
  };

  return (
    <div className="fixed bottom-0 left-0 right-0 z-50">
      {/* Recording Banner */}
      {isRecording && (
        <div className="bg-red-500 text-white py-1 px-4 text-center text-sm font-medium animate-pulse">
          <span className="inline-flex items-center gap-2">
            <span className="w-2 h-2 bg-white rounded-full animate-pulse" />
            تسجيل جارٍ — {formatTime(recordingDuration)}
          </span>
        </div>
      )}

      {/* Player Bar */}
      <div className="bg-white/95 backdrop-blur-xl border-t border-gray-200 shadow-2xl">
        <div className="max-w-7xl mx-auto px-3 sm:px-6 lg:px-8">
          <div className="flex items-center h-20 gap-3 sm:gap-4">
            {/* Track Image */}
            <div className="relative flex-shrink-0">
              <div className="w-14 h-14 sm:w-16 sm:h-16 rounded-xl overflow-hidden bg-gradient-to-br from-alwan-primary to-alwan-secondary">
                {currentTrack.imageUrl ? (
                  <img
                    src={currentTrack.imageUrl}
                    alt={currentTrack.title}
                    className="w-full h-full object-cover"
                    onError={(e) => {
                      (e.target as HTMLImageElement).style.display = 'none';
                    }}
                  />
                ) : (
                  <div className="w-full h-full flex items-center justify-center">
                    <span className="text-white text-2xl">♪</span>
                  </div>
                )}
              </div>
              {isPlaying && (
                <div className="absolute -top-1 -left-1 w-3 h-3 bg-green-500 rounded-full border-2 border-white animate-pulse" />
              )}
            </div>

            {/* Track Info */}
            <div className="flex-1 min-w-0">
              <div className="flex items-center gap-2">
                <h3 className="text-sm sm:text-base font-bold text-gray-900 truncate">
                  {currentTrack.title}
                </h3>
                {currentTrack.isLiveStream && (
                  <span className="live-indicator text-[10px]">LIVE</span>
                )}
                {isRecording && (
                  <span className="inline-flex items-center gap-1 px-2 py-0.5 bg-red-100 text-red-600 text-[10px] font-bold rounded-full">
                    <span className="w-1.5 h-1.5 bg-red-500 rounded-full animate-pulse" />
                    REC
                  </span>
                )}
              </div>
              <p className="text-xs sm:text-sm text-gray-500 truncate mt-0.5">
                {currentTrack.presenterName || currentTrack.subtitle}
              </p>
              {isLoading && (
                <div className="mt-1.5 h-1 bg-gray-100 rounded-full overflow-hidden w-32">
                  <div className="h-full bg-alwan-primary rounded-full animate-pulse w-1/2" />
                </div>
              )}
            </div>

            {/* Controls */}
            <div className="flex items-center gap-1 sm:gap-2">
              {/* Record Button */}
              <button
                onClick={handleRecordToggle}
                className={`relative w-10 h-10 sm:w-11 sm:h-11 rounded-full flex items-center justify-center transition-all ${
                  isRecording
                    ? 'bg-red-500 text-white hover:bg-red-600 scale-110'
                    : 'bg-gray-100 text-gray-600 hover:bg-red-50 hover:text-red-500'
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
                {isRecording && (
                  <span className="absolute inset-0 rounded-full border-2 border-red-500 animate-ping" />
                )}
              </button>

              {/* Play/Pause */}
              <button
                onClick={togglePlayPause}
                className="w-12 h-12 sm:w-14 sm:h-14 rounded-full alwan-gradient text-white flex items-center justify-center hover:opacity-90 transition-opacity shadow-lg"
                title={isPlaying ? 'إيقاف مؤقت' : 'تشغيل'}
              >
                {isLoading ? (
                  <svg className="w-6 h-6 animate-spin" fill="none" viewBox="0 0 24 24">
                    <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" />
                    <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z" />
                  </svg>
                ) : isPlaying ? (
                  <svg className="w-6 h-6" fill="currentColor" viewBox="0 0 24 24">
                    <rect x="6" y="4" width="4" height="16" rx="1" />
                    <rect x="14" y="4" width="4" height="16" rx="1" />
                  </svg>
                ) : (
                  <svg className="w-6 h-6 mr-[-2px]" fill="currentColor" viewBox="0 0 24 24">
                    <path d="M8 5v14l11-7z" />
                  </svg>
                )}
              </button>

              {/* Stop */}
              <button
                onClick={stop}
                className="hidden sm:flex w-10 h-10 rounded-full bg-gray-100 text-gray-600 items-center justify-center hover:bg-gray-200 transition-colors"
                title="إيقاف"
              >
                <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
                  <rect x="6" y="6" width="12" height="12" rx="2" />
                </svg>
              </button>

              {/* Volume */}
              <div className="relative hidden sm:block">
                <button
                  onClick={() => setIsVolumeExpanded(!isVolumeExpanded)}
                  className="w-10 h-10 rounded-full bg-gray-100 text-gray-600 flex items-center justify-center hover:bg-gray-200 transition-colors"
                >
                  <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15.536 8.464a5 5 0 010 7.072m2.828-9.9a9 9 0 010 12.728M5.586 15H4a1 1 0 01-1-1v-4a1 1 0 011-1h1.586l4.707-4.707C10.923 3.663 12 4.109 12 5v14c0 .891-1.077 1.337-1.707.707L5.586 15z" />
                  </svg>
                </button>
                {isVolumeExpanded && (
                  <div className="absolute bottom-12 left-1/2 -translate-x-1/2 bg-white rounded-xl shadow-xl border p-3 w-32 animate-slide-up">
                    <input
                      type="range"
                      min="0"
                      max="1"
                      step="0.01"
                      value={volume}
                      onChange={(e) => setVolume(parseFloat(e.target.value))}
                      className="w-full h-2 bg-gray-200 rounded-lg appearance-none cursor-pointer accent-alwan-primary"
                    />
                    <div className="text-center text-xs text-gray-500 mt-1">
                      {Math.round(volume * 100)}%
                    </div>
                  </div>
                )}
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Record Confirm Dialog */}
      {showRecordConfirm && (
        <div className="fixed inset-0 z-60 flex items-center justify-center bg-black/50">
          <div className="bg-white rounded-2xl p-6 mx-4 max-w-sm w-full animate-slide-up">
            <div className="text-center">
              <div className="w-16 h-16 mx-auto mb-4 rounded-full bg-red-100 flex items-center justify-center">
                <svg className="w-8 h-8 text-red-500" fill="currentColor" viewBox="0 0 24 24">
                  <circle cx="12" cy="12" r="6" />
                </svg>
              </div>
              <h3 className="text-lg font-bold text-gray-900 mb-2">بدء التسجيل</h3>
              <p className="text-sm text-gray-500">سيتم بدء تسجيل البث المباشر. هل تريد المتابعة؟</p>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
