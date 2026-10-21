'use client';

import { useState } from 'react';
import Link from 'next/link';

export default function AlwanHeader() {
  const [isDarkMode, setIsDarkMode] = useState(false);
  const [showMoreMenu, setShowMoreMenu] = useState(false);

  return (
    <header className="sticky top-0 z-[50] bg-white border-b border-gray-200 shadow-sm">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex items-center justify-between h-20 gap-4">
          {/* Logo - 20% smaller (was h-24, now h-19) */}
          <Link href="/" className="flex-shrink-0 -translate-x-4">
            <img
              src="/images/alwan-logo-new.png"
              alt="إذاعة ألوان 88.7 FM"
              className="h-[76px] w-auto"
            />
          </Link>

          {/* Navigation - Center */}
          <nav className="hidden lg:flex items-center gap-7">
            <Link href="/" className="text-[#1D00CD] font-black border-b-2 border-[#1D00CD] pb-1 text-base">
              الرئيسية
            </Link>
            <Link href="/programs" className="text-gray-700 hover:text-[#1D00CD] font-bold text-base flex items-center gap-1.5 transition-colors">
              البرامج
              <span className="text-[10px] bg-[#1D00CD] text-white px-1.5 py-0.5 rounded font-black">FM</span>
            </Link>
            <Link href="/lounge" className="text-gray-700 hover:text-[#1D00CD] font-bold text-base transition-colors">
              الإستراحة
            </Link>
            <Link href="/stations" className="text-gray-700 hover:text-[#1D00CD] font-bold text-base flex items-center gap-1.5 transition-colors">
              إذاعات
              <span className="text-[10px] bg-[#1D00CD] text-white px-1.5 py-0.5 rounded font-black">FM</span>
            </Link>
            <Link href="/library" className="text-gray-700 hover:text-[#1D00CD] font-bold text-base transition-colors">
              مكتبتي
            </Link>
            
            {/* More dropdown */}
            <div className="relative">
              <button
                onClick={() => setShowMoreMenu(!showMoreMenu)}
                className="text-gray-700 hover:text-[#1D00CD] font-bold text-base flex items-center gap-1.5 transition-colors"
              >
                المزيد
                <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
                </svg>
              </button>
              {showMoreMenu && (
                <div className="absolute top-full right-0 mt-2 w-48 bg-white rounded-xl shadow-2xl border border-gray-100 py-2 overflow-hidden">
                  <Link href="/podcasts" className="block px-4 py-2.5 text-sm font-bold text-gray-700 hover:bg-gray-50 hover:text-[#1D00CD]">البودكاست</Link>
                  <Link href="/audiobooks" className="block px-4 py-2.5 text-sm font-bold text-gray-700 hover:bg-gray-50 hover:text-[#1D00CD]">الكتب الصوتية</Link>
                  <Link href="/games" className="block px-4 py-2.5 text-sm font-bold text-gray-700 hover:bg-gray-50 hover:text-[#1D00CD]">الألعاب</Link>
                  <Link href="/favorites" className="block px-4 py-2.5 text-sm font-bold text-gray-700 hover:bg-gray-50 hover:text-[#1D00CD]">المفضلة</Link>
                </div>
              )}
            </div>
          </nav>

          {/* Actions - Left side */}
          <div className="flex items-center gap-3">
            {/* Language Icon - NEW */}
            <button className="w-11 h-11 rounded-full bg-gray-100 text-gray-700 flex items-center justify-center hover:bg-gray-200 transition-colors" title="تغيير اللغة">
              <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 5h12M9 3v2m1.048 9.5A18.022 18.022 0 016.412 9m6.088 9h7M11 21l5-10 5 10M12.751 5C11.783 10.77 8.07 15.61 3 18.129" />
              </svg>
            </button>

            {/* Dark mode toggle */}
            <button
              onClick={() => setIsDarkMode(!isDarkMode)}
              className="w-11 h-11 rounded-full bg-[#1D00CD] text-white flex items-center justify-center hover:bg-[#1200A8] transition-colors"
              title="تبديل الوضع"
            >
              {isDarkMode ? (
                <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 11-8 0 4 4 0 018 0z" />
                </svg>
              ) : (
                <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z" />
                </svg>
              )}
            </button>

            {/* Search */}
            <button className="w-11 h-11 text-gray-600 hover:text-[#1D00CD] flex items-center justify-center transition-colors" title="بحث">
              <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
              </svg>
            </button>

            {/* Notifications */}
            <button className="w-11 h-11 text-gray-600 hover:text-[#1D00CD] flex items-center justify-center transition-colors relative" title="الإشعارات">
              <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9" />
              </svg>
              <span className="absolute top-1.5 right-1.5 w-2.5 h-2.5 bg-[#E35335] rounded-full border-2 border-white"></span>
            </button>

            {/* Login Button */}
            <button className="flex items-center gap-2 bg-[#1D00CD] text-white px-5 py-2.5 rounded-xl hover:bg-[#1200A8] transition-colors">
              <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
              </svg>
              <span className="text-sm font-black">تسجيل الدخول</span>
            </button>

            {/* User Avatar */}
            <div className="w-11 h-11 rounded-full overflow-hidden border-2 border-gray-300 flex-shrink-0">
              <img
                src="https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=100&q=80"
                alt="User"
                className="w-full h-full object-cover"
              />
            </div>
          </div>
        </div>
      </div>
    </header>
  );
}
