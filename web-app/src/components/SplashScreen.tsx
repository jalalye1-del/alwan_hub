'use client';

import { useEffect, useState } from 'react';

interface SplashScreenProps {
  onFinish: () => void;
}

export default function SplashScreen({ onFinish }: SplashScreenProps) {
  const [phase, setPhase] = useState<'showing' | 'exiting'>('showing');

  useEffect(() => {
    console.log('SplashScreen mounted');
    
    // مرحلة العرض - 4 ثوانٍ
    const showTimer = setTimeout(() => {
      console.log('Starting exit animation');
      setPhase('exiting');
    }, 4000);

    // مرحلة الخروج - 1 ثانية ثم الانتهاء
    const exitTimer = setTimeout(() => {
      console.log('Splash finished');
      onFinish();
    }, 5000);

    return () => {
      clearTimeout(showTimer);
      clearTimeout(exitTimer);
    };
  }, [onFinish]);

  return (
    <div className="fixed inset-0 z-[9999] overflow-hidden bg-white">
      {/* خلفية متحركة */}
      <div className="absolute inset-0">
        <div className="absolute inset-0 bg-gradient-to-br from-blue-50 via-white to-purple-50" />
        
        {/* دوائر متحركة */}
        <div className="absolute top-1/4 right-1/4 w-64 h-64 bg-blue-200 rounded-full blur-3xl opacity-30 animate-pulse" />
        <div className="absolute bottom-1/4 left-1/4 w-96 h-96 bg-purple-200 rounded-full blur-3xl opacity-30 animate-pulse" style={{ animationDelay: '1s' }} />
        <div className="absolute top-1/2 left-1/2 w-48 h-48 bg-amber-200 rounded-full blur-3xl opacity-30 animate-pulse" style={{ animationDelay: '2s' }} />
      </div>

      {/* محتوى الشاشة */}
      <div className={`relative z-10 flex flex-col items-center justify-center w-full h-full transition-all duration-1000 ${
        phase === 'exiting' ? 'opacity-0 scale-110' : 'opacity-100 scale-100'
      }`}>
        {/* GIF الرئيسي - ملء الشاشة */}
        <img
          src="/images/splash.gif"
          alt="Alwan Hub"
          className="absolute inset-0 w-full h-full object-cover"
        />
        
        {/* طبقة فوق GIF للنص */}
        <div className="absolute inset-0 bg-gradient-to-t from-black/60 via-transparent to-transparent" />
        
        {/* النص في الأسفل */}
        <div className="absolute bottom-20 left-0 right-0 text-center px-4">
          <h1 className="text-5xl md:text-7xl font-bold mb-4 text-white drop-shadow-lg">
            ألوان هَب
          </h1>
          <p className="text-xl md:text-2xl text-white/90 font-light drop-shadow-md">
            ألوان تنبض بالحياة
          </p>
          
          {/* مؤشر التحميل */}
          <div className="flex items-center justify-center gap-2 mt-8">
            <div className="w-3 h-3 bg-blue-500 rounded-full animate-bounce" style={{ animationDelay: '0s' }} />
            <div className="w-3 h-3 bg-purple-500 rounded-full animate-bounce" style={{ animationDelay: '0.15s' }} />
            <div className="w-3 h-3 bg-amber-400 rounded-full animate-bounce" style={{ animationDelay: '0.3s' }} />
          </div>
        </div>
      </div>
    </div>
  );
}
