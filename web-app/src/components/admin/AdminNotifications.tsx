'use client';

export default function AdminNotifications() {
  return (
    <div>
      <div className="flex items-center justify-between mb-6">
        <div><h1 className="text-2xl font-bold text-gray-900">الإشعارات</h1><p className="text-sm text-gray-500 mt-1">إدارة الإشعارات والتنبيهات</p></div>
        <button className="px-5 py-2.5 alwan-gradient text-white rounded-xl text-sm font-medium">📨 إرسال إشعار</button>
      </div>
      <div className="bg-white rounded-2xl border border-gray-100 p-6 mb-6">
        <h3 className="font-bold text-gray-900 mb-4">إنشاء إشعار جديد</h3>
        <div className="space-y-4">
          <div><label className="block text-sm font-medium text-gray-700 mb-1">عنوان الإشعار</label><input className="w-full px-4 py-2.5 border rounded-xl text-sm" placeholder="عنوان الإشعار..." /></div>
          <div><label className="block text-sm font-medium text-gray-700 mb-1">المحتوى</label><textarea className="w-full px-4 py-2.5 border rounded-xl text-sm resize-none" rows={3} placeholder="نص الإشعار..." /></div>
          <div className="grid sm:grid-cols-3 gap-4">
            <div><label className="block text-sm font-medium text-gray-700 mb-1">النوع</label>
              <select className="w-full px-4 py-2.5 border rounded-xl text-sm"><option>عام</option><option>برنامج جديد</option><option>حلقة بودكاست</option><option>إعلان</option><option>تحديث</option></select>
            </div>
            <div><label className="block text-sm font-medium text-gray-700 mb-1">المنصة</label>
              <select className="w-full px-4 py-2.5 border rounded-xl text-sm"><option>الكل</option><option>الموقع</option><option>Android</option><option>iOS</option></select>
            </div>
            <div><label className="block text-sm font-medium text-gray-700 mb-1">الأولوية</label>
              <select className="w-full px-4 py-2.5 border rounded-xl text-sm"><option>عادية</option><option>عالية</option><option>عاجلة</option></select>
            </div>
          </div>
          <button className="px-6 py-2.5 alwan-gradient text-white rounded-xl text-sm font-medium">📤 إرسال الإشعار</button>
        </div>
      </div>
      <div className="bg-white rounded-2xl border border-gray-100 p-6">
        <h3 className="font-bold text-gray-900 mb-4">الإشعارات المرسلة</h3>
        <div className="space-y-3">
          {[
            { title: 'حلقة جديدة: فهم سلوك المستهلك', sent: 'منذ ساعة', recipients: 12450 },
            { title: 'تذكير: برنامج بودكاست ألوان يبدأ الساعة 1', sent: 'منذ 3 ساعات', recipients: 8920 },
            { title: 'حملة رمضان 2026 - عروض خاصة', sent: 'أمس', recipients: 15340 },
          ].map((notif, i) => (
            <div key={i} className="flex items-center gap-4 p-3 bg-gray-50 rounded-xl">
              <span className="text-xl">🔔</span>
              <div className="flex-1"><div className="text-sm font-medium text-gray-900">{notif.title}</div><div className="text-xs text-gray-400">{notif.sent} • {notif.recipients.toLocaleString('ar')} مستلم</div></div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
