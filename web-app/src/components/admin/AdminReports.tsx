'use client';

export default function AdminReports() {
  return (
    <div>
      <h1 className="text-2xl font-bold text-gray-900 mb-2">التقارير والتحليلات</h1>
      <p className="text-sm text-gray-500 mb-6">تحليلات شاملة لأداء المنصة</p>
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
        {[
          { label: 'إجمالي المستمعين', value: '142,580', icon: '👥', change: '+18%' },
          { label: 'ساعات الاستماع', value: '28,450', icon: '🎧', change: '+12%' },
          { label: 'التسجيلات المحفوظة', value: '3,420', icon: '⏺️', change: '+25%' },
          { label: 'معدل التفاعل', value: '4.2%', icon: '📊', change: '+5%' },
        ].map((stat, i) => (
          <div key={i} className="bg-white rounded-xl p-5 border border-gray-100">
            <div className="flex items-center justify-between mb-2"><span className="text-2xl">{stat.icon}</span><span className="text-xs text-green-500 bg-green-50 px-2 py-0.5 rounded-full">{stat.change}</span></div>
            <div className="text-2xl font-bold">{stat.value}</div>
            <div className="text-xs text-gray-500 mt-1">{stat.label}</div>
          </div>
        ))}
      </div>
      <div className="grid lg:grid-cols-2 gap-6">
        <div className="bg-white rounded-2xl border border-gray-100 p-6">
          <h3 className="font-bold text-gray-900 mb-4">أكثر البرامج استماعاً</h3>
          <div className="space-y-3">
            {[
              { name: 'بودكاست ألوان', listeners: 12450, percent: 85 },
              { name: 'طبيب ألوان', listeners: 8920, percent: 65 },
              { name: 'شعر وحنين', listeners: 6340, percent: 48 },
              { name: 'موعظة حسنة', listeners: 4120, percent: 32 },
            ].map((p, i) => (
              <div key={i}>
                <div className="flex items-center justify-between text-sm mb-1"><span className="font-medium text-gray-900">{p.name}</span><span className="text-gray-500">{p.listeners.toLocaleString('ar')}</span></div>
                <div className="h-2 bg-gray-100 rounded-full"><div className="h-full alwan-gradient rounded-full" style={{ width: `${p.percent}%` }} /></div>
              </div>
            ))}
          </div>
        </div>
        <div className="bg-white rounded-2xl border border-gray-100 p-6">
          <h3 className="font-bold text-gray-900 mb-4">الإذاعات الأكثر استماعاً</h3>
          <div className="space-y-3">
            {[
              { name: 'إذاعة ألوان FM', listeners: 12458, percent: 92 },
              { name: 'بي بي سي عربي', listeners: 28540, percent: 78 },
              { name: 'مونت كارلو', listeners: 21430, percent: 65 },
              { name: 'إذاعة القرآن', listeners: 11870, percent: 55 },
            ].map((s, i) => (
              <div key={i}>
                <div className="flex items-center justify-between text-sm mb-1"><span className="font-medium text-gray-900">{s.name}</span><span className="text-gray-500">{s.listeners.toLocaleString('ar')}</span></div>
                <div className="h-2 bg-gray-100 rounded-full"><div className="h-full bg-emerald-500 rounded-full" style={{ width: `${s.percent}%` }} /></div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
