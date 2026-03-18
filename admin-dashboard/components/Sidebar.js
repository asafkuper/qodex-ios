import React from 'react';
import Link from 'next/link';
import { useRouter } from 'next/router';
import { 
  LayoutDashboard, 
  Calendar, 
  Video, 
  Users, 
  FileText, 
  MessageCircle,
  Settings,
  LogOut,
  Sparkles
} from 'lucide-react';
import { useAdminAuth } from '../lib/auth';

const navItems = [
  { href: '/', label: 'Dashboard', icon: LayoutDashboard },
  { href: '/sessions', label: 'Live Sessions', icon: Video },
  { href: '/content', label: 'Content', icon: FileText },
  { href: '/users', label: 'Users', icon: Users },
  { href: '/community', label: 'Community', icon: MessageCircle },
  { href: '/calendar', label: 'Calendar', icon: Calendar },
  { href: '/settings', label: 'Settings', icon: Settings },
];

export default function Sidebar() {
  const router = useRouter();
  const { user, logout } = useAdminAuth();

  const handleLogout = async () => {
    await logout();
    router.push('/login');
  };

  return (
    <aside className="fixed left-0 top-0 h-full w-64 bg-[#12121A] border-r border-gray-800 z-50">
      {/* Logo */}
      <div className="p-6 border-b border-gray-800">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-[#D4AF37] to-[#F4D03F] flex items-center justify-center">
            <Sparkles className="w-5 h-5 text-black" />
          </div>
          <div>
            <h2 className="font-bold text-lg">QodeX</h2>
            <p className="text-xs text-gray-400">Admin</p>
          </div>
        </div>
      </div>

      {/* Navigation */}
      <nav className="p-4">
        <ul className="space-y-1">
          {navItems.map((item) => {
            const Icon = item.icon;
            const isActive = router.pathname === item.href;
            const isImplemented = ['/', '/sessions'].includes(item.href);
            
            return (
              <li key={item.href}>
                {isImplemented ? (
                  <Link
                    href={item.href}
                    className={`
                      flex items-center gap-3 px-4 py-3 rounded-lg transition-colors
                      ${isActive 
                        ? 'bg-[#D4AF37]/10 text-[#D4AF37] border border-[#D4AF37]/20' 
                        : 'text-gray-400 hover:text-white hover:bg-white/5'
                      }
                    `}
                  >
                    <Icon className="w-5 h-5" />
                    <span>{item.label}</span>
                  </Link>
                ) : (
                  <div
                    className="flex items-center gap-3 px-4 py-3 rounded-lg text-gray-600 cursor-not-allowed"
                    title="Coming soon"
                  >
                    <Icon className="w-5 h-5" />
                    <span>{item.label}</span>
                    <span className="ml-auto text-xs bg-gray-800 px-2 py-0.5 rounded">Soon</span>
                  </div>
                )}
              </li>
            );
          })}
        </ul>
      </nav>

      {/* User Profile */}
      <div className="absolute bottom-0 left-0 right-0 p-4 border-t border-gray-800">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 rounded-full bg-gradient-to-br from-purple-500 to-pink-500 flex items-center justify-center text-sm font-bold">
            {user?.fullName?.charAt(0) || user?.email?.charAt(0) || 'A'}
          </div>
          <div className="flex-1 min-w-0">
            <p className="text-sm font-medium truncate">{user?.fullName || user?.email || 'Admin'}</p>
            <p className="text-xs text-gray-400">{user?.role || 'Administrator'}</p>
          </div>
          <button 
            onClick={handleLogout}
            className="text-gray-400 hover:text-white transition-colors"
            title="Logout"
          >
            <LogOut className="w-5 h-5" />
          </button>
        </div>
      </div>
    </aside>
  );
}
