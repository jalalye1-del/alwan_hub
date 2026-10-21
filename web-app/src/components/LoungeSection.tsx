'use client';

import Link from 'next/link';
import { loungeCategories } from '@/data/lounge';

export default function LoungeSection() {
  return (
    <section>
      <div className="flex items-center justify-between mb-6">
        <div>
          <h2 className="text-2xl font-bold text-gray-900">استراحة ألوان</h2>
          <p className="text-sm text-gray-500 mt-1">مكتبة صوتية متنوعة</p>
        </div>
        <Link href="/lounge" className="text-sm font-medium text-alwan-primary hover:text-alwan-secondary">
          عرض الكل ←
        </Link>
      </div>

      <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-6 gap-3 sm:gap-4">
        {loungeCategories.slice(0, 6).map((cat) => (
          <Link
            key={cat.categoryId}
            href={`/lounge/${cat.categoryId}`}
            className="group relative overflow-hidden rounded-2xl aspect-square"
          >
            <img
              src={cat.imageUrl}
              alt={cat.title}
              className="w-full h-full object-cover group-hover:scale-110 transition-transform duration-500"
            />
            <div className="absolute inset-0 bg-gradient-to-t from-black/80 via-black/30 to-transparent" />
            <div className="absolute bottom-0 right-0 left-0 p-3">
              <div className="flex items-center gap-2">
                <span className="text-xl">{cat.icon}</span>
                <h3 className="text-sm font-bold text-white truncate">{cat.title}</h3>
              </div>
              <p className="text-xs text-white/70 mt-0.5">{cat.itemCount} {cat.trackItemLabel}</p>
            </div>
          </Link>
        ))}
      </div>
    </section>
  );
}
