'use client';

export default function AdminSettings() {
  return (
    <div>
      <h1 className="text-2xl font-bold text-gray-900 mb-2">الإعدادات العامة</h1>
      <p className="text-sm text-gray-500 mb-6">إعدادات المنصة والهوية والتطبيق</p>
      <div className="space-y-6">
        <div className="bg-white rounded-2xl border border-gray-100 p-6">
          <h3 className="font-bold text-gray-900 mb-4">هوية المنصة</h3>
          <div className="grid sm:grid-cols-2 gap-4">
            <div><label className="block text-sm font-medium text-gray-700 mb-1">اسم المنصة</label><input className="w-full px-4 py-2.5 border rounded-xl text-sm" defaultValue="ألوان هَب" /></div>
            <div><label className="block text-sm font-medium text-gray-700 mb-1">الشعار النصي</label><input className="w-full px-4 py-2.5 border rounded-xl text-sm" defaultValue="ألوان تنبض بالحياة" /></div>
            <div><label className="block text-sm font-medium text-gray-700 mb-1">البريد الإلكتروني</label><input className="w-full px-4 py-2.5 border rounded-xl text-sm" defaultValue="info@alwan.fm" /></div>
            <div><label className="block text-sm font-medium text-gray-700 mb-1">رقم التواصل</label><input className="w-full px-4 py-2.5 border rounded-xl text-sm" defaultValue="+967 772 277 800" /></div>
          </div>
        </div>
        <div className="bg-white rounded-2xl border border-gray-100 p-6">
          <h3 className="font-bold text-gray-900 mb-4">إعدادات البث</h3>
          <div className="grid sm:grid-cols-2 gap-4">
            <div><label className="block text-sm font-medium text-gray-700 mb-1">عنوان البث الأساسي</label><input className="w-full px-4 py-2.5 border rounded-xl text-sm font-mono" defaultValue="https://s9.voscast.com:9617/stream" /></div>
            <div><label className="block text-sm font-medium text-gray-700 mb-1">المنطقة الزمنية</label><select className="w-full px-4 py-2.5 border rounded-xl text-sm"><option>توقيت اليمن (UTC+3)</option><option>توقيت السعودية (UTC+3)</option></select></div>
          </div>
        </div>
        <div className="bg-white rounded-2xl border border-gray-100 p-6">
          <h3 className="font-bold text-gray-900 mb-4">إعدادات التسجيل</h3>
          <div className="space-y-3">
            <label className="flex items-center gap-3 p-3 bg-gray-50 rounded-xl"><input type="checkbox" defaultChecked className="rounded" /><span className="text-sm">تفعيل خاصية التسجيل للمستخدمين</span></label>
            <label className="flex items-center gap-3 p-3 bg-gray-50 rounded-xl"><input type="checkbox" defaultChecked className="rounded" /><span className="text-sm">السماح بمشاركة التسجيلات</span></label>
            <label className="flex items-center gap-3 p-3 bg-gray-50 rounded-xl"><input type="checkbox" className="rounded" /><span className="text-sm">تفعيل التحذير عند مغادرة الصفحة أثناء التسجيل</span></label>
          </div>
        </div>
        <button className="px-8 py-3 alwan-gradient text-white rounded-xl font-medium shadow-lg">💾 حفظ جميع الإعدادات</button>
      </div>
    </div>
  );
}
