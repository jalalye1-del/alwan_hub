'use client';

import { podcastEpisodes, formatDuration, formatDate } from '@/data/podcasts';
import { useAudioStore } from '@/lib/audioStore';

export default function PodcastsPageContent() {
  const { play, currentTrack, isPlaying } = useAudioStore();

  return (
    <div>
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-gray-900 mb-2">البودكاست</h1>
        <p className="text-gray-500">حلقات صوتية وفيديو من أفضل البرامج والمقدمين</p>
      </div>

      <div className="grid gap-6">
        {podcastEpisodes.map((episode) => {
          const isCurrent = currentTrack?.id === episode.id;
          return (
            <div key={episode.id} className="bg-white rounded-2xl overflow-hidden border border-gray-100 hover:shadow-xl card-hover">
              <div className="flex flex-col sm:flex-row">
                <div className="relative sm:w-64 h-48 sm:h-auto overflow-hidden flex-shrink-0">
                  <img src={episode.imageAsset} alt={episode.title} className="w-full h-full object-cover" />
                  <div className="absolute inset-0 bg-gradient-to-t from-black/30 to-transparent sm:bg-gradient-to-r" />
                  <div className="absolute bottom-3 right-3 left-3 sm:bottom-auto sm:top-3 sm:left-auto">
                    <span className="px-2 py-1 bg-black/40 backdrop-blur-sm rounded-lg text-white text-xs">{formatDuration(episode.duration)}</span>
                  </div>
                  {episode.isFeatured && (
                    <div className="absolute top-3 right-3 px-2 py-1 bg-amber-500 rounded-lg text-white text-xs font-bold">⭐ مميز</div>
                  )}
                </div>
                <div className="flex-1 p-6">
                  <div className="text-xs text-alwan-primary font-medium mb-1">{episode.seriesName}</div>
                  <h2 className="text-xl font-bold text-gray-900 mb-2">{episode.title}</h2>
                  <p className="text-sm text-gray-600 mb-4 line-clamp-2">{episode.description}</p>
                  <div className="flex flex-wrap items-center gap-4 text-sm text-gray-500 mb-4">
                    <span className="flex items-center gap-1">🎙️ {episode.hostName}</span>
                    <span className="flex items-center gap-1">📅 {formatDate(episode.publishedAt)}</span>
                    <span className="flex items-center gap-1">👥 {episode.listeners.toLocaleString('ar')} مستمع</span>
                  </div>
                  <div className="flex gap-3">
                    <button
                      onClick={() => play({
                        id: episode.id,
                        title: episode.title,
                        subtitle: episode.hostName,
                        url: episode.audioUrl,
                        imageUrl: episode.imageAsset,
                        isLiveStream: false,
                        category: 'بودكاست',
                      })}
                      className={`flex items-center gap-2 px-6 py-3 rounded-xl font-medium text-sm transition-all ${
                        isCurrent && isPlaying
                          ? 'bg-red-500 text-white'
                          : 'alwan-gradient text-white hover:opacity-90'
                      }`}
                    >
                      {isCurrent && isPlaying ? '⏸ إيقاف مؤقت' : '▶ تشغيل'}
                    </button>
                    <button className="flex items-center gap-2 px-6 py-3 rounded-xl bg-gray-100 text-gray-700 hover:bg-gray-200 text-sm transition-colors">
                      ⭐ إضافة للمفضلة
                    </button>
                    <button className="flex items-center gap-2 px-4 py-3 rounded-xl bg-gray-100 text-gray-700 hover:bg-gray-200 text-sm transition-colors">
                      📤 مشاركة
                    </button>
                  </div>
                </div>
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}
