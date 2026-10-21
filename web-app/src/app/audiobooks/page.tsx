import Header from '@/components/Header';
import AudioPlayer from '@/components/AudioPlayer';
import Footer from '@/components/Footer';

export const metadata = { title: 'الكتب الصوتية - ألوان هَب' };

const audiobooks = [
  { id: '1', title: 'الأيام', author: 'طه حسين', narrator: 'محمد عبدالوهاب', duration: '8 ساعات', image: 'https://images.unsplash.com/photo-1544947950-fa07a98d237f?auto=format&fit=crop&w=400&q=80', category: 'أدب' },
  { id: '2', title: 'في قلب اليمن', author: 'أحمد الشامي', narrator: 'عبدالرحمن الأرياني', duration: '5 ساعات', image: 'https://images.unsplash.com/photo-1512820790803-83ca734da794?auto=format&fit=crop&w=400&q=80', category: 'تاريخ' },
  { id: '3', title: 'مقدمة ابن خلدون', author: 'ابن خلدون', narrator: 'خالد النبوي', duration: '12 ساعة', image: 'https://images.unsplash.com/photo-1589998059171-988d887df646?auto=format&fit=crop&w=400&q=80', category: 'فكر' },
  { id: '4', title: 'ألف ليلة وليلة', author: 'مجهول', narrator: 'غسان مطر', duration: '15 ساعة', image: 'https://images.unsplash.com/photo-1524578271613-d550eacf6090?auto=format&fit=crop&w=400&q=80', category: 'تراث' },
  { id: '5', title: 'الأسود يليق بحليمة', author: 'أحلام مستغانمي', narrator: 'سارة الخولاني', duration: '6 ساعات', image: 'https://images.unsplash.com/photo-1476275466078-4007374efbbe?auto=format&fit=crop&w=400&q=80', category: 'رواية' },
  { id: '6', title: 'ساق البامبو', author: 'سعود السنعوسي', narrator: 'فارس الحازمي', duration: '7 ساعات', image: 'https://images.unsplash.com/photo-1543002588-bfa74002ed7e?auto=format&fit=crop&w=400&q=80', category: 'رواية' },
];

export default function AudiobooksPage() {
  return (
    <>
      <Header />
      <main className="pb-24">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
          <div className="mb-8">
            <h1 className="text-3xl font-bold text-gray-900 mb-2">الكتب الصوتية</h1>
            <p className="text-gray-500">مكتبة متنوعة من الكتب الصوتية بأصوات نخبة من الرواة</p>
          </div>
          <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 xl:grid-cols-6 gap-4">
            {audiobooks.map((book) => (
              <div key={book.id} className="group bg-white rounded-2xl overflow-hidden border border-gray-100 hover:shadow-xl card-hover">
                <div className="relative aspect-[3/4] overflow-hidden">
                  <img src={book.image} alt={book.title} className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500" />
                  <div className="absolute inset-0 bg-black/0 group-hover:bg-black/40 transition-colors flex items-center justify-center">
                    <button className="w-14 h-14 rounded-full alwan-gradient text-white flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity shadow-xl">
                      <svg className="w-6 h-6 mr-[-2px]" fill="currentColor" viewBox="0 0 24 24"><path d="M8 5v14l11-7z" /></svg>
                    </button>
                  </div>
                  <span className="absolute top-2 right-2 px-2 py-1 bg-black/40 backdrop-blur-sm rounded text-white text-[10px]">{book.category}</span>
                </div>
                <div className="p-3">
                  <h3 className="font-bold text-sm text-gray-900 truncate">{book.title}</h3>
                  <p className="text-xs text-gray-500 truncate mt-0.5">{book.author}</p>
                  <div className="flex items-center justify-between mt-2 text-[10px] text-gray-400">
                    <span>🎧 {book.narrator}</span>
                    <span>⏱ {book.duration}</span>
                  </div>
                </div>
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
