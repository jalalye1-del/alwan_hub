'use client';

import { fmPrograms } from '@/data/programs';

export default function AdminPrograms() {
  return (
    <div>
      <div className="flex items-center justify-between mb-6">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">البرامج الإذاعية</h1>
          <p className="text-sm text-gray-500 mt-1">إدارة برامج إذاعة ألوان FM</p>
        </div>
        <button className="flex items-center gap-2 px-5 py-2.5 alwan-gradient text-white rounded-xl text-sm font-medium">➕ برنامج جديد</button>
      </div>
      <div className="grid sm:grid-cols-2 gap-4">
        {fmPrograms.map(program => (
          <div key={program.id} className="bg-white rounded-2xl border border-gray-100 overflow-hidden hover:shadow-md transition-shadow">
            <div className="relative h-32">
              <img src={program.imageUrl} alt={program.title} className="w-full h-full object-cover" />
              <div className="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent" />
              <div className="absolute bottom-3 right-3">
                <h3 className="text-white font-bold">{program.title}</h3>
              </div>
              {program.isLive && <div className="absolute top-3 right-3 live-indicator">مباشر</div>}
            </div>
            <div className="p-4">
              <p className="text-sm text-gray-500 mb-2">{program.presenterName}</p>
              <div className="flex items-center gap-4 text-xs text-gray-400 mb-3">
                <span>🕐 {program.liveTime} - {program.liveEndTime}</span>
                <span>📅 {program.broadcastDays.length} أيام</span>
              </div>
              <div className="flex gap-2">
                <button className="flex-1 py-2 rounded-lg bg-alwan-primary/10 text-alwan-primary text-xs font-medium">✏️ تعديل</button>
                <button className="py-2 px-3 rounded-lg bg-red-50 text-red-600 text-xs">🗑️</button>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
