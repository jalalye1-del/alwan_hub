'use client';

export default function AdminUsers() {
  const users = [
    { id: 1, name: 'أحمد محمد', email: 'ahmed@alwan.fm', role: 'مدير النظام', status: 'نشط', lastLogin: 'منذ 5 دقائق' },
    { id: 2, name: 'سارة علي', email: 'sara@alwan.fm', role: 'محرر محتوى', status: 'نشط', lastLogin: 'منذ ساعة' },
    { id: 3, name: 'خالد عمر', email: 'khaled@alwan.fm', role: 'مدير إعلانات', status: 'نشط', lastLogin: 'منذ 3 ساعات' },
    { id: 4, name: 'فاطمة حسن', email: 'fatima@alwan.fm', role: 'محلل', status: 'غير نشط', lastLogin: 'أمس' },
  ];

  return (
    <div>
      <div className="flex items-center justify-between mb-6">
        <div><h1 className="text-2xl font-bold text-gray-900">المستخدمون</h1><p className="text-sm text-gray-500 mt-1">إدارة حسابات المستخدمين والصلاحيات</p></div>
        <button className="px-5 py-2.5 alwan-gradient text-white rounded-xl text-sm font-medium">➕ مستخدم جديد</button>
      </div>
      <div className="bg-white rounded-2xl border border-gray-100 overflow-hidden">
        <table className="w-full text-sm">
          <thead className="bg-gray-50">
            <tr>
              <th className="text-right py-3 px-4 font-medium text-gray-500">الاسم</th>
              <th className="text-right py-3 px-4 font-medium text-gray-500">البريد</th>
              <th className="text-right py-3 px-4 font-medium text-gray-500">الدور</th>
              <th className="text-center py-3 px-4 font-medium text-gray-500">الحالة</th>
              <th className="text-right py-3 px-4 font-medium text-gray-500">آخر دخول</th>
              <th className="text-center py-3 px-4 font-medium text-gray-500">إجراءات</th>
            </tr>
          </thead>
          <tbody>
            {users.map(user => (
              <tr key={user.id} className="border-b border-gray-50 hover:bg-gray-50">
                <td className="py-3 px-4 font-medium text-gray-900">{user.name}</td>
                <td className="py-3 px-4 text-gray-600">{user.email}</td>
                <td className="py-3 px-4"><span className="px-2 py-1 bg-alwan-primary/10 text-alwan-primary rounded-full text-xs">{user.role}</span></td>
                <td className="py-3 px-4 text-center"><span className={`px-2 py-1 rounded-full text-xs ${user.status === 'نشط' ? 'bg-green-100 text-green-600' : 'bg-gray-100 text-gray-500'}`}>{user.status}</span></td>
                <td className="py-3 px-4 text-gray-500 text-xs">{user.lastLogin}</td>
                <td className="py-3 px-4 text-center"><button className="px-2 py-1 rounded bg-gray-100 text-xs">إدارة</button></td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
      <div className="mt-6 bg-white rounded-2xl border border-gray-100 p-6">
        <h3 className="font-bold text-gray-900 mb-4">الأدوار والصلاحيات (RBAC)</h3>
        <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-3">
          {[
            { role: 'مدير النظام', perms: 'جميع الصلاحيات', color: 'bg-red-50 text-red-700' },
            { role: 'مدير الإعلانات', perms: 'إدارة كاملة للإعلانات', color: 'bg-amber-50 text-amber-700' },
            { role: 'محرر الإعلانات', perms: 'إنشاء وتعديل المسودات', color: 'bg-blue-50 text-blue-700' },
            { role: 'مسؤول المراجعة', perms: 'اعتماد أو رفض الإعلانات', color: 'bg-purple-50 text-purple-700' },
            { role: 'مسؤول النشر', perms: 'جدولة ونشر الإعلانات', color: 'bg-emerald-50 text-emerald-700' },
            { role: 'محلل', perms: 'عرض التقارير والإحصائيات', color: 'bg-indigo-50 text-indigo-700' },
          ].map((r, i) => (
            <div key={i} className={`p-3 rounded-xl ${r.color}`}>
              <div className="font-medium text-sm">{r.role}</div>
              <div className="text-xs mt-0.5 opacity-80">{r.perms}</div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
