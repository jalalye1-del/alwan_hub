'use client';

import { fmPrograms, dayLabels } from '@/data/programs';
import { useState } from 'react';

export default function ScheduleSection() {
  const [selectedDay, setSelectedDay] = useState(() => {
    const day = new Date().getDay();
    return day === 6 ? 0 : day + 1;
  });

  const dayPrograms = fmPrograms.filter(p => p.broadcastDays.includes(selectedDay));

  return (
    <section>
      <div className="flex items-center justify-between mb-6">
        <div>
          <h2 className="text-2xl font-bold text-gray-900">الجدول البرامجي</h2>
          <p className="text-sm text-gray-500 mt-1">مواعيد البث والإعادة</p>
        </div>
      </div>

      {/* Day Selector */}
      <div className="flex gap-2 mb-6 overflow-x-auto pb-2">
        {dayLabels.map((label, index) => (
          <button
            key={index}
            onClick={() => setSelectedDay(index)}
            className={`px-4 py-2 rounded-xl text-sm font-medium whitespace-nowrap transition-all ${
              selectedDay === index
                ? 'alwan-gradient text-white shadow-lg'
                : 'bg-white text-gray-600 border border-gray-200 hover:border-alwan-primary/30'
            }`}
          >
            {label}
          </button>
        ))}
      </div>

      {/* Schedule Cards */}
      <div className="space-y-3">
        {dayPrograms.length > 0 ? (
          dayPrograms.map((program) => (
            <div
              key={program.id}
              className="flex items-center gap-4 p-4 bg-white rounded-2xl border border-gray-100 hover:shadow-md transition-shadow"
            >
              <div
                className="w-14 h-14 rounded-xl flex items-center justify-center flex-shrink-0"
                style={{ backgroundColor: program.accentColor + '20' }}
              >
                <span className="text-2xl">🎙️</span>
              </div>
              <div className="flex-1 min-w-0">
                <h3 className="font-bold text-gray-900">{program.title}</h3>
                <p className="text-sm text-gray-500">{program.presenterName}</p>
              </div>
              <div className="text-left flex-shrink-0">
                <div className="text-sm font-bold" style={{ color: program.accentColor }}>
                  {program.liveTime}
                </div>
                <div className="text-xs text-gray-400">
                  {program.liveEndTime} - {program.liveTime}
                </div>
              </div>
              {program.isLive && (
                <span className="live-indicator text-[10px]">مباشر</span>
              )}
            </div>
          ))
        ) : (
          <div className="text-center py-12 text-gray-400">
            <span className="text-4xl mb-4 block">📅</span>
            <p>لا توجد برامج مجدولة لهذا اليوم</p>
          </div>
        )}
      </div>
    </section>
  );
}
