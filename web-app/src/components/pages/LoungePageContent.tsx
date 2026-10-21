'use client';

import Link from 'next/link';
import { loungeCategories } from '@/data/lounge';

export default function LoungePageContent() {
  return (
    <div>
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-gray-900 mb-2">استراحة ألوان</h1>
        <p className="text-gray-500">مكتبة صوتية شاملة — أغاني، أناشيد، قرآن، مسلسلات إذاعية، برامج ثقافية وفنية</p>
      </div>

      <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-5">
        {loungeCategories.map((cat) => (
          <Link
            key={cat.categoryId}
            href={`/lounge/${cat.categoryId}`}
            className="group relative overflow-hidden rounded-2xl aspect-[4/3] shadow-sm hover:shadow-xl card-hover"
          >
            <img src={cat.imageUrl} alt={cat.title} className="w-full h-full object-cover group-hover:scale-110 transition-transform duration-700" />
            <div className="absolute inset-0 bg-gradient-to-t from-black/80 via-black/40 to-transparent" />
            <div className="absolute bottom-0 right-0 left-0 p-5">
              <div className="flex items-center gap-3 mb-1">
                <span className="text-2xl">{cat.icon}</span>
                <h3 className="text-lg font-bold text-white">{cat.title}</h3>
              </div>
              <p className="text-sm text-white/70">{cat.itemCount} {cat.trackItemLabel}</p>
            </div>
          </Link>
        ))}
      </div>
    </div>
  );
}
