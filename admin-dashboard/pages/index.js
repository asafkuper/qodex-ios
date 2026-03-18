import React, { useState, useEffect } from 'react';
import Head from 'next/head';
import Sidebar from '../components/Sidebar';
import StatCard from '../components/StatCard';
import Chart from '../components/Chart';
import RecentActivity from '../components/RecentActivity';
import UpcomingSessions from '../components/UpcomingSessions';
import { getDashboardStats, getUpcomingSessions, getRecentActivity } from '../lib/api';
import { useAdminAuth } from '../lib/auth';
import { useRouter } from 'next/router';

export default function Dashboard() {
  const router = useRouter();
  const { user, isAdmin, loading: authLoading } = useAdminAuth();
  const [stats, setStats] = useState(null);
  const [sessions, setSessions] = useState([]);
  const [activity, setActivity] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    if (!authLoading && !isAdmin) {
      router.push('/login');
    }
  }, [authLoading, isAdmin, router]);

  useEffect(() => {
    if (isAdmin) {
      loadDashboardData();
    }
  }, [isAdmin]);

  async function loadDashboardData() {
    try {
      setLoading(true);
      const [statsData, sessionsData, activityData] = await Promise.all([
        getDashboardStats(),
        getUpcomingSessions(3),
        getRecentActivity(5)
      ]);
      
      setStats(statsData);
      setSessions(sessionsData);
      setActivity(activityData);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  }

  if (authLoading || loading) {
    return (
      <div className="min-h-screen bg-[#0A0A0F] text-white">
        <Sidebar />
        <main className="ml-64 p-8">
          <div className="flex items-center justify-center h-96">
            <div className="text-center">
              <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-[#D4AF37] mx-auto mb-4"></div>
              <p className="text-gray-400">Loading dashboard...</p>
            </div>
          </div>
        </main>
      </div>
    );
  }

  if (error) {
    return (
      <div className="min-h-screen bg-[#0A0A0F] text-white">
        <Sidebar />
        <main className="ml-64 p-8">
          <div className="bg-red-900/20 border border-red-800 rounded-xl p-6">
            <h3 className="text-red-400 font-semibold mb-2">Error Loading Dashboard</h3>
            <p className="text-red-300">{error}</p>
            <button 
              onClick={loadDashboardData}
              className="mt-4 px-4 py-2 bg-red-600 hover:bg-red-700 rounded-lg transition-colors"
            >
              Retry
            </button>
          </div>
        </main>
      </div>
    );
  }

  // Calculate next session display
  const nextSessionDisplay = sessions.length > 0 
    ? formatTimeUntil(sessions[0].startDate)
    : { value: 'No sessions', change: 'Schedule one' };

  return (
    <div className="min-h-screen bg-[#0A0A0F] text-white">
      <Head>
        <title>QodeX Admin | Dashboard</title>
      </Head>
      
      <Sidebar />
      
      <main className="ml-64 p-8">
        {/* Header */}
        <div className="mb-8">
          <h1 className="text-3xl font-light mb-2">
            Welcome back, {user?.fullName || 'Shani'}
          </h1>
          <p className="text-gray-400">Here's what's happening with your Inner Circle</p>
        </div>

        {/* Stats Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
          <StatCard 
            title="Total Users" 
            value={stats?.totalUsers?.toLocaleString() || '0'} 
            change={`+${stats?.recentSignups || 0} this week`}
            trend="up"
            icon="Users"
          />
          <StatCard 
            title="Active Subscribers" 
            value={stats?.activeSubscribers?.toLocaleString() || '0'} 
            change={`${stats?.conversionRate || 0}% conversion`}
            trend="up"
            icon="Crown"
          />
          <StatCard 
            title="MRR" 
            value={`$${Math.round(stats?.mrr || 0).toLocaleString()}`} 
            change="Monthly recurring"
            trend="neutral"
            icon="DollarSign"
          />
          <StatCard 
            title="Next Live Session" 
            value={nextSessionDisplay.value}
            change={nextSessionDisplay.change}
            trend="neutral"
            icon="Video"
          />
        </div>

        {/* Charts Row */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8">
          <div className="bg-[#12121A] rounded-xl p-6 border border-gray-800">
            <h3 className="text-lg font-medium mb-4">Revenue Growth</h3>
            <Chart data={stats?.revenueData || []} />
          </div>
          
          <div className="bg-[#12121A] rounded-xl p-6 border border-gray-800">
            <h3 className="text-lg font-medium mb-4">User Distribution by Tier</h3>
            <div className="space-y-4">
              <TierProgress 
                tier="Free" 
                count={stats?.tierCounts?.free || 0} 
                total={stats?.totalUsers || 1}
                color="#6B7280" 
              />
              <TierProgress 
                tier="Seeker" 
                count={stats?.tierCounts?.seeker || 0} 
                total={stats?.totalUsers || 1}
                color="#D4AF37" 
              />
              <TierProgress 
                tier="Initiate" 
                count={stats?.tierCounts?.initiate || 0} 
                total={stats?.totalUsers || 1}
                color="#F4D03F" 
              />
              <TierProgress 
                tier="Master" 
                count={stats?.tierCounts?.master || 0} 
                total={stats?.totalUsers || 1}
                color="#FFD700" 
              />
            </div>
          </div>
        </div>

        {/* Bottom Row */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <UpcomingSessions sessions={sessions} />
          <RecentActivity activity={activity} />
        </div>
      </main>
    </div>
  );
}

function TierProgress({ tier, count, total, color }) {
  const percentage = Math.round((count / total) * 100);
  
  return (
    <div>
      <div className="flex justify-between mb-1">
        <span className="text-sm text-gray-300">{tier}</span>
        <span className="text-sm text-gray-400">{count.toLocaleString()} ({percentage}%)</span>
      </div>
      <div className="h-2 bg-gray-800 rounded-full overflow-hidden">
        <div 
          className="h-full rounded-full transition-all duration-500"
          style={{ width: `${percentage}%`, backgroundColor: color }}
        />
      </div>
    </div>
  );
}

function formatTimeUntil(date) {
  if (!date) return { value: 'No sessions', change: 'Schedule one' };
  
  const now = new Date();
  const diff = date - now;
  const days = Math.floor(diff / (1000 * 60 * 60 * 24));
  const hours = Math.floor((diff % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
  
  if (days > 0) {
    return { value: `${days} days`, change: date.toLocaleDateString('en-US', { weekday: 'short', hour: 'numeric' }) };
  } else if (hours > 0) {
    return { value: `${hours} hours`, change: 'Coming up soon' };
  } else {
    return { value: 'Starting', change: 'Now!' };
  }
}
