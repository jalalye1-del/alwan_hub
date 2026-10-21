import Header from '@/components/Header';
import AudioPlayer from '@/components/AudioPlayer';
import AdminPanel from '@/components/admin/AdminPanel';

export const metadata = { title: 'لوحة التحكم - ألوان هَب' };

export default function AdminPage() {
  return (
    <>
      <Header />
      <main className="pb-24">
        <AdminPanel />
      </main>
      <AudioPlayer />
    </>
  );
}
