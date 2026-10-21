'use client';

import Link from 'next/link';

const quickLinks = [
  { href: '/stations', icon: '📻', label: 'البث المباشر', color: 'from-red-500 to-pink-500' },
  { href: '/podcasts', icon: '🎙️', label: 'البودكاست', color: 'from-purple-500 to-indigo-500' },
  { href: '/audiobooks', icon: '📚', label: 'الكتب الصوتية', color: 'from-emerald-500 to-teal-500' },
  { href: '/programs', icon: '📅', label: 'البرامج', color: 'from-blue-500 to-cyan-500' },
  { href: '/chat', icon: '💬', label: 'الدردشة', color: 'from-orange-500 to-amber-500' },
  { href: '/games', icon: '🎮', label: 'الألعاب', color: 'from-violet-500 to-purple-500' },
  { href: '/lounge', icon: '🎵', label: 'الاستراحة', color: 'from-pink-500 to-rose-500' },
  { href: '/recordings', icon: '⏺️', label: 'التسجيلات', color: 'from-gray-600 to-gray-800' },
  { href: '/favorites', icon: '⭐', label: 'المفضلة', color: 'from-yellow-500 to-orange-500' },
];

export default function QuickAccess() {
  return (
    <section>
      <div className="flex items-center justify-between mb-6">
        <h2 className="text-2xl font-bold text-gray-900">الوصول السريع</h2>
      </div>
      <div className="grid grid-cols-3 sm:grid-cols-4 md:grid-cols-5 lg:grid-cols-9 gap-3 sm:gap-4">
        {quickLinks.map((link) => (
          <Link
            key={link.href}
            href={link.href}
            className="group flex flex-col items-center gap-2 p-4 rounded-2xl bg-white border border-gray-100 hover:border-transparent hover:shadow-xl card-hover"
          >
            <div className={`w-12 h-12 rounded-xl bg-gradient-to-br ${link.color} flex items-center justify-center text-xl shadow-lg group-hover:scale-110 transition-transform`}>
              {link.icon}
            </div>
            <span className="text-xs sm:text-sm font-medium text-gray-700 text-center group-hover:text-alwan-primary transition-colors">
              {link.label}
            </span>
          </Link>
        ))}
      </div>
    </section>
  );
}
