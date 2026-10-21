import { PodcastEpisode } from '@/types';

export const podcastEpisodes: PodcastEpisode[] = [
  {
    id: 'podcast-consumer-behaviour',
    title: 'فهم سلوك المستهلك وصدمات العرض والطلب',
    description: 'قراءة مبسطة في قرارات الشراء وكيف تغيّر الظروف اليومية سلوك الأسواق والمجتمع.',
    hostName: 'أ. منير الشيباني',
    seriesName: 'اقتصاد ببساطة',
    audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
    videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
    imageAsset: 'https://images.unsplash.com/photo-1590602847861-f357a9332bbc?auto=format&fit=crop&w=500&q=85',
    duration: 910,
    publishedAt: '2026-08-06T09:00:00.000Z',
    listeners: 2400,
    isFeatured: true,
  },
  {
    id: 'podcast-digital-parenting',
    title: 'تربية الأطفال في العصر الرقمي',
    description: 'دليل عملي للأسرة لفهم التطبيقات والألعاب وبناء عادات رقمية أكثر توازنًا.',
    hostName: 'د. سارة العلواني',
    seriesName: 'مساحة أسرة',
    audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
    videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
    imageAsset: 'https://images.unsplash.com/photo-1544717297-fa95b6ee9643?auto=format&fit=crop&w=500&q=85',
    duration: 1125,
    publishedAt: '2026-08-03T12:00:00.000Z',
    listeners: 1850,
    isFeatured: false,
  },
  {
    id: 'podcast-yemeni-creativity',
    title: 'كيف يصنع الشباب اليمني فرصته؟',
    description: 'حوار ملهم حول تحويل الأفكار الصغيرة إلى مشاريع مؤثرة وقابلة للنمو.',
    hostName: 'شروق أحمد',
    seriesName: 'حكاية نجاح',
    audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
    videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
    imageAsset: 'https://images.unsplash.com/photo-1531545514256-b1400bc00f31?auto=format&fit=crop&w=500&q=85',
    duration: 1260,
    publishedAt: '2026-07-30T15:30:00.000Z',
    listeners: 3120,
    isFeatured: false,
  },
];

export const getFeaturedPodcast = (): PodcastEpisode | undefined => {
  return podcastEpisodes.find(ep => ep.isFeatured);
};

export const formatDuration = (seconds: number): string => {
  const mins = Math.floor(seconds / 60);
  const secs = seconds % 60;
  return `${mins}:${secs.toString().padStart(2, '0')}`;
};

export const formatDate = (dateStr: string): string => {
  const date = new Date(dateStr);
  return date.toLocaleDateString('ar-YE', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
  });
};
