import { create } from 'zustand';
import { AudioTrack } from '@/types';

interface AudioPlayerState {
  currentTrack: AudioTrack | null;
  isPlaying: boolean;
  position: number;
  duration: number;
  volume: number;
  isRecording: boolean;
  recordingDuration: number;
  isLoading: boolean;
  error: string | null;
  isInitialized: boolean;

  // Actions
  initAudio: () => void;
  play: (track: AudioTrack) => void;
  togglePlayPause: () => void;
  stop: () => void;
  setVolume: (vol: number) => void;
  setPosition: (pos: number) => void;
  setDuration: (dur: number) => void;
  setLoading: (loading: boolean) => void;
  setError: (error: string | null) => void;
  startRecording: () => void;
  stopRecording: () => void;
}

let audioElement: HTMLAudioElement | null = null;
let isAudioInitialized = false;

const getAudioElement = (): HTMLAudioElement | null => {
  if (typeof window === 'undefined') return null;
  if (!audioElement) {
    audioElement = new Audio();
    audioElement.crossOrigin = 'anonymous';
  }
  return audioElement;
};

export const useAudioStore = create<AudioPlayerState>((set, get) => {
  let recordingInterval: ReturnType<typeof setInterval> | null = null;

  return {
    currentTrack: null,
    isPlaying: false,
    position: 0,
    duration: 0,
    volume: 0.8,
    isRecording: false,
    recordingDuration: 0,
    isLoading: false,
    error: null,
    isInitialized: false,

    initAudio: () => {
      if (typeof window === 'undefined' || isAudioInitialized) return;
      
      const audio = getAudioElement();
      if (!audio) return;

      isAudioInitialized = true;

      audio.addEventListener('play', () => set({ isPlaying: true, isLoading: false }));
      audio.addEventListener('pause', () => set({ isPlaying: false }));
      audio.addEventListener('ended', () => set({ isPlaying: false }));
      audio.addEventListener('timeupdate', () => set({ position: audio.currentTime }));
      audio.addEventListener('durationchange', () => set({ duration: audio.duration || 0 }));
      audio.addEventListener('error', () => set({ error: 'خطأ في تشغيل الصوت', isLoading: false }));
      audio.addEventListener('waiting', () => set({ isLoading: true }));
      audio.addEventListener('canplay', () => set({ isLoading: false }));

      set({ isInitialized: true });
    },

    play: (track: AudioTrack) => {
      if (typeof window === 'undefined') return;
      
      const state = get();
      if (!state.isInitialized) {
        state.initAudio();
      }

      const audio = getAudioElement();
      if (!audio) return;

      audio.src = track.url;
      audio.volume = get().volume;
      audio.play().catch(() => set({ error: 'تعذر تشغيل البث' }));
      set({
        currentTrack: track,
        isPlaying: true,
        isLoading: true,
        error: null,
      });
    },

    togglePlayPause: () => {
      if (typeof window === 'undefined') return;
      
      const audio = getAudioElement();
      if (!audio) return;

      if (get().isPlaying) {
        audio.pause();
      } else {
        audio.play().catch(() => set({ error: 'تعذر تشغيل البث' }));
      }
    },

    stop: () => {
      if (typeof window === 'undefined') return;
      
      const audio = getAudioElement();
      if (!audio) return;
      
      audio.pause();
      audio.src = '';
      set({ isPlaying: false, currentTrack: null, position: 0, duration: 0 });
    },

    setVolume: (vol: number) => {
      if (typeof window === 'undefined') return;
      
      const audio = getAudioElement();
      if (!audio) return;
      
      const clamped = Math.max(0, Math.min(1, vol));
      audio.volume = clamped;
      set({ volume: clamped });
    },

    setPosition: (pos: number) => {
      if (typeof window === 'undefined') return;
      
      const audio = getAudioElement();
      if (!audio) return;
      
      audio.currentTime = pos;
      set({ position: pos });
    },

    setDuration: (dur: number) => set({ duration: dur }),
    setLoading: (loading: boolean) => set({ isLoading: loading }),
    setError: (error: string | null) => set({ error }),

    startRecording: () => {
      set({ isRecording: true, recordingDuration: 0 });
      recordingInterval = setInterval(() => {
        set(state => ({ recordingDuration: state.recordingDuration + 1 }));
      }, 1000);
    },

    stopRecording: () => {
      if (recordingInterval) {
        clearInterval(recordingInterval);
        recordingInterval = null;
      }
      set({ isRecording: false });
    },
  };
});
