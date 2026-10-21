'use client';

import { useState } from 'react';

type AdStatus = 'draft' | 'active' | 'scheduled' | 'paused' | 'expired' | 'review';
type AdType = 'image' | 'video' | 'audio' | 'text' | 'promotional' | 'external_link';
type Platform = 'web' | 'android' | 'ios';
type PublishMode = 'unified' | 'separate' | 'unified_custom';

interface AdCampaign {
  id: string;
  name: string;
  advertiserName: string;
  status: AdStatus;
  platforms: Platform[];
  publishMode: PublishMode;
  startDate: string;
  endDate: string;
  priority: number;
  impressions: number;
  clicks: number;
  adCount: number;
}

const mockCampaigns: AdCampaign[] = [
  { id: '1', name: 'حملة رمضان 2026', advertiserName: 'شركة النور', status: 'active', platforms: ['web', 'android', 'ios'], publishMode: 'unified', startDate: '2026-03-01', endDate: '2026-04-30', priority: 1, impressions: 45230, clicks: 1823, adCount: 5 },
  { id: '2', name: 'إعلانات بنك الأمل', advertiserName: 'بنك الأمل', status: 'active', platforms: ['web', 'android'], publishMode: 'unified_custom', startDate: '2026-01-01', endDate: '2026-12-31', priority: 2, impressions: 28450, clicks: 956, adCount: 3 },
  { id: '3', name: 'ترويج برنامج صباحكم ألوان', advertiserName: 'إذاعة ألوان', status: 'active', platforms: ['web', 'android', 'ios'], publishMode: 'unified', startDate: '2026-06-01', endDate: '2026-08-31', priority: 3, impressions: 12340, clicks: 567, adCount: 2 },
  { id: '4', name: 'حملة شاي الكبوس', advertiserName: 'شاي الكبوس', status: 'scheduled', platforms: ['web', 'android', 'ios'], publishMode: 'separate', startDate: '2026-11-01', endDate: '2026-12-31', priority: 1, impressions: 0, clicks: 0, adCount: 4 },
  { id: '5', name: 'إعلان قديم - عرض خاص', advertiserName: 'محل الزهور', status: 'paused', platforms: ['web'], publishMode: 'unified', startDate: '2026-01-01', endDate: '2026-06-30', priority: 5, impressions: 8900, clicks: 234, adCount: 1 },
];

const statusConfig: Record<AdStatus, { label: string; color: string; bg: string }> = {
  draft: { label: 'مسودة', color: 'text-gray-600', bg: 'bg-gray-100' },
  active: { label: 'نشط', color: 'text-green-600', bg: 'bg-green-100' },
  scheduled: { label: 'مجدول', color: 'text-blue-600', bg: 'bg-blue-100' },
  paused: { label: 'متوقف', color: 'text-amber-600', bg: 'bg-amber-100' },
  expired: { label: 'منتهي', color: 'text-red-600', bg: 'bg-red-100' },
  review: { label: 'قيد المراجعة', color: 'text-purple-600', bg: 'bg-purple-100' },
};

type SubTab = 'overview' | 'campaigns' | 'placements' | 'create' | 'preview' | 'reports';

