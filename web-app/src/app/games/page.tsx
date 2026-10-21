import Header from '@/components/Header';
import AudioPlayer from '@/components/AudioPlayer';
import Footer from '@/components/Footer';

export const metadata = { title: 'الألعاب والمسابقات - ألوان هَب' };

export default function GamesPage() {
  return (
    <>
      <Header />
      <main className="pb-24">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
          <div className="mb-8">
            <h1 className="text-3xl font-bold text-gray-900 mb-2">الألعاب والمسابقات</h1>
            <p className="text-gray-500">شارك في المسابقات التفاعلية واربح جوائز قيّمة</p>
          </div>

          {/* Competition Programs */}
          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6 mb-12">
            {[
              { id: 'isra', title: 'برنامج إسرائيل والنصر', sponsor: 'برعاية بنك ISR', status: 'يبدأ 8:00 مساءً', desc: 'مسابقة ثقافية كبرى مع أسئلة متنوعة وجوائز قيمة.', color: 'from-indigo-500 to-purple-600', emoji: '🏆' },
              { id: 'luck', title: 'برنامج صندوق الحظ', sponsor: 'برعاية كاك بنك', status: 'يبدأ 8:00 مساءً', desc: 'افتح الصناديق الغامضة على الهواء مباشرة واكسب الجائزة.', color: 'from-purple-500 to-pink-600', emoji: '🎁' },
              { id: 'tonight', title: 'برنامج ألوان الليلة', sponsor: 'برعاية مجموعة بن هايل', status: 'قريباً', desc: 'أكبر سهرة مسابقات رمضانية متنوعة وتحديات فورية.', color: 'from-blue-500 to-indigo-600', emoji: '🌙' },
            ].map((game) => (
              <div key={game.id} className="bg-white rounded-2xl overflow-hidden border border-gray-100 hover:shadow-xl card-hover">
                <div className={`h-36 bg-gradient-to-br ${game.color} flex items-center justify-center`}>
                  <span className="text-5xl">{game.emoji}</span>
                </div>
                <div className="p-5">
                  <div className="text-xs text-gray-400 mb-1">{game.sponsor}</div>
                  <h3 className="text-lg font-bold text-gray-900 mb-1">{game.title}</h3>
                  <span className="inline-block px-2 py-0.5 bg-amber-100 text-amber-700 text-xs rounded-full mb-2">{game.status}</span>
                  <p className="text-sm text-gray-600 mb-4">{game.desc}</p>
                  <div className="flex gap-2">
                    <button className="flex-1 py-2.5 rounded-xl alwan-gradient text-white text-sm font-medium hover:opacity-90">طلب اشتراك</button>
                    <button className="px-4 py-2.5 rounded-xl bg-gray-100 text-gray-600 text-sm hover:bg-gray-200">🔔</button>
                  </div>
                </div>
              </div>
            ))}
          </div>

          {/* Quiz Challenges */}
          <h2 className="text-xl font-bold text-gray-900 mb-4">التحديات الفكرية</h2>
          <div className="grid sm:grid-cols-2 gap-4">
            {[
              { id: 'hg', title: 'تحدي التاريخ والجغرافيا', cat: 'التاريخ والجغرافيا', emoji: '🌍', color: 'bg-emerald-500' },
              { id: 'sn', title: 'تحدي العلوم والطبيعة', cat: 'العلوم والطبيعة', emoji: '🔬', color: 'bg-blue-500' },
              { id: 'rl', title: 'تحدي الدين واللغات', cat: 'الدين واللغات', emoji: '📖', color: 'bg-amber-500' },
              { id: 'as', title: 'تحدي الفنون والرياضة', cat: 'الفنون والرياضة', emoji: '⚽', color: 'bg-purple-500' },
            ].map((challenge) => (
              <div key={challenge.id} className="flex items-center gap-4 bg-white rounded-2xl p-5 border border-gray-100 hover:shadow-lg card-hover cursor-pointer">
                <div className={`w-14 h-14 rounded-xl ${challenge.color} flex items-center justify-center text-2xl flex-shrink-0`}>
                  {challenge.emoji}
                </div>
                <div className="flex-1 min-w-0">
                  <h3 className="font-bold text-gray-900">{challenge.title}</h3>
                  <p className="text-sm text-gray-500">{challenge.cat}</p>
                </div>
                <button className="px-4 py-2 rounded-xl bg-alwan-primary/10 text-alwan-primary text-sm font-medium hover:bg-alwan-primary hover:text-white transition-all">
                  ابدأ التحدي
                </button>
              </div>
            ))}
          </div>
        </div>
      </main>
      <Footer />
      <AudioPlayer />
    </>
  );
}
