import Header from '@/components/Header';
import AudioPlayer from '@/components/AudioPlayer';
import StationsPageContent from '@/components/pages/StationsPageContent';
import Footer from '@/components/Footer';

export const metadata = { title: 'الإذاعات - ألوان هَب' };

export default function StationsPage() {
  return (
    <>
      <Header />
      <main className="pb-24">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
          <StationsPageContent />
        </div>
      </main>
      <Footer />
      <AudioPlayer />
    </>
  );
}
