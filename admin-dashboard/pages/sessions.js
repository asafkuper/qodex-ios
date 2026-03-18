import React, { useState } from 'react';
import Head from 'next/head';
import Sidebar from '../components/Sidebar';
import { Plus, Calendar, Clock, Users, Video, MoreVertical, Edit2, Trash2, Copy } from 'lucide-react';

const mockSessions = [
  {
    id: 1,
    title: 'Decode Your Chart Live',
    date: '2026-03-12',
    time: '20:00',
    duration: '60 min',
    type: 'Live Reading',
    attendees: 45,
    maxAttendees: 100,
    status: 'scheduled',
    description: 'Bring your birth date and time for live chart decoding.',
  },
  {
    id: 2,
    title: 'Master Numbers Deep Dive',
    date: '2026-03-19',
    time: '19:00',
    duration: '90 min',
    type: 'Teaching',
    attendees: 0,
    maxAttendees: 150,
    status: 'scheduled',
    description: 'Understanding 11, 22, 33 in your chart.',
  },
  {
    id: 3,
    title: 'Q&A with Shani',
    date: '2026-03-26',
    time: '20:00',
    duration: '60 min',
    type: 'Q&A',
    attendees: 0,
    maxAttendees: 200,
    status: 'draft',
    description: 'Open Q&A session.',
  },
];

export default function Sessions() {
  const [sessions, setSessions] = useState(mockSessions);
  const [showModal, setShowModal] = useState(false);

  return (
    <div className="min-h-screen bg-[#0A0A0F] text-white">
      <Head>
        <title>QodeX Admin | Live Sessions</title>
      </Head>

      <Sidebar />

      <main className="ml-64 p-8">
        {/* Header */}
        <div className="flex justify-between items-center mb-8">
          <div>
            <h1 className="text-3xl font-light mb-2">Live Sessions</h1>
            <p className="text-gray-400">Schedule and manage your live events</p>
          </div>
          
          <button
            onClick={() => setShowModal(true)}
            className="flex items-center gap-2 px-6 py-3 bg-[#D4AF37] text-black rounded-lg font-medium hover:bg-[#F4D03F] transition-colors"
          >
            <Plus className="w-5 h-5" />
            New Session
          </button>
        </div>

        {/* Stats */}
        <div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
          <StatBox label="Total Sessions" value="24" />
          <StatBox label="This Month" value="4" />
          <StatBox label="Total Attendees" value="1,247" />
          <StatBox label="Avg. Attendance" value="52" />
        </div>

        {/* Sessions List */}
        <div className="bg-[#12121A] rounded-xl border border-gray-800 overflow-hidden">
          <div className="p-6 border-b border-gray-800">
            <h2 className="text-xl font-medium">Upcoming Sessions</h2>
          </div>

          <div className="divide-y divide-gray-800">
            {sessions.map((session) => (
              <div key={session.id} className="p-6 hover:bg-white/5 transition-colors">
                <div className="flex items-start justify-between">
                  <div className="flex-1">
                    <div className="flex items-center gap-3 mb-2">
                      <h3 className="text-lg font-medium">{session.title}</h3>
                      <StatusBadge status={session.status} />
                    </div>
                    
                    <p className="text-gray-400 mb-4">{session.description}</p>
                    
                    <div className="flex items-center gap-6 text-sm text-gray-400">
                      <div className="flex items-center gap-2">
                        <Calendar className="w-4 h-4" />
                        {session.date}
                      </div>
                      <div className="flex items-center gap-2">
                        <Clock className="w-4 h-4" />
                        {session.time} ({session.duration})
                      </div>
                      <div className="flex items-center gap-2">
                        <Video className="w-4 h-4" />
                        {session.type}
                      </div>
                      <div className="flex items-center gap-2">
                        <Users className="w-4 h-4" />
                        {session.attendees} / {session.maxAttendees}
                      </div>
                    </div>
                  </div>

                  <div className="flex items-center gap-2">
                    <button className="p-2 text-gray-400 hover:text-white hover:bg-white/10 rounded-lg transition-colors">
                      <Edit2 className="w-4 h-4" />
                    </button>
                    <button className="p-2 text-gray-400 hover:text-white hover:bg-white/10 rounded-lg transition-colors">
                      <Copy className="w-4 h-4" />
                    </button>
                    <button className="p-2 text-gray-400 hover:text-red-400 hover:bg-red-500/10 rounded-lg transition-colors">
                      <Trash2 className="w-4 h-4" />
                    </button>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </main>
    </div>
  );
}

function StatBox({ label, value }) {
  return (
    <div className="bg-[#12121A] rounded-xl p-4 border border-gray-800">
      <p className="text-2xl font-bold text-[#D4AF37]">{value}</p>
      <p className="text-sm text-gray-400">{label}</p>
    </div>
  );
}

function StatusBadge({ status }) {
  const colors = {
    scheduled: 'bg-green-500/20 text-green-400 border-green-500/30',
    draft: 'bg-yellow-500/20 text-yellow-400 border-yellow-500/30',
    live: 'bg-red-500/20 text-red-400 border-red-500/30',
    ended: 'bg-gray-500/20 text-gray-400 border-gray-500/30',
  };

  return (
    <span className={`px-3 py-1 text-xs rounded-full border ${colors[status] || colors.draft}`}>
      {status.charAt(0).toUpperCase() + status.slice(1)}
    </span>
  );
}
