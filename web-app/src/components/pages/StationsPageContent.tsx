'use client';

import { fmStations } from '@/data/stations';
import { useAudioStore } from '@/lib/audioStore';
import { useState } from 'react';

const types = ['الكل', 'إذاعات FM', 'إذاعات عربية', 'World Radio'];

export default function StationsPageContent() {
  const { play, currentTrack, isPlaying } = useAudioStore();
  const [activeType, setActiveType] = useState('الكل');
  const [search, setSearch] = useState('');

  const filteredStations = fmStations.filter(s => {
    const matchType = activeType === 'الكل' || s.type === activeType;
    const matchSearch = !search || s.name.includes(search) || s.country.includes(search);
    return matchType && matchSearch;
  });

  return (
    <div>
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-gray-900 mb-2">الإذاعات</h1>
        <p className="text-gray-500">استمع لأكثر من {fmStations.length} إذاعة مباشرة</p>
      </div>

      {/* Search and Filter */}
      <div className="flex flex-col sm:flex-row gap-4 mb-6">
        <div className="relative flex-1">
          <input
            type="text"
            placeholder="ابحث عن إذاعة..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="w-full px-4 py-3 pr-12 bg-white border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-alwan-primary/20 focus:border-alwan-primary"
          />
          <svg className="absolute right-4 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
          </svg>
        </div>
        <div className="flex gap-2 overflow-x-auto pb-2">
          {types.map((type) => (
            <button
              key={type}
              onClick={() => setActiveType(type)}
              className={`px-4 py-3 rounded-xl text-sm font-medium whitespace-nowrap transition-all ${
                activeType === type
                  ? 'alwan-gradient text-white shadow-lg'
                  : 'bg-white text-gray-600 border border-gray-200 hover:border-alwan-primary/30'
              }`}
            >
              {type}
            </button>
          ))}
        </div>
      </div>

      {/* Stations Grid */}
      <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-4">
        {filteredStations.map((station) => {
          const isCurrent = currentTrack?.id === station.id;
          return (
            <div
              key={station.id}
              onClick={() => station.url && play({
                id: station.id,
                title: station.name,
                subtitle: station.currentProgram || station.frequency,
                url: station.url,
                imageUrl: station.logo,
                isLiveStream: true,
                presenterName: station.currentProgram,
                category: station.type,
              })}
              className={`group bg-white rounded-2xl p-5 border cursor-pointer transition-all hover:shadow-xl card-hover ${
                isCurrent && isPlaying ? 'border-alwan-primary ring-2 ring-alwan-primary/20' : 'border-gray-100 hover:border-transparent'
              }`}
            >
              <div className="relative w-20 h-20 mx-auto mb-4 rounded-full bg-gradient-to-br from-gray-50 to-gray-100 overflow-hidden">
                <div className="w-full h-full flex items-center justify-center text-3xl">📻</div>
                {isCurrent && isPlaying && (
                  <div className="absolute inset-0 bg-alwan-primary/10 flex items-center justify-center">
                    <div className="flex gap-0.5">
                      {[...Array(4)].map((_, i) => (
                        <div key={i} className="w-1 bg-alwan-primary rounded-full animate-pulse" style={{ height: `${12 + Math.random() * 12}px`, animationDelay: `${i * 0.15}s` }} />
                      ))}
                    </div>
                  </div>
                )}
              </div>
              <h3 className="text-sm font-bold text-gray-900 text-center truncate group-hover:text-alwan-primary">{station.name}</h3>
              <p className="text-xs text-gray-500 text-center mt-1">{station.country} • {station.frequency}</p>
              <div className="flex items-center justify-center gap-3 mt-3">
                <div className="flex items-center gap-1 text-xs text-gray-400">
                  <span>⭐</span> {station.rating}
                </div>
                <div className="flex items-center gap-1 text-xs text-gray-400">
                  <span>👥</span> {(station.listeners / 1000).toFixed(1)}K
                </div>
              </div>
              {station.isLive && (
                <div className="flex justify-center mt-2">
                  <span className="text-[10px] text-red-500 font-medium flex items-center gap-1">
                    <span className="w-1.5 h-1.5 bg-red-500 rounded-full animate-pulse" /> مباشر
                  </span>
                </div>
              )}
            </div>
          );
        })}
      </div>
    </div>
  );
}
