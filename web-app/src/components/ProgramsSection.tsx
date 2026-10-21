'use client';

import Link from 'next/link';
import { useAudioStore } from '@/lib/audioStore';
import { fmPrograms } from '@/data/programs';

export default function ProgramsSection() {
  const { play, currentTrack, isPlaying } = useAudioStore();

  const handlePlayProgram = (program: typeof fmPrograms[0]) => {
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
    <section id="programs">
      <div className="flex items-center justify-between mb-6">
        <div>
          <h2 className="text-2xl font-bold text-gray-900">البرامج الإذاعية</h2>
          <p className="text-sm text-gray-500 mt-1">برامج حصرية مع أبرز المقدمين</p>
        </div>
        <Link
          href="/programs"
          className="text-sm font-medium text-alwan-primary hover:text-alwan-secondary transition-colors"
        >
          عرض الكل ←
        </Link>
      </div>

      <div className="grid sm:grid-cols-2 lg:grid-cols-4 gap-4 sm:gap-6">
        {fmPrograms.map((program) => {
          const isCurrentProgram = currentTrack?.id === program.id;
          return (
            <div
              key={program.id}
              className="group bg-white rounded-2xl overflow-hidden border border-gray-100 hover:border-transparent hover:shadow-xl card-hover"
            >
              {/* Image */}
              <div className="relative h-40 overflow-hidden">
                <img
                  src={program.imageUrl}
                  alt={program.title}
                  className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500"
                />
                <div className="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent" />
                {program.isLive && (
                  <div className="absolute top-3 right-3 live-indicator">
                    مباشر
                  </div>
                )}
                <div className="absolute bottom-3 right-3 left-3">
                  <h3 className="text-white font-bold text-lg truncate">{program.title}</h3>
                  <p className="text-white/80 text-sm truncate">{program.presenterName}</p>
                </div>
              </div>

              {/* Content */}
              <div className="p-4">
                <p className="text-sm text-gray-600 line-clamp-2 mb-3">{program.description}</p>
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-2 text-xs text-gray-500">
                    <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                    </svg>
                    {program.liveTime} - {program.liveEndTime}
                  </div>
                  <button
                    onClick={() => handlePlayProgram(program)}
                    className={`w-9 h-9 rounded-full flex items-center justify-center transition-all ${
                      isCurrentProgram && isPlaying
                        ? 'bg-red-500 text-white'
                        : 'bg-alwan-primary/10 text-alwan-primary hover:bg-alwan-primary hover:text-white'
                    }`}
                  >
                    {isCurrentProgram && isPlaying ? (
                      <svg className="w-4 h-4" fill="currentColor" viewBox="0 0 24 24">
                        <rect x="6" y="4" width="4" height="16" rx="1" />
                        <rect x="14" y="4" width="4" height="16" rx="1" />
                      </svg>
                    ) : (
                      <svg className="w-4 h-4" fill="currentColor" viewBox="0 0 24 24">
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
