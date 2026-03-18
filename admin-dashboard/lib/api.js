// lib/api.js - API functions for admin dashboard
import { db } from './firebase';
import { 
  collection, 
  query, 
  getDocs, 
  getCountFromServer,
  where,
  orderBy,
  limit,
  Timestamp,
  doc,
  getDoc
} from 'firebase/firestore';

/**
 * Get dashboard statistics
 */
export async function getDashboardStats() {
  try {
    // Get total users count
    const usersRef = collection(db, 'users');
    const usersSnapshot = await getCountFromServer(usersRef);
    const totalUsers = usersSnapshot.data().count;

    // Get active subscribers (non-free tier)
    const subscribersQuery = query(
      collection(db, 'users'),
      where('membershipTier', 'in', ['seeker', 'initiate', 'master'])
    );
    const subscribersSnapshot = await getCountFromServer(subscribersQuery);
    const activeSubscribers = subscribersSnapshot.data().count;

    // Get users by tier
    const tiers = ['free', 'seeker', 'initiate', 'master'];
    const tierCounts = {};
    
    for (const tier of tiers) {
      const tierQuery = query(
        collection(db, 'users'),
        where('membershipTier', '==', tier)
      );
      const tierSnapshot = await getCountFromServer(tierQuery);
      tierCounts[tier] = tierSnapshot.data().count;
    }

    // Calculate MRR (Monthly Recurring Revenue)
    let mrr = 0;
    const subscribersDocs = await getDocs(subscribersQuery);
    subscribersDocs.forEach(doc => {
      const data = doc.data();
      const tier = data.membershipTier;
      if (tier === 'seeker') mrr += 19.99;
      else if (tier === 'initiate') mrr += 49.99;
      else if (tier === 'master') mrr += 199.99;
    });

    // Get recent signups (last 7 days)
    const sevenDaysAgo = new Date();
    sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);
    
    const recentSignupsQuery = query(
      collection(db, 'users'),
      where('createdAt', '>=', Timestamp.fromDate(sevenDaysAgo)),
      orderBy('createdAt', 'desc')
    );
    const recentSignupsSnapshot = await getCountFromServer(recentSignupsQuery);
    const recentSignups = recentSignupsSnapshot.data().count;

    return {
      totalUsers,
      activeSubscribers,
      mrr: Math.round(mrr * 100) / 100,
      tierCounts,
      recentSignups,
      conversionRate: totalUsers > 0 ? (activeSubscribers / totalUsers * 100).toFixed(1) : 0
    };
  } catch (error) {
    console.error('Error fetching dashboard stats:', error);
    throw error;
  }
}

/**
 * Get upcoming live sessions
 */
export async function getUpcomingSessions(limit_count = 5) {
  try {
    const now = Timestamp.now();
    const sessionsQuery = query(
      collection(db, 'live_sessions'),
      where('startDate', '>=', now),
      orderBy('startDate', 'asc'),
      limit(limit_count)
    );
    
    const snapshot = await getDocs(sessionsQuery);
    return snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data(),
      startDate: doc.data().startDate?.toDate()
    }));
  } catch (error) {
    console.error('Error fetching sessions:', error);
    throw error;
  }
}

/**
 * Get recent user activity
 */
export async function getRecentActivity(limit_count = 10) {
  try {
    const activityQuery = query(
      collection(db, 'analytics', 'activity', 'events'),
      orderBy('timestamp', 'desc'),
      limit(limit_count)
    );
    
    const snapshot = await getDocs(activityQuery);
    return snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data(),
      timestamp: doc.data().timestamp?.toDate()
    }));
  } catch (error) {
    console.error('Error fetching activity:', error);
    // Return empty array if collection doesn't exist yet
    return [];
  }
}

/**
 * Get users list with pagination
 */
export async function getUsers(page = 1, perPage = 20, filters = {}) {
  try {
    let usersQuery = query(
      collection(db, 'users'),
      orderBy('createdAt', 'desc'),
      limit(perPage)
    );

    // Apply filters
    if (filters.tier) {
      usersQuery = query(
        collection(db, 'users'),
        where('membershipTier', '==', filters.tier),
        orderBy('createdAt', 'desc'),
        limit(perPage)
      );
    }

    const snapshot = await getDocs(usersQuery);
    
    return snapshot.docs.map(doc => {
      const data = doc.data();
      return {
        id: doc.id,
        email: data.email,
        fullName: data.fullName,
        membershipTier: data.membershipTier,
        createdAt: data.createdAt?.toDate(),
        lastActiveAt: data.lastActiveAt?.toDate(),
        role: data.role
      };
    });
  } catch (error) {
    console.error('Error fetching users:', error);
    throw error;
  }
}

/**
 * Get revenue data for charts
 */
export async function getRevenueData(days = 30) {
  try {
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - days);
    
    // This would require a payments/subscriptions collection
    // For now, return mock data structure
    const data = [];
    for (let i = days; i >= 0; i--) {
      const date = new Date();
      date.setDate(date.getDate() - i);
      data.push({
        date: date.toISOString().split('T')[0],
        revenue: 0 // Would be populated from actual payment data
      });
    }
    
    return data;
  } catch (error) {
    console.error('Error fetching revenue data:', error);
    throw error;
  }
}

/**
 * Update user data
 */
export async function updateUser(userId, updates) {
  try {
    const { updateDoc, doc } = await import('firebase/firestore');
    const userRef = doc(db, 'users', userId);
    await updateDoc(userRef, {
      ...updates,
      updatedAt: Timestamp.now()
    });
    return { success: true };
  } catch (error) {
    console.error('Error updating user:', error);
    throw error;
  }
}

/**
 * Create live session
 */
export async function createLiveSession(sessionData) {
  try {
    const { addDoc, collection, Timestamp } = await import('firebase/firestore');
    const sessionRef = collection(db, 'live_sessions');
    
    await addDoc(sessionRef, {
      ...sessionData,
      createdAt: Timestamp.now(),
      reminderSent: false
    });
    
    return { success: true };
  } catch (error) {
    console.error('Error creating session:', error);
    throw error;
  }
}

/**
 * Delete live session
 */
export async function deleteLiveSession(sessionId) {
  try {
    const { deleteDoc, doc } = await import('firebase/firestore');
    await deleteDoc(doc(db, 'live_sessions', sessionId));
    return { success: true };
  } catch (error) {
    console.error('Error deleting session:', error);
    throw error;
  }
}

/**
 * Send custom notification to users
 */
export async function sendCustomNotification(userIds, title, body, data = {}) {
  try {
    const { httpsCallable } = await import('firebase/functions');
    const { getFunctions } = await import('firebase/functions');
    const { app } = await import('./firebase');
    
    const functions = getFunctions(app);
    const sendNotification = httpsCallable(functions, 'sendCustomNotification');
    
    const result = await sendNotification({
      userIds,
      title,
      body,
      data
    });
    
    return result.data;
  } catch (error) {
    console.error('Error sending notification:', error);
    throw error;
  }
}
