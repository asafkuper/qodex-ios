import React from 'react';
import { UserPlus, Crown, MessageSquare, BookOpen } from 'lucide-react';

export default function RecentActivity({ activity = [] }) {
  const getIcon = (type) => {
    switch (type) {
      case 'signup':
        return <UserPlus className="w-4 h-4" />;
      case 'subscription':
        return <Crown className="w-4 h-4" />;
      case 'post':
        return <MessageSquare className="w-4 h-4" />;
      case 'content':
        return <BookOpen className="w-4 h-4" />;
      default:
        return <UserPlus className="w-4 h-4" />;
    }
  };

  const getColor = (type) => {
    switch (type) {
      case 'signup':
        return 'bg-blue-500/20 text-blue-400';
      case 'subscription':
        return 'bg-[#D4AF37]/20 text-[#D4AF37]';
      case 'post':
        return 'bg-green-500/20 text-green-400';
      case 'content':
        return 'bg-purple-500/20 text-purple-400';
      default:
        return 'bg-gray-500/20 text-gray-400';
    }
  };

  const formatTime = (date) => {
    if (!date) return 'Just now';
    const now = new Date();
    const diff = now - new Date(date);
    const minutes = Math.floor(diff / 60000);
    const hours = Math.floor(diff / 3600000);
    const days = Math.floor(diff / 86400000);

    if (minutes < 1) return 'Just now';
    if (minutes < 60) return `${minutes}m ago`;
    if (hours < 24) return `${hours}h ago`;
    if (days < 7) return `${days}d ago`;
    return new Date(date).toLocaleDateString('en-US', { month: 'short', day: 'numeric' });
  };

  // Default mock data if no activity
  const defaultActivity = [
    { id: 1, type: 'signup', message: 'New user joined: Sarah M.', timestamp: new Date(Date.now() - 1000 * 60 * 5) },
    { id: 2, type: 'subscription', message: 'User upgraded to Seeker', timestamp: new Date(Date.now() - 1000 * 60 * 15) },
    { id: 3, type: 'post', message: 'New community post in Numerology', timestamp: new Date(Date.now() - 1000 * 60 * 30) },
  ];

  const displayActivity = activity.length > 0 ? activity : defaultActivity;

  return (
    <div className="bg-[#12121A] rounded-xl p-6 border border-gray-800">
      <div className="flex items-center justify-between mb-4">
        <h3 className="text-lg font-medium">Recent Activity</h3>
        <button className="text-[#D4AF37] text-sm hover:underline">
          View All
        </button>
      </div>

      <div className="space-y-3">
        {displayActivity.map((item) => (
          <div key={item.id} className="flex items-center gap-3">
            <div className={`w-8 h-8 rounded-full flex items-center justify-center ${getColor(item.type)}`}>
              {getIcon(item.type)}
            </div>
            
            <div className="flex-1 min-w-0">
              <p className="text-sm text-gray-300 truncate">{item.message || item.title || 'Activity'}</p>
            </div>
            
            <span className="text-xs text-gray-500 flex-shrink-0">
              {formatTime(item.timestamp)}
            </span>
          </div>
        ))}
      </div>
    </div>
  );
}
