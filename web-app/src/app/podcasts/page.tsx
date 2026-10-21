import Header from '@/components/Header';
import AudioPlayer from '@/components/AudioPlayer';
import PodcastsPageContent from '@/components/pages/PodcastsPageContent';
import Footer from '@/components/Footer';

export const metadata = { title: 'البودكاست - ألوان هَب' };

export default function PodcastsPage() {
  return (
    <>
      <Header />
      <main className="pb-24">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
          <PodcastsPageContent />
        </div>
      </main>
      <Footer />
      <AudioPlayer />
    </>
  );
}
