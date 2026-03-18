//
//  Firebase Cloud Functions for QodeX Push Notifications
//  Deploy with: firebase deploy --only functions
//

const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

const db = admin.firestore();
const messaging = admin.messaging();

// ==================== SCHEDULED FUNCTIONS ====================

/**
 * Send daily Qode notifications to all active members
 * Runs every day at 8:00 AM in user's local timezone
 */
exports.sendDailyQode = functions.pubsub
  .schedule('0 8 * * *')
  .timeZone('America/New_York')
  .onRun(async (context) => {
    const usersSnapshot = await db
      .collection('users')
      .where('notifications.dailyQode', '==', true)
      .get();
    
    const tokens = [];
    usersSnapshot.forEach(doc => {
      const user = doc.data();
      if (user.fcmToken) {
        tokens.push(user.fcmToken);
      }
    });
    
    if (tokens.length === 0) return null;
    
    const message = {
      tokens: tokens,
      notification: {
        title: '✨ Your Daily Qode is Ready',
        body: 'Discover what the numbers reveal for you today.'
      },
      data: {
        type: 'daily_qode',
        click_action: 'OPEN_DAILY_QODE'
      },
      apns: {
        payload: {
          aps: {
            badge: 1,
            sound: 'default'
          }
        }
      }
    };
    
    const response = await messaging.sendEachForMulticast(message);
    console.log(`Sent daily Qode to ${response.successCount} users`);
    
    // Store notification in Firestore for in-app history
    const batch = db.batch();
    usersSnapshot.forEach(doc => {
      const notifRef = db.collection('users').doc(doc.id).collection('notifications').doc();
      batch.set(notifRef, {
        type: 'daily_qode',
        title: 'Your Daily Qode is Ready',
        body: 'Discover what the numbers reveal for you today.',
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        isRead: false
      });
    });
    await batch.commit();
    
    return null;
  });

/**
 * Send weekly report every Sunday at 9 AM
 */
exports.sendWeeklyReport = functions.pubsub
  .schedule('0 9 * * 0')
  .timeZone('America/New_York')
  .onRun(async (context) => {
    const usersSnapshot = await db
      .collection('users')
      .where('notifications.weeklyReport', '==', true)
      .get();
    
    const tokens = [];
    usersSnapshot.forEach(doc => {
      const user = doc.data();
      if (user.fcmToken) tokens.push(user.fcmToken);
    });
    
    if (tokens.length === 0) return null;
    
    const message = {
      tokens: tokens,
      notification: {
        title: '📊 Your Weekly Qode Report',
        body: 'See how your numbers aligned this week and what\'s coming next.'
      },
      data: {
        type: 'weekly_report',
        click_action: 'OPEN_WEEKLY_REPORT'
      }
    };
    
    await messaging.sendEachForMulticast(message);
    return null;
  });

// ==================== TRIGGERED FUNCTIONS ====================

/**
 * Notify users when a new live session is scheduled
 */
exports.notifyNewLiveSession = functions.firestore
  .document('live_sessions/{sessionId}')
  .onCreate(async (snap, context) => {
    const session = snap.data();
    const tier = session.tierRequirement || 'all_members';
    
    // Get users subscribed to this tier
    const usersSnapshot = await db
      .collection('users')
      .where('notifications.liveSessions', '==', true)
      .get();
    
    const tokens = [];
    usersSnapshot.forEach(doc => {
      const user = doc.data();
      // Check if user has access to this tier
      if (user.fcmToken && hasTierAccess(user.membershipTier, tier)) {
        tokens.push(user.fcmToken);
      }
    });
    
    if (tokens.length === 0) return null;
    
    const message = {
      tokens: tokens,
      notification: {
        title: '📅 New Live Session Scheduled',
        body: `${session.title} with ${session.hostName}`
      },
      data: {
        type: 'live_session',
        session_id: context.params.sessionId,
        click_action: 'OPEN_LIVE_SESSION'
      }
    };
    
    await messaging.sendEachForMulticast(message);
    return null;
  });

/**
 * Send reminder 15 minutes before live session starts
 */
exports.remindLiveSession = functions.pubsub
  .schedule('*/5 * * * *') // Check every 5 minutes
  .onRun(async (context) => {
    const now = admin.firestore.Timestamp.now();
    const fifteenMinutes = new Date(now.toMillis() + 15 * 60 * 1000);
    
    const sessionsSnapshot = await db
      .collection('live_sessions')
      .where('startDate', '<=', fifteenMinutes)
      .where('reminderSent', '!=', true)
      .get();
    
    const promises = sessionsSnapshot.docs.map(async (doc) => {
      const session = doc.data();
      
      // Get registered users
      const registrationsSnapshot = await db
        .collection('live_sessions')
        .doc(doc.id)
        .collection('registrations')
        .get();
      
      const tokens = [];
      registrationsSnapshot.forEach(regDoc => {
        const reg = regDoc.data();
        if (reg.fcmToken) tokens.push(reg.fcmToken);
      });
      
      if (tokens.length > 0) {
        const message = {
          tokens: tokens,
          notification: {
            title: '🔴 Live Session Starting Soon',
            body: `${session.title} begins in 15 minutes`
          },
          data: {
            type: 'live_session_reminder',
            session_id: doc.id
          }
        };
        
        await messaging.sendEachForMulticast(message);
      }
      
      // Mark reminder as sent
      await doc.ref.update({ reminderSent: true });
    });
    
    await Promise.all(promises);
    return null;
  });

