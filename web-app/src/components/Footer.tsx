import Link from 'next/link';

export default function Footer() {
  return (
    <footer className="bg-gray-900 text-white pt-16 pb-28">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="grid md:grid-cols-4 gap-8 mb-12">
          {/* Brand */}
          <div className="md:col-span-1">
            <div className="flex items-center gap-3 mb-4">
              <div className="w-12 h-12 rounded-xl alwan-gradient flex items-center justify-center">
                <span className="text-white font-bold text-xl">أ</span>
              </div>
              <div>
                <h3 className="text-lg font-bold">ألوان هَب</h3>
                <p className="text-xs text-gray-400">ألوان تنبض بالحياة</p>
              </div>
            </div>
            <p className="text-sm text-gray-400 leading-relaxed">
              منصة إعلامية صوتية متكاملة تقدم البث المباشر والبرامج والبودكاست والكتب الصوتية والمحتوى الترفيهي.
            </p>
          </div>

          {/* Links */}
          <div>
            <h4 className="font-bold mb-4 text-amber-400">روابط سريعة</h4>
            <ul className="space-y-2">
              {['الرئيسية', 'البرامج', 'الإذاعات', 'البودكاست', 'الاستراحة'].map((item) => (
                <li key={item}>
                  <Link href="#" className="text-sm text-gray-400 hover:text-white transition-colors">
                    {item}
                  </Link>
                </li>
              ))}
            </ul>
          </div>

          <div>
            <h4 className="font-bold mb-4 text-amber-400">خدماتنا</h4>
            <ul className="space-y-2">
              {['الكتب الصوتية', 'الألعاب', 'الدردشة', 'التسجيلات', 'المفضلة'].map((item) => (
                <li key={item}>
                  <Link href="#" className="text-sm text-gray-400 hover:text-white transition-colors">
                    {item}
                  </Link>
                </li>
              ))}
            </ul>
          </div>

          <div>
            <h4 className="font-bold mb-4 text-amber-400">تواصل معنا</h4>
            <ul className="space-y-3">
              <li className="flex items-center gap-2 text-sm text-gray-400">
                <span>📧</span> info@alwan.fm
              </li>
              <li className="flex items-center gap-2 text-sm text-gray-400">
                <span>📱</span> +967 772 277 800
              </li>
              <li className="flex items-center gap-2 text-sm text-gray-400">
                <span>📍</span> صنعاء، اليمن
              </li>
            </ul>
            <div className="flex gap-3 mt-4">
              {['𝕏', 'f', 'in', '▶'].map((icon, i) => (
                <button
                  key={i}
                  className="w-9 h-9 rounded-lg bg-white/10 flex items-center justify-center text-sm hover:bg-white/20 transition-colors"
                >
                  {icon}
                </button>
              ))}
            </div>
          </div>
        </div>

        <div className="border-t border-white/10 pt-8 flex flex-col sm:flex-row items-center justify-between gap-4">
          <p className="text-sm text-gray-400">
            © 2026 ألوان هَب. جميع الحقوق محفوظة.
          </p>
          <p className="text-sm text-gray-500">
            إذاعة ألوان FM — ألوان تنبض بالحياة
          </p>
        </div>
      </div>
    </footer>
  );
}
