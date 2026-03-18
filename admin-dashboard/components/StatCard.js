import React from 'react';
import { Users, Crown, DollarSign, Video, TrendingUp, TrendingDown, Minus } from 'lucide-react';

const iconMap = {
  Users,
  Crown,
  DollarSign,
  Video
};

export default function StatCard({ title, value, change, trend, icon }) {
  const Icon = iconMap[icon] || Users;
  
  const getTrendIcon = () => {
    switch (trend) {
      case 'up':
        return <TrendingUp className="w-4 h-4 text-green-400" />;
      case 'down':
        return <TrendingDown className="w-4 h-4 text-red-400" />;
      default:
        return <Minus className="w-4 h-4 text-gray-400" />;
    }
  };

  const getTrendColor = () => {
    switch (trend) {
      case 'up':
        return 'text-green-400';
      case 'down':
        return 'text-red-400';
      default:
        return 'text-gray-400';
    }
  };

  return (
    <div className="bg-[#12121A] rounded-xl p-6 border border-gray-800">
      <div className="flex items-start justify-between">
        <div>
          <p className="text-sm text-gray-400 mb-1">{title}</p>
          <p className="text-2xl font-bold text-white">{value}</p>
          
          <div className="flex items-center gap-1 mt-2">
            {getTrendIcon()}
            <span className={`text-sm ${getTrendColor()}`}>{change}</span>
          </div>
        </div>
        
        <div className="w-12 h-12 rounded-xl bg-[#D4AF37]/10 flex items-center justify-center">
          <Icon className="w-6 h-6 text-[#D4AF37]" />
        </div>
      </div>
    </div>
  );
}
