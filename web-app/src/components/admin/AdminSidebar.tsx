'use client';

interface Tab {
  id: string;
  label: string;
  icon: string;
}

interface Props {
  tabs: Tab[];
  activeTab: string;
  onTabChange: (tab: string) => void;
  isOpen: boolean;
  onToggle: () => void;
}

export default function AdminSidebar({ tabs, activeTab, onTabChange, isOpen, onToggle }: Props) {
  return (
    <aside className={`fixed top-16 right-0 bottom-20 bg-white border-l border-gray-200 z-40 transition-all duration-300 ${isOpen ? 'w-64' : 'w-16'}`}>
      <div className="flex flex-col h-full">
        <button
          onClick={onToggle}
          className="p-4 text-gray-400 hover:text-gray-600 border-b border-gray-100"
        >
          {isOpen ? '◀' : '▶'}
        </button>
        <nav className="flex-1 overflow-y-auto py-2">
          {tabs.map((tab) => (
            <button
              key={tab.id}
              onClick={() => onTabChange(tab.id)}
              className={`w-full flex items-center gap-3 px-4 py-3 text-sm font-medium transition-colors ${
                activeTab === tab.id
                  ? 'bg-alwan-primary/10 text-alwan-primary border-r-3 border-alwan-primary'
                  : 'text-gray-600 hover:bg-gray-50 hover:text-gray-900'
              }`}
            >
              <span className="text-lg flex-shrink-0">{tab.icon}</span>
              {isOpen && <span className="truncate">{tab.label}</span>}
            </button>
          ))}
        </nav>
        {isOpen && (
          <div className="p-4 border-t border-gray-100">
            <div className="bg-gradient-to-br from-alwan-primary to-alwan-secondary rounded-xl p-4 text-white">
              <div className="text-sm font-bold mb-1">ألوان هَب</div>
              <div className="text-xs opacity-80">لوحة التحكم v1.0</div>
            </div>
          </div>
        )}
      </div>
    </aside>
  );
}