export default function AdminAdvertisements() {
  const [subTab, setSubTab] = useState<SubTab>('overview');
  const [showCreateForm, setShowCreateForm] = useState(false);
  const [selectedCampaign, setSelectedCampaign] = useState<AdCampaign | null>(null);
  const [campaigns, setCampaigns] = useState(mockCampaigns);

  // New Ad form state
  const [newAd, setNewAd] = useState({
    name: '', advertiserName: '', type: 'image' as AdType, platforms: ['web', 'android', 'ios'] as Platform[],
    publishMode: 'unified' as PublishMode, startDate: '', endDate: '', priority: 3,
    imageUrl: '', linkUrl: '', placement: 'homepage-banner', description: '',
  });

  const activeCount = campaigns.filter(c => c.status === 'active').length;
  const scheduledCount = campaigns.filter(c => c.status === 'scheduled').length;
  const pausedCount = campaigns.filter(c => c.status === 'paused').length;
  const totalImpressions = campaigns.reduce((sum, c) => sum + c.impressions, 0);
  const totalClicks = campaigns.reduce((sum, c) => sum + c.clicks, 0);

  const subTabs: { id: SubTab; label: string; icon: string }[] = [
    { id: 'overview', label: 'نظرة عامة', icon: '📊' },
    { id: 'campaigns', label: 'الحملات', icon: '📋' },
    { id: 'placements', label: 'المواضع الإعلانية', icon: '📍' },
    { id: 'create', label: 'إنشاء إعلان', icon: '➕' },
    { id: 'preview', label: 'المعاينة', icon: '👁️' },
    { id: 'reports', label: 'التقارير', icon: '📈' },
  ];

  const handleCreateAd = () => {
    const campaign: AdCampaign = {
      id: String(campaigns.length + 1),
      name: newAd.name,
      advertiserName: newAd.advertiserName,
      status: 'draft',
      platforms: newAd.platforms,
      publishMode: newAd.publishMode,
      startDate: newAd.startDate,
      endDate: newAd.endDate,
      priority: newAd.priority,
      impressions: 0,
      clicks: 0,
      adCount: 1,
    };
    setCampaigns([campaign, ...campaigns]);
    setShowCreateForm(false);
    setSubTab('campaigns');
  };

  const toggleCampaignStatus = (id: string) => {
    setCampaigns(campaigns.map(c => {
      if (c.id === id) {
        return { ...c, status: c.status === 'active' ? 'paused' : 'active' };
      }
      return c;
    }));
  };

  return (
    <div>
      <div className="flex items-center justify-between mb-6">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">إدارة الإعلانات</h1>
          <p className="text-sm text-gray-500 mt-1">إدارة مركزية لإعلانات الموقع والتطبيق</p>
        </div>
        <button
          onClick={() => { setSubTab('create'); setShowCreateForm(true); }}
          className="flex items-center gap-2 px-5 py-2.5 alwan-gradient text-white rounded-xl text-sm font-medium hover:opacity-90 shadow-lg"
        >
          ➕ إعلان جديد
        </button>
      </div>

      {/* Sub Tabs */}
      <div className="flex gap-2 mb-6 overflow-x-auto pb-2">
        {subTabs.map((tab) => (
          <button
            key={tab.id}
            onClick={() => { setSubTab(tab.id); if (tab.id === 'create') setShowCreateForm(true); }}
            className={`flex items-center gap-2 px-4 py-2.5 rounded-xl text-sm font-medium whitespace-nowrap transition-all ${
              subTab === tab.id
                ? 'alwan-gradient text-white shadow-lg'
                : 'bg-white text-gray-600 border border-gray-200 hover:border-alwan-primary/30'
            }`}
          >
            <span>{tab.icon}</span> {tab.label}
          </button>
        ))}
      </div>

      {/* Overview */}
      {subTab === 'overview' && (
        <div className="space-y-6">
          <div className="grid grid-cols-2 lg:grid-cols-5 gap-4">
            <div className="bg-white rounded-xl p-4 border border-gray-100">
              <div className="text-xs text-gray-500 mb-1">إجمالي الإعلانات</div>
              <div className="text-2xl font-bold">{campaigns.length}</div>
            </div>
            <div className="bg-white rounded-xl p-4 border border-green-100">
              <div className="text-xs text-green-600 mb-1">النشطة</div>
              <div className="text-2xl font-bold text-green-600">{activeCount}</div>
            </div>
            <div className="bg-white rounded-xl p-4 border border-blue-100">
              <div className="text-xs text-blue-600 mb-1">المجدولة</div>
              <div className="text-2xl font-bold text-blue-600">{scheduledCount}</div>
            </div>
            <div className="bg-white rounded-xl p-4 border border-gray-100">
              <div className="text-xs text-gray-500 mb-1">الظهور</div>
              <div className="text-2xl font-bold">{totalImpressions.toLocaleString('ar')}</div>
            </div>
            <div className="bg-white rounded-xl p-4 border border-gray-100">
              <div className="text-xs text-gray-500 mb-1">النقرات</div>
              <div className="text-2xl font-bold">{totalClicks.toLocaleString('ar')}</div>
            </div>
          </div>

          {/* Active Campaigns Table */}
          <div className="bg-white rounded-2xl border border-gray-100 overflow-hidden">
            <div className="p-5 border-b border-gray-100">
              <h3 className="font-bold text-gray-900">الحملات الإعلانية</h3>
            </div>
            <div className="overflow-x-auto">
              <table className="w-full text-sm">
                <thead className="bg-gray-50">
                  <tr>
                    <th className="text-right py-3 px-4 font-medium text-gray-500">الحملة</th>
                    <th className="text-right py-3 px-4 font-medium text-gray-500">المعلن</th>
                    <th className="text-center py-3 px-4 font-medium text-gray-500">الحالة</th>
                    <th className="text-center py-3 px-4 font-medium text-gray-500">المنصات</th>
                    <th className="text-center py-3 px-4 font-medium text-gray-500">نمط النشر</th>
                    <th className="text-center py-3 px-4 font-medium text-gray-500">الظهور</th>
                    <th className="text-center py-3 px-4 font-medium text-gray-500">النقرات</th>
                    <th className="text-center py-3 px-4 font-medium text-gray-500">إجراءات</th>
                  </tr>
                </thead>
                <tbody>
                  {campaigns.map((campaign) => (
                    <tr key={campaign.id} className="border-b border-gray-50 hover:bg-gray-50">
                      <td className="py-3 px-4">
                        <div className="font-medium text-gray-900">{campaign.name}</div>
                        <div className="text-xs text-gray-400">{campaign.startDate} → {campaign.endDate}</div>
                      </td>
                      <td className="py-3 px-4 text-gray-600">{campaign.advertiserName}</td>
                      <td className="py-3 px-4 text-center">
                        <span className={`inline-flex px-2 py-1 rounded-full text-xs font-medium ${statusConfig[campaign.status].bg} ${statusConfig[campaign.status].color}`}>
                          {statusConfig[campaign.status].label}
                        </span>
                      </td>
                      <td className="py-3 px-4 text-center">
                        <div className="flex items-center justify-center gap-1">
                          {campaign.platforms.map(p => (
                            <span key={p} className="text-xs bg-gray-100 px-1.5 py-0.5 rounded">
                              {p === 'web' ? '🌐' : p === 'android' ? '🤖' : '🍎'}
                            </span>
                          ))}
                        </div>
                      </td>
                      <td className="py-3 px-4 text-center text-xs text-gray-600">
                        {campaign.publishMode === 'unified' ? 'موحد' : campaign.publishMode === 'separate' ? 'منفصل' : 'موحد مخصص'}
                      </td>
                      <td className="py-3 px-4 text-center text-gray-600">{campaign.impressions.toLocaleString('ar')}</td>
                      <td className="py-3 px-4 text-center text-gray-600">{campaign.clicks.toLocaleString('ar')}</td>
                      <td className="py-3 px-4 text-center">
                        <div className="flex items-center justify-center gap-1">
                          <button
                            onClick={() => toggleCampaignStatus(campaign.id)}
                            className={`px-2 py-1 rounded text-xs font-medium ${
                              campaign.status === 'active' ? 'bg-amber-100 text-amber-700' : 'bg-green-100 text-green-700'
                            }`}
                          >
                            {campaign.status === 'active' ? '⏸ إيقاف' : '▶ تفعيل'}
                          </button>
                          <button className="px-2 py-1 rounded text-xs bg-gray-100 text-gray-600">✏️</button>
                        </div>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        </div>
      )}

      {/* Campaigns */}
      {subTab === 'campaigns' && (
        <div className="space-y-4">
          {campaigns.map((campaign) => (
            <div key={campaign.id} className="bg-white rounded-2xl border border-gray-100 p-6 hover:shadow-md transition-shadow">
              <div className="flex items-start justify-between mb-4">
                <div>
                  <div className="flex items-center gap-3">
                    <h3 className="text-lg font-bold text-gray-900">{campaign.name}</h3>
                    <span className={`px-2.5 py-1 rounded-full text-xs font-medium ${statusConfig[campaign.status].bg} ${statusConfig[campaign.status].color}`}>
                      {statusConfig[campaign.status].label}
                    </span>
                  </div>
                  <p className="text-sm text-gray-500 mt-1">{campaign.advertiserName}</p>
                </div>
                <div className="flex gap-2">
                  <button onClick={() => toggleCampaignStatus(campaign.id)} className="px-3 py-1.5 rounded-lg bg-gray-100 text-gray-600 text-xs hover:bg-gray-200">
                    {campaign.status === 'active' ? '⏸ إيقاف' : '▶ تفعيل'}
                  </button>
                  <button className="px-3 py-1.5 rounded-lg bg-alwan-primary/10 text-alwan-primary text-xs hover:bg-alwan-primary/20">✏️ تعديل</button>
                  <button className="px-3 py-1.5 rounded-lg bg-red-50 text-red-600 text-xs hover:bg-red-100">🗑️ حذف</button>
                </div>
              </div>
              <div className="grid grid-cols-2 md:grid-cols-6 gap-4">
                <div>
                  <div className="text-xs text-gray-400">المنصات</div>
                  <div className="flex gap-1 mt-1">
                    {campaign.platforms.map(p => (
                      <span key={p} className="text-xs bg-gray-100 px-2 py-0.5 rounded">{p === 'web' ? '🌐 ويب' : p === 'android' ? '🤖 أندرويد' : '🍎 iOS'}</span>
                    ))}
                  </div>
                </div>
                <div>
                  <div className="text-xs text-gray-400">نمط النشر</div>
                  <div className="text-sm font-medium mt-1">
                    {campaign.publishMode === 'unified' ? '🔗 موحد ومتزامن' : campaign.publishMode === 'separate' ? '📱 منفصل' : '🎨 موحد مع تخصيص'}
                  </div>
                </div>
                <div>
                  <div className="text-xs text-gray-400">الفترة</div>
                  <div className="text-sm mt-1">{campaign.startDate} → {campaign.endDate}</div>
                </div>
                <div>
                  <div className="text-xs text-gray-400">الظهور</div>
                  <div className="text-sm font-bold mt-1">{campaign.impressions.toLocaleString('ar')}</div>
                </div>
                <div>
                  <div className="text-xs text-gray-400">النقرات</div>
                  <div className="text-sm font-bold mt-1">{campaign.clicks.toLocaleString('ar')}</div>
                </div>
                <div>
                  <div className="text-xs text-gray-400">معدل التفاعل</div>
                  <div className="text-sm font-bold mt-1">
                    {campaign.impressions > 0 ? ((campaign.clicks / campaign.impressions) * 100).toFixed(2) : 0}%
                  </div>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Placements */}
      {subTab === 'placements' && (
        <div className="space-y-6">
          <div className="bg-white rounded-2xl border border-gray-100 p-6">
            <h3 className="font-bold text-gray-900 mb-4">المواضع الإعلانية — الموقع</h3>
            <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-3">
              {[
                { id: 'header-top', name: 'أعلى الهيدر', dimensions: '970×90', type: 'صورة / فيديو' },
                { id: 'homepage-banner', name: 'البنر الرئيسي', dimensions: '1200×400', type: 'صورة / فيديو / صوت' },
                { id: 'homepage-middle', name: 'بين أقسام المحتوى', dimensions: '728×90', type: 'صورة' },
                { id: 'live-page', name: 'صفحة البث المباشر', dimensions: '300×250', type: 'صورة / نصي' },
                { id: 'programs-page', name: 'صفحة البرامج', dimensions: '728×90', type: 'صورة / ترويجي' },
                { id: 'podcasts-page', name: 'صفحة البودكاست', dimensions: '300×250', type: 'صورة / نصي' },
                { id: 'episode-page', name: 'صفحات الحلقات', dimensions: '728×90', type: 'صورة' },
              ].map((placement) => (
                <div key={placement.id} className="p-4 rounded-xl border border-gray-200 hover:border-alwan-primary/30 hover:bg-alwan-primary/5 transition-all">
                  <div className="font-medium text-gray-900 text-sm">{placement.name}</div>
                  <div className="text-xs text-gray-500 mt-1">📐 {placement.dimensions}</div>
                  <div className="text-xs text-gray-400 mt-0.5">📦 {placement.type}</div>
                </div>
              ))}
            </div>
          </div>
          <div className="bg-white rounded-2xl border border-gray-100 p-6">
            <h3 className="font-bold text-gray-900 mb-4">المواضع الإعلانية — التطبيق</h3>
            <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-3">
              {[
                { id: 'app-home', name: 'الشاشة الرئيسية', dimensions: '320×100', type: 'صورة / بانر' },
                { id: 'app-main-banner', name: 'البنر الرئيسي', dimensions: '360×180', type: 'صورة / فيديو' },
                { id: 'app-between-cards', name: 'بين بطاقات المحتوى', dimensions: '320×80', type: 'صورة / نصي' },
                { id: 'app-programs', name: 'أقسام البرامج', dimensions: '320×100', type: 'ترويجي' },
                { id: 'app-podcasts', name: 'صفحة البودكاست', dimensions: '320×250', type: 'صورة / صوتي' },
                { id: 'app-library', name: 'المكتبة الصوتية', dimensions: '320×100', type: 'صورة' },
              ].map((placement) => (
                <div key={placement.id} className="p-4 rounded-xl border border-gray-200 hover:border-alwan-primary/30 hover:bg-alwan-primary/5 transition-all">
                  <div className="font-medium text-gray-900 text-sm">{placement.name}</div>
                  <div className="text-xs text-gray-500 mt-1">📐 {placement.dimensions}</div>
                  <div className="text-xs text-gray-400 mt-0.5">📦 {placement.type}</div>
                </div>
              ))}
            </div>
          </div>
        </div>
      )}

      {/* Create Ad */}
      {subTab === 'create' && (
        <div className="bg-white rounded-2xl border border-gray-100 p-6 max-w-3xl">
          <h3 className="text-lg font-bold text-gray-900 mb-6">إنشاء إعلان جديد</h3>
          <div className="space-y-5">
            <div className="grid sm:grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">اسم الحملة *</label>
                <input type="text" value={newAd.name} onChange={e => setNewAd({...newAd, name: e.target.value})} className="w-full px-4 py-2.5 border border-gray-200 rounded-xl text-sm focus:ring-2 focus:ring-alwan-primary/20 focus:border-alwan-primary outline-none" placeholder="مثال: حملة رمضان 2026" />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">اسم المعلن *</label>
                <input type="text" value={newAd.advertiserName} onChange={e => setNewAd({...newAd, advertiserName: e.target.value})} className="w-full px-4 py-2.5 border border-gray-200 rounded-xl text-sm focus:ring-2 focus:ring-alwan-primary/20 focus:border-alwan-primary outline-none" placeholder="مثال: شركة النور" />
              </div>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">نوع الإعلان</label>
              <select value={newAd.type} onChange={e => setNewAd({...newAd, type: e.target.value as AdType})} className="w-full px-4 py-2.5 border border-gray-200 rounded-xl text-sm focus:ring-2 focus:ring-alwan-primary/20 focus:border-alwan-primary outline-none">
                <option value="image">🖼️ صورة ثابتة</option>
                <option value="video">🎬 فيديو</option>
                <option value="audio">🔊 صورة مع صوت</option>
                <option value="text">📝 نصي / صورة ونص</option>
                <option value="promotional">🎯 ترويجي لبرنامج</option>
                <option value="external_link">🔗 رابط خارجي</option>
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">المنصات المستهدفة</label>
              <div className="flex gap-3">
                {(['web', 'android', 'ios'] as Platform[]).map(platform => (
                  <label key={platform} className="flex items-center gap-2 px-4 py-2 border rounded-xl cursor-pointer hover:bg-gray-50">
                    <input type="checkbox" checked={newAd.platforms.includes(platform)} onChange={e => {
                      if (e.target.checked) setNewAd({...newAd, platforms: [...newAd.platforms, platform]});
                      else setNewAd({...newAd, platforms: newAd.platforms.filter(p => p !== platform)});
                    }} className="rounded" />
                    <span className="text-sm">{platform === 'web' ? '🌐 الموقع' : platform === 'android' ? '🤖 أندرويد' : '🍎 iOS'}</span>
                  </label>
                ))}
              </div>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">نمط النشر عبر المنصات</label>
              <div className="grid sm:grid-cols-3 gap-3">
                {[
                  { value: 'unified', label: '🔗 موحد ومتزامن', desc: 'نفس المادة على جميع المنصات' },
                  { value: 'separate', label: '📱 منفصل', desc: 'مادة مختلفة لكل منصة' },
                  { value: 'unified_custom', label: '🎨 موحد مع تخصيص', desc: 'حملة موحدة مع تخصيص العرض' },
                ].map(mode => (
                  <button
                    key={mode.value}
                    onClick={() => setNewAd({...newAd, publishMode: mode.value as PublishMode})}
                    className={`p-3 rounded-xl border text-right text-sm transition-all ${
                      newAd.publishMode === mode.value
                        ? 'border-alwan-primary bg-alwan-primary/5 ring-2 ring-alwan-primary/20'
                        : 'border-gray-200 hover:border-gray-300'
                    }`}
                  >
                    <div className="font-medium text-gray-900">{mode.label}</div>
                    <div className="text-xs text-gray-500 mt-0.5">{mode.desc}</div>
                  </button>
                ))}
              </div>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">وصف الإعلان</label>
              <textarea value={newAd.description} onChange={e => setNewAd({...newAd, description: e.target.value})} rows={3} className="w-full px-4 py-2.5 border border-gray-200 rounded-xl text-sm focus:ring-2 focus:ring-alwan-primary/20 focus:border-alwan-primary outline-none resize-none" placeholder="وصف مختصر للإعلان..." />
            </div>

            <div className="grid sm:grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">تاريخ البدء</label>
                <input type="date" value={newAd.startDate} onChange={e => setNewAd({...newAd, startDate: e.target.value})} className="w-full px-4 py-2.5 border border-gray-200 rounded-xl text-sm focus:ring-2 focus:ring-alwan-primary/20 focus:border-alwan-primary outline-none" />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">تاريخ الانتهاء</label>
                <input type="date" value={newAd.endDate} onChange={e => setNewAd({...newAd, endDate: e.target.value})} className="w-full px-4 py-2.5 border border-gray-200 rounded-xl text-sm focus:ring-2 focus:ring-alwan-primary/20 focus:border-alwan-primary outline-none" />
              </div>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">الموضع الإعلاني</label>
              <select value={newAd.placement} onChange={e => setNewAd({...newAd, placement: e.target.value})} className="w-full px-4 py-2.5 border border-gray-200 rounded-xl text-sm focus:ring-2 focus:ring-alwan-primary/20 focus:border-alwan-primary outline-none">
                <option value="homepage-banner">البنر الرئيسي — الموقع</option>
                <option value="header-top">أعلى الهيدر — الموقع</option>
                <option value="homepage-middle">بين أقسام المحتوى — الموقع</option>
                <option value="live-page">صفحة البث المباشر — الموقع</option>
                <option value="app-home">الشاشة الرئيسية — التطبيق</option>
                <option value="app-main-banner">البنر الرئيسي — التطبيق</option>
                <option value="app-between-cards">بين بطاقات المحتوى — التطبيق</option>
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">الأولوية (1 = الأعلى)</label>
              <input type="number" min={1} max={10} value={newAd.priority} onChange={e => setNewAd({...newAd, priority: parseInt(e.target.value)})} className="w-32 px-4 py-2.5 border border-gray-200 rounded-xl text-sm focus:ring-2 focus:ring-alwan-primary/20 focus:border-alwan-primary outline-none" />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">رفع مادة الإعلان</label>
              <div className="border-2 border-dashed border-gray-200 rounded-xl p-8 text-center hover:border-alwan-primary/50 transition-colors cursor-pointer">
                <div className="text-4xl mb-2">📁</div>
                <p className="text-sm text-gray-500">اسحب الملفات هنا أو انقر للاختيار</p>
                <p className="text-xs text-gray-400 mt-1">يدعم: صور (JPG, PNG, WebP) — فيديو (MP4) — صوت (MP3)</p>
              </div>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">رابط الانتقال</label>
              <input type="url" value={newAd.linkUrl} onChange={e => setNewAd({...newAd, linkUrl: e.target.value})} className="w-full px-4 py-2.5 border border-gray-200 rounded-xl text-sm focus:ring-2 focus:ring-alwan-primary/20 focus:border-alwan-primary outline-none" placeholder="https://example.com/landing-page" />
            </div>

            <div className="flex gap-3 pt-4 border-t border-gray-100">
              <button onClick={handleCreateAd} className="flex-1 py-3 alwan-gradient text-white rounded-xl font-medium hover:opacity-90 shadow-lg">
                💾 حفظ كمسودة
              </button>
              <button onClick={() => { handleCreateAd(); }} className="px-6 py-3 bg-green-500 text-white rounded-xl font-medium hover:bg-green-600">
                🚀 نشر مباشرة
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Preview */}
      {subTab === 'preview' && (
        <div className="space-y-6">
          <h3 className="text-lg font-bold text-gray-900">معاينة الإعلان على المنصات</h3>
          <div className="grid md:grid-cols-3 gap-6">
            {/* Desktop Preview */}
            <div className="bg-white rounded-2xl border border-gray-100 overflow-hidden">
              <div className="p-3 bg-gray-50 border-b border-gray-100 flex items-center gap-2">
                <span className="text-sm">🖥️</span>
                <span className="text-sm font-medium text-gray-700">سطح المكتب</span>
              </div>
              <div className="p-4 space-y-3">
                <div className="h-6 bg-gray-100 rounded" />
                <div className="h-16 bg-gradient-to-r from-alwan-primary/20 to-alwan-secondary/20 rounded-xl flex items-center justify-center border-2 border-dashed border-alwan-primary/30">
                  <div className="text-center">
                    <div className="text-xs text-alwan-primary font-medium">مساحة الإعلان</div>
                    <div className="text-[10px] text-gray-400">1200 × 400</div>
                  </div>
                </div>
                <div className="h-4 bg-gray-100 rounded w-3/4" />
                <div className="h-4 bg-gray-100 rounded w-1/2" />
              </div>
            </div>

            {/* Android Preview */}
            <div className="bg-white rounded-2xl border border-gray-100 overflow-hidden">
              <div className="p-3 bg-gray-50 border-b border-gray-100 flex items-center gap-2">
                <span className="text-sm">🤖</span>
                <span className="text-sm font-medium text-gray-700">أندرويد</span>
              </div>
              <div className="p-4 max-w-[200px] mx-auto">
                <div className="border-2 border-gray-200 rounded-2xl overflow-hidden">
                  <div className="h-4 bg-gray-100" />
                  <div className="p-3 space-y-2">
                    <div className="h-20 bg-gradient-to-r from-alwan-primary/20 to-alwan-secondary/20 rounded-lg flex items-center justify-center border border-dashed border-alwan-primary/30">
                      <div className="text-[10px] text-alwan-primary">360 × 180</div>
                    </div>
                    <div className="h-3 bg-gray-100 rounded w-3/4" />
                    <div className="h-3 bg-gray-100 rounded w-1/2" />
                  </div>
                  <div className="h-8 bg-gray-50 border-t" />
                </div>
              </div>
            </div>

            {/* iOS Preview */}
            <div className="bg-white rounded-2xl border border-gray-100 overflow-hidden">
              <div className="p-3 bg-gray-50 border-b border-gray-100 flex items-center gap-2">
                <span className="text-sm">🍎</span>
                <span className="text-sm font-medium text-gray-700">iPhone</span>
              </div>
              <div className="p-4 max-w-[180px] mx-auto">
                <div className="border-2 border-gray-200 rounded-3xl overflow-hidden">
                  <div className="h-4 bg-gray-100 rounded-b-none" />
                  <div className="p-3 space-y-2">
                    <div className="h-20 bg-gradient-to-r from-alwan-primary/20 to-alwan-secondary/20 rounded-lg flex items-center justify-center border border-dashed border-alwan-primary/30">
                      <div className="text-[10px] text-alwan-primary">320 × 100</div>
                    </div>
                    <div className="h-3 bg-gray-100 rounded w-3/4" />
                    <div className="h-3 bg-gray-100 rounded w-1/2" />
                  </div>
                  <div className="h-8 bg-gray-50 border-t" />
                </div>
              </div>
            </div>
          </div>
          <p className="text-xs text-gray-400 text-center">⚠️ المعاينة تقريبية ولا تغني عن اختبار الأجهزة الحقيقية</p>
        </div>
      )}

      {/* Reports */}
      {subTab === 'reports' && (
        <div className="space-y-6">
          <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
            <div className="bg-white rounded-xl p-5 border border-gray-100">
              <div className="text-xs text-gray-500">إجمالي الظهور</div>
              <div className="text-2xl font-bold mt-1">{totalImpressions.toLocaleString('ar')}</div>
              <div className="text-xs text-green-500 mt-1">↑ 15% من الشهر السابق</div>
            </div>
            <div className="bg-white rounded-xl p-5 border border-gray-100">
              <div className="text-xs text-gray-500">إجمالي النقرات</div>
              <div className="text-2xl font-bold mt-1">{totalClicks.toLocaleString('ar')}</div>
              <div className="text-xs text-green-500 mt-1">↑ 8% من الشهر السابق</div>
            </div>
            <div className="bg-white rounded-xl p-5 border border-gray-100">
              <div className="text-xs text-gray-500">معدل التفاعل</div>
              <div className="text-2xl font-bold mt-1">{totalImpressions > 0 ? ((totalClicks / totalImpressions) * 100).toFixed(2) : 0}%</div>
              <div className="text-xs text-amber-500 mt-1">↓ 0.5% من الشهر السابق</div>
            </div>
            <div className="bg-white rounded-xl p-5 border border-gray-100">
              <div className="text-xs text-gray-500">أعلى إعلان تفاعلاً</div>
              <div className="text-sm font-bold mt-1 truncate">حملة رمضان 2026</div>
              <div className="text-xs text-green-500 mt-1">1,823 نقرة</div>
            </div>
          </div>

          {/* Platform comparison */}
          <div className="bg-white rounded-2xl border border-gray-100 p-6">
            <h3 className="font-bold text-gray-900 mb-4">الأداء حسب المنصة</h3>
            <div className="space-y-3">
              {[
                { platform: '🌐 الموقع', impressions: 28500, clicks: 1200, color: 'bg-blue-500' },
                { platform: '🤖 أندرويد', impressions: 18200, clicks: 890, color: 'bg-green-500' },
                { platform: '🍎 iOS', impressions: 12100, clicks: 560, color: 'bg-purple-500' },
              ].map((row) => (
                <div key={row.platform} className="flex items-center gap-4">
                  <span className="text-sm w-24">{row.platform}</span>
                  <div className="flex-1 bg-gray-100 rounded-full h-6 overflow-hidden">
                    <div className={`h-full ${row.color} rounded-full flex items-center px-2`} style={{ width: `${(row.impressions / totalImpressions) * 100}%` }}>
                      <span className="text-[10px] text-white font-medium">{row.impressions.toLocaleString('ar')}</span>
                    </div>
                  </div>
                  <span className="text-sm text-gray-600 w-20 text-left">{row.clicks.toLocaleString('ar')} نقرة</span>
                </div>
              ))}
            </div>
          </div>

          <button className="flex items-center gap-2 px-5 py-2.5 bg-white border border-gray-200 rounded-xl text-sm font-medium text-gray-700 hover:bg-gray-50">
            📥 تصدير التقرير (PDF)
          </button>
        </div>
      )}
    </div>
  );
}
