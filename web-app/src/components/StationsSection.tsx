'use client';

import Link from 'next/link';
import { fmStations } from '@/data/stations';
import { useAudioStore } from '@/lib/audioStore';

export default function StationsSection() {
  const { play, currentTrack, isPlaying } = useAudioStore();
  const liveStations = fmStations.filter(s => s.url && s.isLive).slice(0, 6);

  return (
    <section>
      <div className="flex items-center justify-between mb-6">
        <div>
          <h2 className="text-2xl font-bold text-gray-900">الإذاعات المباشرة</h2>
          <p className="text-sm text-gray-500 mt-1">استمع لأفضل الإذاعات العربية والعالمية</p>
        </div>
        <Link href="/stations" className="text-sm font-medium text-alwan-primary hover:text-alwan-secondary">
          عرض الكل ←
        </Link>
      </div>

      <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-6 gap-4">
        {liveStations.map((station) => {
          const isCurrentStation = currentTrack?.id === station.id;
          return (
            <button
              key={station.id}
              onClick={() => play({
                id: station.id,
                title: station.name,
                subtitle: station.currentProgram || station.frequency,
                url: station.url,
                imageUrl: station.logo,
                isLiveStream: true,
                presenterName: station.currentProgram,
                category: station.type,
              })}
              className={`group relative bg-white rounded-2xl p-4 border transition-all hover:shadow-xl card-hover ${
                isCurrentStation && isPlaying ? 'border-alwan-primary ring-2 ring-alwan-primary/20' : 'border-gray-100 hover:border-transparent'
              }`}
            >
              <div className="w-16 h-16 mx-auto rounded-full bg-gradient-to-br from-gray-50 to-gray-100 overflow-hidden mb-3">
                <div className="w-full h-full flex items-center justify-center text-2xl">
                  📻
                </div>
              </div>
              <h3 className="text-sm font-bold text-gray-900 text-center truncate group-hover:text-alwan-primary transition-colors">
                {station.name}
              </h3>
              <p className="text-xs text-gray-500 text-center mt-1 truncate">
                {station.country}
              </p>
              {isCurrentStation && isPlaying && (
                <div className="absolute top-2 left-2 w-3 h-3 bg-green-500 rounded-full animate-pulse" />
              )}
              {station.isLive && (
                <div className="absolute top-2 right-2">
                  <span className="w-2 h-2 bg-red-500 rounded-full animate-pulse" />
                </div>
              )}
            </button>
          );
        })}
      </div>
    </section>
  );
}
