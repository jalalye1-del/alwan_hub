import { FmProgram } from '@/types';

const STREAM_URL = 'https://s9.voscast.com:9617/stream';

const dayLabels = ['السبت', 'الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة'];

export const fmPrograms: FmProgram[] = [
  {
    id: 'alwan-podcast',
    title: 'بودكاست ألوان',
    description: 'حوارات ملهمة مع ضيوف من مختلف المجالات لمشاركة الأفكار والخبرات المهمة.',
    presenterName: 'أفنان خالد',
    liveTime: '01:00 PM',
    liveEndTime: '02:00 PM',
    replayTimes: ['10:30 PM', '03:30 AM'],
    imageUrl: 'https://images.unsplash.com/photo-1590602847861-f357a9332bbc?auto=format&fit=crop&w=500&q=85',
    streamUrl: STREAM_URL,
    accentColor: '#4A35E8',
    broadcastDays: [0, 2, 5],
    broadcastSlots: [
      { dayLabel: 'السبت', time: '01:00 PM' },
      { dayLabel: 'الإثنين', time: '01:00 PM' },
      { dayLabel: 'الجمعة', time: '01:00 PM' },
    ],
    replaySlots: [
      { dayLabel: 'الأحد', time: '10:30 PM' },
      { dayLabel: 'الثلاثاء', time: '10:30 PM' },
    ],
    conversationTitle: 'حلقة اليوم: مساحة الأفكار',
    isLive: true,
    sortOrder: 0,
  },
  {
    id: 'alwan-doctor',
    title: 'طبيب ألوان',
    description: 'نصائح طبية موثوقة وأجوبة وإرشادات مع نخبة من الأطباء والمتخصصين.',
    presenterName: 'د. مرام البعداني',
    liveTime: '04:00 PM',
    liveEndTime: '05:00 PM',
    replayTimes: ['01:00 AM', '06:00 AM'],
    imageUrl: 'https://images.unsplash.com/photo-1505751172876-fa1923c5c528?auto=format&fit=crop&w=500&q=85',
    streamUrl: STREAM_URL,
    accentColor: '#3159D9',
    broadcastDays: [1, 4],
    broadcastSlots: [
      { dayLabel: 'الأحد', time: '04:00 PM' },
      { dayLabel: 'الخميس', time: '04:00 PM' },
    ],
    replaySlots: [
      { dayLabel: 'الإثنين', time: '01:00 AM' },
      { dayLabel: 'الجمعة', time: '06:00 AM' },
    ],
    conversationTitle: 'استشارات طبية مباشرة',
    isLive: false,
    sortOrder: 1,
  },
  {
    id: 'poetry-and-nostalgia',
    title: 'شعر وحنين',
    description: 'أجمل القصائد والأغاني المختارة من تراثنا العربي الأصيل بصوت إذاعات مميزة.',
    presenterName: 'نزار القدسي',
    liveTime: '07:00 PM',
    liveEndTime: '08:00 PM',
    replayTimes: ['04:00 AM', '11:00 AM'],
    imageUrl: 'https://images.unsplash.com/photo-1455390582262-044cdead277a?auto=format&fit=crop&w=500&q=85',
    streamUrl: STREAM_URL,
    accentColor: '#C77A18',
    broadcastDays: [2, 5],
    broadcastSlots: [
      { dayLabel: 'الإثنين', time: '07:00 PM' },
      { dayLabel: 'الجمعة', time: '07:00 PM' },
    ],
    replaySlots: [
      { dayLabel: 'الثلاثاء', time: '04:00 AM' },
      { dayLabel: 'السبت', time: '11:00 AM' },
    ],
    conversationTitle: 'مختارات شعرية',
    isLive: false,
    sortOrder: 2,
  },
  {
    id: 'good-sermon',
    title: 'موعظة حسنة',
    description: 'خواطر إيمانية وقيم نبيلة من القرآن والسنة في حياتنا اليومية.',
    presenterName: 'د. عبدالرحمن الجرموزي',
    liveTime: '09:00 PM',
    liveEndTime: '10:00 PM',
    replayTimes: ['06:00 AM', '02:00 PM'],
    imageUrl: 'https://images.unsplash.com/photo-1609599006353-e629aaabfeae?auto=format&fit=crop&w=500&q=85',
    streamUrl: STREAM_URL,
    accentColor: '#0C8E83',
    broadcastDays: [3],
    broadcastSlots: [
      { dayLabel: 'الثلاثاء', time: '09:00 PM' },
    ],
    replaySlots: [
      { dayLabel: 'الأربعاء', time: '06:00 AM' },
      { dayLabel: 'الخميس', time: '02:00 PM' },
    ],
    conversationTitle: 'رسالة اليوم',
    isLive: false,
    sortOrder: 3,
  },
];

export const getScheduleForDay = (dayIndex: number) => {
  return fmPrograms.filter(p => p.broadcastDays.includes(dayIndex));
};

export const getCurrentProgram = (): FmProgram | null => {
  const now = new Date();
  const day = now.getDay();
  const dayIndex = day === 6 ? 0 : day + 1; // Convert JS Sunday=0 to Saturday=0
  const currentHour = now.getHours();
  const currentMinute = now.getMinutes();

  for (const program of fmPrograms) {
    if (program.broadcastDays.includes(dayIndex)) {
      const [hours] = program.liveTime.split(':').map(Number);
      const [endHours] = program.liveEndTime.split(':').map(Number);
      if (currentHour >= hours && currentHour < endHours) {
        return program;
      }
    }
  }
  return null;
};

export const getNextProgram = (): FmProgram | null => {
  const now = new Date();
  const day = now.getDay();
  const dayIndex = day === 6 ? 0 : day + 1;
  const currentHour = now.getHours();

  let nextProgram: FmProgram | null = null;
  let minDiff = Infinity;

  for (const program of fmPrograms) {
    const [hours] = program.liveTime.split(':').map(Number);
    let diff = hours - currentHour;
    if (diff < 0) diff += 24;
    if (diff < minDiff && diff > 0) {
      minDiff = diff;
      nextProgram = program;
    }
  }

  return nextProgram;
};

export { dayLabels };
