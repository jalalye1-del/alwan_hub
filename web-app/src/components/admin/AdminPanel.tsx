'use client';

import { useState } from 'react';
import AdminSidebar from './AdminSidebar';
import AdminDashboard from './AdminDashboard';
import AdminBroadcast from './AdminBroadcast';
import AdminPrograms from './AdminPrograms';
import AdminAdvertisements from './AdminAdvertisements';
import AdminUsers from './AdminUsers';
import AdminNotifications from './AdminNotifications';
import AdminReports from './AdminReports';
import AdminSettings from './AdminSettings';
import AdminPodcasts from './AdminPodcasts';
import AdminLounge from './AdminLounge';
import AdminSchedule from './AdminSchedule';

const tabs = [
  { id: 'dashboard', label: 'الرئيسية', icon: '📊' },
  { id: 'broadcast', label: 'إدارة البث', icon: '📡' },
  { id: 'programs', label: 'البرامج الإذاعية', icon: '🎙️' },
  { id: 'schedule', label: 'الجدول البرامجي', icon: '📅' },
  { id: 'podcasts', label: 'البودكاست', icon: '🎧' },
  { id: 'lounge', label: 'الاستراحة', icon: '🎵' },
  { id: 'advertisements', label: 'إدارة الإعلانات', icon: '📢' },
  { id: 'users', label: 'المستخدمون', icon: '👥' },
  { id: 'notifications', label: 'الإشعارات', icon: '🔔' },
  { id: 'reports', label: 'التقارير', icon: '📈' },
  { id: 'settings', label: 'الإعدادات', icon: '⚙️' },
];

export default function AdminPanel() {
  const [activeTab, setActiveTab] = useState('dashboard');
  const [sidebarOpen, setSidebarOpen] = useState(true);

  const renderContent = () => {
    switch (activeTab) {
      case 'dashboard': return <AdminDashboard />;
      case 'broadcast': return <AdminBroadcast />;
      case 'programs': return <AdminPrograms />;
      case 'schedule': return <AdminSchedule />;
      case 'podcasts': return <AdminPodcasts />;
      case 'lounge': return <AdminLounge />;
      case 'advertisements': return <AdminAdvertisements />;
      case 'users': return <AdminUsers />;
      case 'notifications': return <AdminNotifications />;
      case 'reports': return <AdminReports />;
      case 'settings': return <AdminSettings />;
      default: return <AdminDashboard />;
    }
  };

  return (
    <div className="flex min-h-[calc(100vh-4rem)]">
      <AdminSidebar
        tabs={tabs}
        activeTab={activeTab}
        onTabChange={setActiveTab}
        isOpen={sidebarOpen}
        onToggle={() => setSidebarOpen(!sidebarOpen)}
      />
      <div className={`flex-1 transition-all duration-300 ${sidebarOpen ? 'mr-64' : 'mr-16'}`}>
        <div className="p-6 lg:p-8">
          {renderContent()}
        </div>
      </div>
    </div>
  );
}
