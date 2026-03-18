import React from 'react';
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts';

export default function Chart({ data = [] }) {
  // Default data if none provided
  const chartData = data.length > 0 
    ? data 
    : [
        { date: 'Mon', revenue: 400 },
        { date: 'Tue', revenue: 300 },
        { date: 'Wed', revenue: 600 },
        { date: 'Thu', revenue: 800 },
        { date: 'Fri', revenue: 500 },
        { date: 'Sat', revenue: 900 },
        { date: 'Sun', revenue: 700 },
      ];

  return (
    <ResponsiveContainer width="100%" height={250}>
      <LineChart data={chartData}>
        <CartesianGrid strokeDasharray="3 3" stroke="#1f2937" />
        <XAxis 
          dataKey="date" 
          stroke="#6b7280"
          fontSize={12}
          tickLine={false}
        />
        <YAxis 
          stroke="#6b7280"
          fontSize={12}
          tickLine={false}
          tickFormatter={(value) => `$${value}`}
        />
        <Tooltip 
          contentStyle={{
            backgroundColor: '#12121A',
            border: '1px solid #374151',
            borderRadius: '8px'
          }}
          formatter={(value) => [`$${value}`, 'Revenue']}
        />
        <Line 
          type="monotone" 
          dataKey="revenue" 
          stroke="#D4AF37" 
          strokeWidth={2}
          dot={{ fill: '#D4AF37', strokeWidth: 0, r: 4 }}
          activeDot={{ r: 6, fill: '#F4D03F' }}
        />
      </LineChart>
    </ResponsiveContainer>
  );
}
