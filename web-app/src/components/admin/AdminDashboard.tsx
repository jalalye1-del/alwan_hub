'use client';

export default function AdminDashboard() {
  const stats = [
    { label: 'المستمعون النشطون', value: '12,458', change: '+12%', icon: '🎧', color: 'bg-blue-500' },
    { label: 'البرامج النشطة', value: '24', change: '+3', icon: '🎙️', color: 'bg-purple-500' },
    { label: 'الإعلانات النشطة', value: '18', change: '+5', icon: '📢', color: 'bg-amber-500' },
    { label: 'حلقات البودكاست', value: '42', change: '+8', icon: '🎧', color: 'bg-emerald-500' },
  ];

  const recentActivity = [
    { action: 'نشر إعلان', target: 'حملة رمضان 2026', time: 'منذ 5 دقائق', icon: '📢' },
    { action: 'إضافة برنامج', target: 'صباحكم ألوان', time: 'منذ ساعة', icon: '🎙️' },
    { action: 'تحديث الجدول', target: 'الإثنين - الخميس', time: 'منذ 3 ساعات', icon: '📅' },
    { action: 'نشر حلقة بودكاست', target: 'اقتصاد ببساطة - ح 15', time: 'منذ 5 ساعات', icon: '🎧' },
    { action: 'إيقاف إعلان', target: 'بنر قديم', time: 'أمس', icon: '⏸️' },
  ];

  return (
    <div>
      <div className="mb-8">
        <h1 className="text-2xl font-bold text-gray-900">لوحة التحكم</h1>
        <p className="text-sm text-gray-500 mt-1">نظرة عامة على منصة ألوان هَب</p>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
        {stats.map((stat, i) => (
          <div key={i} className="bg-white rounded-2xl p-5 border border-gray-100">
            <div className="flex items-center justify-between mb-3">
              <span className="text-2xl">{stat.icon}</span>
              <span className="text-xs font-medium text-green-500 bg-green-50 px-2 py-1 rounded-full">{stat.change}</span>
            </div>
            <div className="text-2xl font-bold text-gray-900">{stat.value}</div>
            <div className="text-sm text-gray-500 mt-1">{stat.label}</div>
          </div>
        ))}
      </div>

      <div className="grid lg:grid-cols-2 gap-6">
        {/* Recent Activity */}
        <div className="bg-white rounded-2xl border border-gray-100 p-6">
          <h2 className="text-lg font-bold text-gray-900 mb-4">النشاط الأخير</h2>
          <div className="space-y-3">
            {recentActivity.map((item, i) => (
              <div key={i} className="flex items-center gap-3 p-3 rounded-xl hover:bg-gray-50">
                <span className="text-xl">{item.icon}</span>
                <div className="flex-1 min-w-0">
                  <div className="text-sm font-medium text-gray-900">{item.action}</div>
                  <div className="text-xs text-gray-500 truncate">{item.target}</div>
                </div>
                <span className="text-xs text-gray-400 flex-shrink-0">{item.time}</span>
              </div>
            ))}
          </div>
        </div>

        {/* Quick Actions */}
        <div className="bg-white rounded-2xl border border-gray-100 p-6">
          <h2 className="text-lg font-bold text-gray-900 mb-4">إجراءات سريعة</h2>
          <div className="grid grid-cols-2 gap-3">
            {[
              { label: 'إضافة برنامج', icon: '🎙️', color: 'bg-blue-50 text-blue-600' },
              { label: 'نشر إعلان', icon: '📢', color: 'bg-amber-50 text-amber-600' },
              { label: 'تعديل الجدول', icon: '📅', color: 'bg-purple-50 text-purple-600' },
              { label: 'إرسال إشعار', icon: '🔔', color: 'bg-red-50 text-red-600' },
              { label: 'إضافة بودكاست', icon: '🎧', color: 'bg-emerald-50 text-emerald-600' },
              { label: 'عرض التقارير', icon: '📈', color: 'bg-indigo-50 text-indigo-600' },
            ].map((action, i) => (
              <button key={i} className={`flex items-center gap-2 p-4 rounded-xl ${action.color} hover:opacity-80 transition-opacity text-sm font-medium`}>
                <span className="text-lg">{action.icon}</span>
                {action.label}
              </button>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