/**
 * Notify when new teaching is published
 */
exports.notifyNewTeaching = functions.firestore
  .document('teachings/{teachingId}')
  .onCreate(async (snap, context) => {
    const teaching = snap.data();
    
    const usersSnapshot = await db
      .collection('users')
      .where('notifications.newTeachings', '==', true)
      .get();
    
    const tokens = [];
    usersSnapshot.forEach(doc => {
      const user = doc.data();
      if (user.fcmToken && hasTierAccess(user.membershipTier, teaching.requiredTier)) {
        tokens.push(user.fcmToken);
      }
    });
    
    if (tokens.length === 0) return null;
    
    const message = {
      tokens: tokens,
      notification: {
        title: '📚 New Teaching Available',
        body: `${teaching.title} by ${teaching.instructorName}`
      },
      data: {
        type: 'new_teaching',
        teaching_id: context.params.teachingId
      }
    };
    
    await messaging.sendEachForMulticast(message);
    return null;
  });

/**
 * Notify user when someone replies to their post
 */
exports.notifyCommunityReply = functions.firestore
  .document('topics/{topicId}/replies/{replyId}')
  .onCreate(async (snap, context) => {
    const reply = snap.data();
    const topicId = context.params.topicId;
    
    // Get topic author
    const topicDoc = await db.collection('topics').doc(topicId).get();
    const topic = topicDoc.data();
    
    if (!topic || topic.authorId === reply.authorId) return null;
    
    // Get author's FCM token
    const authorDoc = await db.collection('users').doc(topic.authorId).get();
    const author = authorDoc.data();
    
    if (!author?.fcmToken || !author.notifications?.communityReplies) return null;
    
    const message = {
      token: author.fcmToken,
      notification: {
        title: '💬 New Reply',
        body: `${reply.authorName} replied to your post`
      },
      data: {
        type: 'community_reply',
        topic_id: topicId,
        reply_id: context.params.replyId
      }
    };
    
    await messaging.send(message);
    
    // Store in notification history
    await db.collection('users').doc(topic.authorId).collection('notifications').add({
      type: 'community_reply',
      title: 'New Reply',
      body: `${reply.authorName} replied to "${topic.title}"`,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      isRead: false,
      metadata: {
        topicId: topicId,
        replyId: context.params.replyId
      }
    });
    
    return null;
  });

/**
 * Welcome new subscriber
 */
exports.welcomeNewSubscriber = functions.firestore
  .document('users/{userId}')
  .onUpdate(async (change, context) => {
    const newData = change.after.data();
    const oldData = change.before.data();
    
    // Check if tier upgraded from free
    if (oldData.membershipTier === 'free' && newData.membershipTier !== 'free') {
      if (!newData.fcmToken) return null;
      
      const tierNames = {
        'seeker': 'Inner Circle',
        'initiate': 'Qode Initiate',
        'master': 'Qode Master'
      };
      
      const message = {
        token: newData.fcmToken,
        notification: {
          title: '🎉 Welcome to the Inner Circle',
          body: `You're now a ${tierNames[newData.membershipTier]}. Your journey begins!`
        },
        data: {
          type: 'welcome_subscriber'
        }
      };
      
      await messaging.send(message);
      
      // Send follow-up tips after 24 hours
      await scheduleWelcomeTips(context.params.userId);
    }
    
    return null;
  });

/**
 * Membership expiry warning
 */
exports.membershipExpiryWarning = functions.pubsub
  .schedule('0 10 * * *')
  .onRun(async (context) => {
    const now = admin.firestore.Timestamp.now();
    const threeDaysFromNow = new Date(now.toMillis() + 3 * 24 * 60 * 60 * 1000);
    
    const usersSnapshot = await db
      .collection('users')
      .where('membershipExpiry', '<=', threeDaysFromNow)
      .where('membershipExpiry', '>', now)
      .where('expiryWarningSent', '!=', true)
      .get();
    
    const promises = usersSnapshot.docs.map(async (doc) => {
      const user = doc.data();
      if (!user.fcmToken) return;
      
      const daysLeft = Math.ceil((user.membershipExpiry.toMillis() - now.toMillis()) / (24 * 60 * 60 * 1000));
      
      const message = {
        token: user.fcmToken,
        notification: {
          title: '⏰ Membership Expiring Soon',
          body: `Your Inner Circle access expires in ${daysLeft} days. Renew to keep your journey going.`
        },
        data: {
          type: 'membership_expiry'
        }
      };
      
      await messaging.send(message);
      await doc.ref.update({ expiryWarningSent: true });
    });
    
    await Promise.all(promises);
    return null;
  });

