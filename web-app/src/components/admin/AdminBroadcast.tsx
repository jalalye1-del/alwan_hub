'use client';

export default function AdminBroadcast() {
  return (
    <div>
      <h1 className="text-2xl font-bold text-gray-900 mb-2">إدارة البث</h1>
      <p className="text-sm text-gray-500 mb-6">إعدادات البث المباشر والمصادر</p>
      <div className="bg-white rounded-2xl border border-gray-100 p-6 mb-6">
        <h3 className="font-bold text-gray-900 mb-4">مصادر البث</h3>
        <div className="space-y-3">
          {[
            { name: 'إذاعة ألوان FM', url: 'https://s9.voscast.com:9617/stream', status: 'active', listeners: 12458 },
            { name: 'إذاعة دلتا', url: 'http://168.119.10.136:7057/live', status: 'active', listeners: 8920 },
            { name: 'بي بي سي عربي', url: 'https://stream.live.vc.bbcmedia.co.uk/bbc_arabic_radio', status: 'active', listeners: 28540 },
          ].map((source, i) => (
            <div key={i} className="flex items-center gap-4 p-4 bg-gray-50 rounded-xl">
              <div className={`w-3 h-3 rounded-full ${source.status === 'active' ? 'bg-green-500' : 'bg-red-500'}`} />
              <div className="flex-1">
                <div className="font-medium text-gray-900">{source.name}</div>
                <div className="text-xs text-gray-500 font-mono">{source.url}</div>
              </div>
              <div className="text-sm text-gray-500">{source.listeners.toLocaleString('ar')} مستمع</div>
              <button className="px-3 py-1.5 rounded-lg bg-alwan-primary/10 text-alwan-primary text-xs">إدارة</button>
            </div>
          ))}
        </div>
      </div>
      <div className="bg-white rounded-2xl border border-gray-100 p-6">
        <h3 className="font-bold text-gray-900 mb-4">إعدادات البث</h3>
        <div className="grid sm:grid-cols-2 gap-4">
          <div><label className="block text-sm font-medium text-gray-700 mb-1">عنوان البث الرئيسي</label><input className="w-full px-4 py-2.5 border rounded-xl text-sm" defaultValue="https://s9.voscast.com:9617/stream" /></div>
          <div><label className="block text-sm font-medium text-gray-700 mb-1">عنوان البث الاحتياطي</label><input className="w-full px-4 py-2.5 border rounded-xl text-sm" defaultValue="http://168.119.10.136:7057/live" /></div>
          <div><label className="block text-sm font-medium text-gray-700 mb-1">مهلة إعادة الاتصال (ثانية)</label><input type="number" className="w-full px-4 py-2.5 border rounded-xl text-sm" defaultValue={5} /></div>
          <div><label className="block text-sm font-medium text-gray-700 mb-1">الحد الأقصى لمحاولات إعادة الاتصال</label><input type="number" className="w-full px-4 py-2.5 border rounded-xl text-sm" defaultValue={3} /></div>
        </div>
        <button className="mt-4 px-6 py-2.5 alwan-gradient text-white rounded-xl text-sm font-medium">💾 حفظ الإعدادات</button>
      </div>
    </div>
  );
}
