'use client';

import { loungeCategories } from '@/data/lounge';

export default function AdminLounge() {
  return (
    <div>
      <div className="flex items-center justify-between mb-6">
        <div><h1 className="text-2xl font-bold text-gray-900">الاستراحة</h1><p className="text-sm text-gray-500 mt-1">إدارة محتوى الاستراحة والمكتبة الصوتية</p></div>
        <button className="px-5 py-2.5 alwan-gradient text-white rounded-xl text-sm font-medium">➕ إضافة تصنيف</button>
      </div>
      <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-4">
        {loungeCategories.map(cat => (
          <div key={cat.categoryId} className="bg-white rounded-xl border border-gray-100 overflow-hidden hover:shadow-md transition-shadow">
            <div className="relative h-28 overflow-hidden">
              <img src={cat.imageUrl} alt={cat.title} className="w-full h-full object-cover" />
              <div className="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent" />
              <div className="absolute bottom-2 right-2"><span className="text-xl">{cat.icon}</span></div>
            </div>
            <div className="p-4">
              <h3 className="font-bold text-gray-900">{cat.title}</h3>
              <p className="text-xs text-gray-500 mt-1">{cat.itemCount} {cat.trackItemLabel}</p>
              <div className="flex gap-2 mt-3">
                <button className="flex-1 py-2 rounded-lg bg-alwan-primary/10 text-alwan-primary text-xs font-medium">إدارة المحتوى</button>
                <button className="py-2 px-3 rounded-lg bg-gray-100 text-gray-600 text-xs">✏️</button>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
