'use client';

import Link from 'next/link';
import { useAudioStore } from '@/lib/audioStore';
import { podcastEpisodes, formatDuration, formatDate } from '@/data/podcasts';

export default function PodcastsSection() {
  const { play, currentTrack, isPlaying } = useAudioStore();
  const episodes = podcastEpisodes.slice(0, 3);

  return (
    <section>
      <div className="flex items-center justify-between mb-6">
        <div>
          <h2 className="text-2xl font-bold text-gray-900">أحدث حلقات البودكاست</h2>
          <p className="text-sm text-gray-500 mt-1">حلقات مختارة من أفضل البرامج</p>
        </div>
        <Link href="/podcasts" className="text-sm font-medium text-alwan-primary hover:text-alwan-secondary">
          عرض الكل ←
        </Link>
      </div>

      <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-4 sm:gap-6">
        {episodes.map((episode) => {
          const isCurrent = currentTrack?.id === episode.id;
          return (
            <div
              key={episode.id}
              className="group bg-white rounded-2xl overflow-hidden border border-gray-100 hover:border-transparent hover:shadow-xl card-hover"
            >
              <div className="relative h-36 overflow-hidden">
                <img
                  src={episode.imageAsset}
                  alt={episode.title}
                  className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500"
                />
                <div className="absolute inset-0 bg-gradient-to-t from-black/50 to-transparent" />
                <div className="absolute top-3 left-3 px-2 py-1 bg-black/40 backdrop-blur-sm rounded-lg text-white text-xs">
                  {formatDuration(episode.duration)}
                </div>
                {episode.isFeatured && (
                  <div className="absolute top-3 right-3 px-2 py-1 bg-amber-500 rounded-lg text-white text-xs font-bold">
                    مميز
                  </div>
                )}
              </div>

              <div className="p-4">
                <div className="text-xs text-alwan-primary font-medium mb-1">{episode.seriesName}</div>
                <h3 className="font-bold text-gray-900 truncate mb-1 group-hover:text-alwan-primary transition-colors">
                  {episode.title}
                </h3>
                <p className="text-sm text-gray-500 truncate">{episode.hostName}</p>
                <div className="flex items-center justify-between mt-3 pt-3 border-t border-gray-50">
                  <span className="text-xs text-gray-400">{formatDate(episode.publishedAt)}</span>
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
                    className={`w-8 h-8 rounded-full flex items-center justify-center transition-all ${
                      isCurrent && isPlaying
                        ? 'bg-red-500 text-white'
                        : 'bg-alwan-primary/10 text-alwan-primary hover:bg-alwan-primary hover:text-white'
                    }`}
                  >
                    {isCurrent && isPlaying ? (
                      <svg className="w-3.5 h-3.5" fill="currentColor" viewBox="0 0 24 24">
                        <rect x="6" y="4" width="4" height="16" rx="1" />
                        <rect x="14" y="4" width="4" height="16" rx="1" />
                      </svg>
                    ) : (
                      <svg className="w-3.5 h-3.5" fill="currentColor" viewBox="0 0 24 24">
                        <path d="M8 5v14l11-7z" />
                      </svg>
                    )}
                  </button>
                </div>
              </div>
            </div>
          );
        })}
      </div>
    </section>
  );
}
