'use client';

import { podcastEpisodes } from '@/data/podcasts';

export default function AdminPodcasts() {
  return (
    <div>
      <div className="flex items-center justify-between mb-6">
        <div><h1 className="text-2xl font-bold text-gray-900">البودكاست</h1><p className="text-sm text-gray-500 mt-1">إدارة حلقات البودكاست</p></div>
        <button className="flex items-center gap-2 px-5 py-2.5 alwan-gradient text-white rounded-xl text-sm font-medium">➕ حلقة جديدة</button>
      </div>
      <div className="space-y-3">
        {podcastEpisodes.map(episode => (
          <div key={episode.id} className="flex items-center gap-4 bg-white rounded-xl border border-gray-100 p-4 hover:shadow-md transition-shadow">
            <img src={episode.imageAsset} alt={episode.title} className="w-16 h-16 rounded-xl object-cover flex-shrink-0" />
            <div className="flex-1 min-w-0">
              <h3 className="font-bold text-gray-900 truncate">{episode.title}</h3>
              <p className="text-sm text-gray-500">{episode.seriesName} • {episode.hostName}</p>
              <p className="text-xs text-gray-400 mt-1">{new Date(episode.publishedAt).toLocaleDateString('ar-YE')} • {episode.listeners.toLocaleString('ar')} مستمع</p>
            </div>
            <div className="flex gap-2">
              <button className="px-3 py-1.5 rounded-lg bg-alwan-primary/10 text-alwan-primary text-xs">✏️ تعديل</button>
              <button className="px-3 py-1.5 rounded-lg bg-red-50 text-red-600 text-xs">🗑️</button>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
