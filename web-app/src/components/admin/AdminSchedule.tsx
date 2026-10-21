'use client';

import { fmPrograms, dayLabels } from '@/data/programs';

export default function AdminSchedule() {
  return (
    <div>
      <div className="flex items-center justify-between mb-6">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">الجدول البرامجي</h1>
          <p className="text-sm text-gray-500 mt-1">إدارة جدول البث الأسبوعي</p>
        </div>
        <button className="px-5 py-2.5 alwan-gradient text-white rounded-xl text-sm font-medium">➕ إضافة فقرة</button>
      </div>
      <div className="bg-white rounded-2xl border border-gray-100 overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead className="bg-gray-50">
              <tr>
                <th className="text-right py-3 px-4 font-medium text-gray-500">البرنامج</th>
                <th className="text-right py-3 px-4 font-medium text-gray-500">المقدم</th>
                <th className="text-center py-3 px-4 font-medium text-gray-500">البث</th>
                <th className="text-center py-3 px-4 font-medium text-gray-500">الإعادة</th>
                {dayLabels.map((d, i) => <th key={i} className="text-center py-3 px-3 font-medium text-gray-500">{d}</th>)}
                <th className="text-center py-3 px-4 font-medium text-gray-500">إجراءات</th>
              </tr>
            </thead>
            <tbody>
              {fmPrograms.map(program => (
                <tr key={program.id} className="border-b border-gray-50 hover:bg-gray-50">
                  <td className="py-3 px-4 font-medium text-gray-900">{program.title}</td>
                  <td className="py-3 px-4 text-gray-600">{program.presenterName}</td>
                  <td className="py-3 px-4 text-center text-gray-600">{program.liveTime}</td>
                  <td className="py-3 px-4 text-center text-gray-500 text-xs">{program.replayTimes.join('، ')}</td>
                  {dayLabels.map((_, i) => (
                    <td key={i} className="text-center py-3 px-2">
                      {program.broadcastDays.includes(i) ? (
                        <span className="inline-block w-6 h-6 rounded-full bg-green-100 text-green-600 text-xs leading-6">✓</span>
                      ) : (
                        <span className="inline-block w-6 h-6 rounded-full bg-gray-50 text-gray-300 text-xs leading-6">—</span>
                      )}
                    </td>
                  ))}
                  <td className="py-3 px-4 text-center">
                    <button className="px-2 py-1 rounded bg-alwan-primary/10 text-alwan-primary text-xs">✏️ تعديل</button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