// ==================== RE-ENGAGEMENT ====================

/**
 * Win-back campaign for inactive users
 */
exports.reengageInactiveUsers = functions.pubsub
  .schedule('0 14 * * *') // 2 PM daily
  .onRun(async (context) => {
    const now = admin.firestore.Timestamp.now();
    const threeDaysAgo = new Date(now.toMillis() - 3 * 24 * 60 * 60 * 1000);
    const sevenDaysAgo = new Date(now.toMillis() - 7 * 24 * 60 * 60 * 1000);
    const fourteenDaysAgo = new Date(now.toMillis() - 14 * 24 * 60 * 60 * 1000);
    
    // 3 days inactive - gentle
    const threeDayUsers = await db
      .collection('users')
      .where('lastActiveAt', '<=', threeDaysAgo)
      .where('lastActiveAt', '>', sevenDaysAgo)
      .where('reengagementSent3Day', '!=', true)
      .get();
    
    // 7 days inactive - moderate
    const sevenDayUsers = await db
      .collection('users')
      .where('lastActiveAt', '<=', sevenDaysAgo)
      .where('lastActiveAt', '>', fourteenDaysAgo)
      .where('reengagementSent7Day', '!=', true)
      .get();
    
    // 14 days inactive - strong
    const fourteenDayUsers = await db
      .collection('users')
      .where('lastActiveAt', '<=', fourteenDaysAgo)
      .where('reengagementSent14Day', '!=', true)
      .get();
    
    const sendReengagement = async (users, type, title, body, flagField) => {
      const promises = users.docs.map(async (doc) => {
        const user = doc.data();
        if (!user.fcmToken) return;
        
        const message = {
          token: user.fcmToken,
          notification: { title, body },
          data: { type: 'reengagement', reengagement_type: type }
        };
        
        await messaging.send(message);
        await doc.ref.update({ [flagField]: true });
      });
      
      await Promise.all(promises);
    };
    
    await sendReengagement(
      threeDayUsers,
      'gentle',
      '✨ Missing your daily Qode?',
      'The numbers have been waiting for you.',
      'reengagementSent3Day'
    );
    
    await sendReengagement(
      sevenDayUsers,
      'moderate',
      '🌟 Your journey continues',
      'New teachings have been added since you were last here.',
      'reengagementSent7Day'
    );
    
    await sendReengagement(
      fourteenDayUsers,
      'strong',
      '💫 We miss you in the Inner Circle',
      'Shani shared something special this week. Come see!',
      'reengagementSent14Day'
    );
    
    return null;
  });

// ==================== HELPER FUNCTIONS ====================

function hasTierAccess(userTier, requiredTier) {
  const tiers = ['free', 'seeker', 'initiate', 'master'];
  const userIndex = tiers.indexOf(userTier);
  const requiredIndex = tiers.indexOf(requiredTier);
  return userIndex >= requiredIndex;
}

async function scheduleWelcomeTips(userId) {
  // Schedule Cloud Task or use delayed function
  // Implementation depends on your setup
}

// ==================== HTTP ENDPOINTS ====================

/**
 * Send custom notification to specific users
 * Admin only endpoint
 */
exports.sendCustomNotification = functions.https.onCall(async (data, context) => {
  // Verify admin
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be logged in');
  }
  
  // Check admin role
  const callerDoc = await db.collection('users').doc(context.auth.uid).get();
  if (!callerDoc.exists || callerDoc.data().role !== 'admin') {
    throw new functions.https.HttpsError('permission-denied', 'Admin access required');
  }
  
  const { userIds, title, body, data: payload } = data;
  
  // Validate inputs
  if (!Array.isArray(userIds) || userIds.length === 0 || userIds.length > 1000) {
    throw new functions.https.HttpsError('invalid-argument', 'userIds must be an array with 1-1000 items');
  }
  if (!title || typeof title !== 'string' || title.length > 100) {
    throw new functions.https.HttpsError('invalid-argument', 'title must be a string with max 100 chars');
  }
  if (!body || typeof body !== 'string' || body.length > 500) {
    throw new functions.https.HttpsError('invalid-argument', 'body must be a string with max 500 chars');
  }
  
  // Log admin action
  await db.collection('admin_logs').add({
    action: 'custom_notification',
    adminId: context.auth.uid,
    targetUserCount: userIds.length,
    title,
    timestamp: admin.firestore.FieldValue.serverTimestamp()
  });
  
  const tokens = [];
  for (const userId of userIds) {
    const userDoc = await db.collection('users').doc(userId).get();
    const user = userDoc.data();
    if (user?.fcmToken) {
      tokens.push(user.fcmToken);
    }
  }
  
  if (tokens.length === 0) {
    return { success: false, error: 'No valid tokens found' };
  }
  
  const message = {
    tokens: tokens,
    notification: { title, body },
    data: payload || {}
  };
  
  const response = await messaging.sendEachForMulticast(message);
  
  return {
    success: true,
    sent: response.successCount,
    failed: response.failureCount
  };
});
