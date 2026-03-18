import React from 'react';
import { Video, Calendar, Users } from 'lucide-react';

export default function UpcomingSessions({ sessions = [] }) {
  const formatDate = (date) => {
    if (!date) return 'TBD';
    const d = new Date(date);
    return d.toLocaleDateString('en-US', { 
      month: 'short', 
      day: 'numeric',
      hour: 'numeric',
      minute: '2-digit'
    });
  };

  return (
    <div className="bg-[#12121A] rounded-xl p-6 border border-gray-800">
      <div className="flex items-center justify-between mb-4">
        <h3 className="text-lg font-medium">Upcoming Live Sessions</h3>
        <button className="text-[#D4AF37] text-sm hover:underline">
          View All
        </button>
      </div>

      <div className="space-y-4">
        {sessions.length === 0 ? (
          <div className="text-center py-8 text-gray-500">
            <Video className="w-12 h-12 mx-auto mb-3 opacity-50" />
            <p>No upcoming sessions scheduled</p>
            <button className="mt-3 text-[#D4AF37] text-sm hover:underline">
              Schedule a session
            </button>
          </div>
        ) : (
          sessions.map((session) => (
            <div 
              key={session.id} 
              className="flex items-start gap-4 p-4 bg-[#0A0A0F] rounded-lg border border-gray-800 hover:border-[#D4AF37]/30 transition-colors"
            >
              <div className="w-12 h-12 rounded-lg bg-[#D4AF37]/10 flex items-center justify-center flex-shrink-0">
                <Video className="w-6 h-6 text-[#D4AF37]" />
              </div>
              
              <div className="flex-1 min-w-0">
                <h4 className="font-medium text-white truncate">
                  {session.title || 'Untitled Session'}
                </h4>
                
                <div className="flex items-center gap-4 mt-1 text-sm text-gray-400">
                  <span className="flex items-center gap-1">
                    <Calendar className="w-4 h-4" />
                    {formatDate(session.startDate)}
                  </span>
                  
                  {session.registrations && (
                    <span className="flex items-center gap-1">
                      <Users className="w-4 h-4" />
                      {session.registrations} registered
                    </span>
                  )}
                </div>

                {session.tierRequirement && (
                  <span className={`inline-block mt-2 px-2 py-1 text-xs rounded-full ${
                    session.tierRequirement === 'free' 
                      ? 'bg-green-500/20 text-green-400'
                      : 'bg-[#D4AF37]/20 text-[#D4AF37]'
                  }`}>
                    {session.tierRequirement === 'free' ? 'Free' : session.tierRequirement}
                  </span>
                )}
              </div>
            </div>
          ))
        )}
      </div>
    </div>
  );
}
