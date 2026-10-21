'use client';

import { useState, useEffect } from 'react';
import AlwanHeader from '@/components/AlwanHeader';
import AlwanPlayer from '@/components/AlwanPlayer';
import AlwanHero from '@/components/AlwanHero';

export default function HomePage() {
  const [showSplash, setShowSplash] = useState(true);
  const [isExiting, setIsExiting] = useState(false);

  useEffect(() => {
    if (!showSplash) return;
    const timer = setTimeout(() => setIsExiting(true), 4000);
    return () => clearTimeout(timer);
  }, [showSplash]);

  useEffect(() => {
    if (!isExiting) return;
    const timer = setTimeout(() => setShowSplash(false), 800);
    return () => clearTimeout(timer);
  }, [isExiting]);

  if (showSplash) {
    return (
      <div className={`fixed inset-0 z-[9999] overflow-hidden bg-white transition-all duration-700 ${isExiting ? 'opacity-0 scale-110' : 'opacity-100 scale-100'}`}>
        <div className="absolute inset-0 bg-gradient-to-br from-[#E0F2FE] via-white to-[#F5F3FF]" />
        <div className="absolute top-1/4 right-1/4 w-64 h-64 bg-[#A78BFA] rounded-full blur-3xl opacity-30 animate-pulse" />
        <div className="absolute bottom-1/4 left-1/4 w-96 h-96 bg-[#C084FC] rounded-full blur-3xl opacity-30 animate-pulse" style={{ animationDelay: '1s' }} />
        <div className="absolute top-1/2 left-1/2 w-48 h-48 bg-[#FA9E0D] rounded-full blur-3xl opacity-30 animate-pulse" style={{ animationDelay: '2s' }} />

        <img
          src="/images/splash.gif"
          alt="Alwan Hub"
          className="absolute inset-0 w-full h-full object-cover"
        />

        <div className="absolute inset-0 bg-gradient-to-t from-black/70 via-black/30 to-transparent" />

        <div className="relative z-10 flex flex-col items-center justify-center h-full">
          <div className="absolute bottom-24 left-0 right-0 text-center px-4">
            <h1 className="text-6xl md:text-8xl font-black mb-4 text-white" style={{ textShadow: '3px 3px 12px rgba(0,0,0,0.8)' }}>
              منصة ألوان
            </h1>
            <p className="text-2xl md:text-3xl text-white/95 font-black mb-8" style={{ textShadow: '2px 2px 8px rgba(0,0,0,0.6)' }}>
              ألوان تنبض بالحياة
            </p>
            <div className="flex items-center justify-center gap-3">
              <div className="w-4 h-4 bg-[#1D00CD] rounded-full animate-bounce" style={{ animationDelay: '0s' }} />
              <div className="w-4 h-4 bg-[#C084FC] rounded-full animate-bounce" style={{ animationDelay: '0.15s' }} />
              <div className="w-4 h-4 bg-[#FA9E0D] rounded-full animate-bounce" style={{ animationDelay: '0.3s' }} />
            </div>
          </div>
        </div>
      </div>
    );
  }

  return (
    <>
      <AlwanHeader />
      <main className="pb-28">
        <AlwanHero />
      </main>
      <AlwanPlayer />
    </>
  );
}
