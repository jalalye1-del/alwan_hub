'use client';

import { fmPrograms, dayLabels } from '@/data/programs';
import { useAudioStore } from '@/lib/audioStore';
import { useState } from 'react';

export default function ProgramsPageContent() {
  const { play, currentTrack, isPlaying } = useAudioStore();
  const [filter, setFilter] = useState('all');

  const handlePlay = (program: typeof fmPrograms[0]) => {
    play({
      id: program.id,
      title: program.title,
      subtitle: program.presenterName,
      url: program.streamUrl,
      imageUrl: program.imageUrl,
      isLiveStream: program.isLive,
      presenterName: program.presenterName,
      programImage: program.imageUrl,
      category: 'برامج ألوان',
    });
  };

  return (
    <div>
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-gray-900 mb-2">البرامج الإذاعية</h1>
        <p className="text-gray-500">جميع برامج إذاعة ألوان FM مع جدول البث والإعادة</p>
      </div>

      {/* Schedule Overview */}
      <div className="bg-white rounded-2xl border border-gray-100 p-6 mb-8">
        <h2 className="text-lg font-bold text-gray-900 mb-4">الجدول الأسبوعي</h2>
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-gray-100">
                <th className="text-right py-3 px-2 font-medium text-gray-500">البرنامج</th>
                {dayLabels.map((day, i) => (
                  <th key={i} className="text-center py-3 px-2 font-medium text-gray-500">{day}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {fmPrograms.map((program) => (
                <tr key={program.id} className="border-b border-gray-50 hover:bg-gray-50">
                  <td className="py-3 px-2">
                    <div className="flex items-center gap-2">
                      <div className="w-8 h-8 rounded-lg flex items-center justify-center" style={{ backgroundColor: program.accentColor + '20' }}>
                        <span className="text-sm">🎙️</span>
                      </div>
                      <div>
                        <div className="font-medium text-gray-900">{program.title}</div>
                        <div className="text-xs text-gray-400">{program.liveTime} - {program.liveEndTime}</div>
                      </div>
                    </div>
                  </td>
                  {dayLabels.map((_, i) => (
                    <td key={i} className="text-center py-3 px-2">
                      {program.broadcastDays.includes(i) ? (
                        <span className="inline-block w-6 h-6 rounded-full bg-green-100 text-green-600 text-xs leading-6">✓</span>
                      ) : (
                        <span className="inline-block w-6 h-6 rounded-full bg-gray-50 text-gray-300 text-xs leading-6">-</span>
                      )}
                    </td>
                  ))}
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {/* Programs Grid */}
      <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-6">
        {fmPrograms.map((program) => {
          const isCurrent = currentTrack?.id === program.id;
          return (
            <div key={program.id} className="bg-white rounded-2xl overflow-hidden border border-gray-100 hover:shadow-xl card-hover">
              <div className="relative h-48 overflow-hidden">
                <img src={program.imageUrl} alt={program.title} className="w-full h-full object-cover" />
                <div className="absolute inset-0 bg-gradient-to-t from-black/70 to-transparent" />
                {program.isLive && <div className="absolute top-3 right-3 live-indicator">مباشر</div>}
                <div className="absolute bottom-4 right-4 left-4">
                  <h3 className="text-xl font-bold text-white">{program.title}</h3>
                  <p className="text-white/80 text-sm mt-1">{program.presenterName}</p>
                </div>
              </div>
              <div className="p-5">
                <p className="text-sm text-gray-600 mb-4">{program.description}</p>
                <div className="flex items-center gap-4 mb-4">
                  <div className="flex items-center gap-1 text-xs text-gray-500">
                    <span>🕐</span> {program.liveTime} - {program.liveEndTime}
                  </div>
                  <div className="flex items-center gap-1 text-xs text-gray-500">
                    <span>🔄</span> الإعادة: {program.replayTimes.join('، ')}
                  </div>
                </div>
                <div className="flex gap-2">
                  <button
                    onClick={() => handlePlay(program)}
                    className={`flex-1 flex items-center justify-center gap-2 py-3 rounded-xl font-medium text-sm transition-all ${
                      isCurrent && isPlaying
                        ? 'bg-red-500 text-white'
                        : 'alwan-gradient text-white hover:opacity-90'
                    }`}
                  >
                    {isCurrent && isPlaying ? 'يُبث الآن' : program.isLive ? 'استمع مباشرة' : 'تشغيل'}
                  </button>
                  <button className="px-4 py-3 rounded-xl bg-gray-100 text-gray-600 hover:bg-gray-200 text-sm transition-colors">
                    🔔 تذكير
                  </button>
                </div>
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}
