// FM Station data model
export interface FmStation {
  id: string;
  name: string;
  logo: string;
  coverImage: string;
  url: string;
  frequency: string;
  isLive: boolean;
  currentProgram: string;
  country: string;
  city: string;
  language: string;
  category: string;
  type: string;
  listeners: number;
  rating: number;
  foundedYear: number;
  description: string;
  isFavorite?: boolean;
}

// FM Program data model
export interface FmProgram {
  id: string;
  title: string;
  description: string;
  presenterName: string;
  liveTime: string;
  liveEndTime: string;
  replayTimes: string[];
  imageUrl: string;
  streamUrl: string;
  accentColor: string;
  broadcastDays: number[];
  broadcastSlots: { dayLabel: string; time: string }[];
  replaySlots: { dayLabel: string; time: string }[];
  conversationTitle: string;
  isLive: boolean;
  sortOrder: number;
}

// Podcast Episode data model
export interface PodcastEpisode {
  id: string;
  title: string;
  description: string;
  hostName: string;
  seriesName: string;
  audioUrl: string;
  videoUrl: string;
  imageAsset: string;
  duration: number; // seconds
  publishedAt: string;
  listeners: number;
  isFeatured: boolean;
}

// Recording File data model
export interface RecordingFile {
  id: string;
  title: string;
  fileName: string;
  filePath: string;
  sourceType: string;
  category: string;
  folderName: string;
  programName?: string;
  imageUrl?: string;
  duration: number; // milliseconds
  fileSize: number;
  createdAt: string;
  status: 'completed' | 'recording' | 'cancelled' | 'failed';
  isFavorite: boolean;
}

// Audio Player state
export interface AudioState {
  currentTrack: AudioTrack | null;
  isPlaying: boolean;
  position: number;
  duration: number;
  volume: number;
  isRecording: boolean;
  recordingDuration: number;
}

export interface AudioTrack {
  id: string;
  title: string;
  subtitle: string;
  url: string;
  imageUrl: string;
  isLiveStream: boolean;
  presenterName?: string;
  programImage?: string;
  category: string;
}

// Lounge Category
export interface LoungeCategory {
  categoryId: string;
  title: string;
  icon: string;
  sectionTitle: string;
  trackItemLabel: string;
  itemCount: number;
  imageUrl: string;
}

// Competition / Games
export interface CompetitionProgram {
  id: string;
  title: string;
  sponsor: string;
  status: string;
  description: string;
  color: string;
}

// Advertisement types
export interface Advertisement {
  id: string;
  title: string;
  advertiserName: string;
  type: 'image' | 'video' | 'audio' | 'text' | 'promotional' | 'program' | 'episode' | 'external_link' | 'internal_link';
  imageUrl?: string;
  videoUrl?: string;
  audioUrl?: string;
  text?: string;
  linkUrl: string;
  placement: string;
  campaignId: string;
  status: 'draft' | 'active' | 'scheduled' | 'paused' | 'expired' | 'review';
  platforms: ('web' | 'android' | 'ios')[];
  startDate: string;
  endDate: string;
  priority: number;
  displayDuration: number; // seconds
}

export interface Campaign {
  id: string;
  name: string;
  advertiserName: string;
  type: string;
  description: string;
  startDate: string;
  endDate: string;
  status: 'draft' | 'active' | 'scheduled' | 'paused' | 'expired';
  priority: number;
  platforms: ('web' | 'android' | 'ios')[];
  publishMode: 'unified' | 'separate' | 'unified_custom';
  totalAds: number;
  activeAds: number;
}

// Admin User roles
export type AdminRole = 'admin' | 'ad_manager' | 'ad_editor' | 'ad_reviewer' | 'ad_publisher' | 'ad_analyst';
