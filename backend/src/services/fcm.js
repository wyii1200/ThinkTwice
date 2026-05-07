const admin = require('firebase-admin');

async function sendFCM(userId, title, body, data = {}) {
  try {
    const db = admin.firestore();
    const userDoc = await db.collection('users').doc(userId).get();
    const userData = userDoc.data();

    if (!userData || !userData.fcmToken) {
      console.warn(`No FCM token found for user ${userId}`);
      return null;
    }

    const message = {
      token: userData.fcmToken,
      notification: { title, body },
      data: {
        ...data,
        userId,
        timestamp: Date.now().toString(),
      },
      android: {
        priority: 'high',
        notification: { channelId: 'thinktwice_nudges' },
      },
      apns: {
        payload: { aps: { sound: 'default' } },
      },
    };

    const response = await admin.messaging().send(message);
    console.log(`FCM sent to ${userId}:`, response);
    return response;
  } catch (error) {
    console.error('FCM send error:', error);
    throw error;
  }
}

module.exports = { sendFCM };