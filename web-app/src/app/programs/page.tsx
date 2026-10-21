import Header from '@/components/Header';
import AudioPlayer from '@/components/AudioPlayer';
import ProgramsPageContent from '@/components/pages/ProgramsPageContent';
import Footer from '@/components/Footer';

export const metadata = { title: 'البرامج الإذاعية - ألوان هَب' };

export default function ProgramsPage() {
  return (
    <>
      <Header />
      <main className="pb-24">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
          <ProgramsPageContent />
        </div>
      </main>
      <Footer />
      <AudioPlayer />
    </>
  );
}
