const admin = require('firebase-admin');

async function sendFCM(
  userId,
  title,
  body,
  data = {}
) {
  try {

    const db = admin.firestore();

    const userDoc = await db
      .collection('users')
      .doc(userId)
      .get();

    const userData = userDoc.data();

    if (
      !userData ||
      !userData.fcmToken
    ) {

      console.warn(
        `No FCM token found for user ${userId}`
      );

      return {
        success: false,
        skipped: true,
        reason: 'missing_fcm_token',
      };
    }

    const safeData = {};

    // FCM data values must be strings
    Object.entries(data || {}).forEach(
      ([key, value]) => {
        safeData[key] =
          value === undefined || value === null
            ? ''
            : String(value);
      }
    );

    const message = {

      token:
        userData.fcmToken,

      notification: {
        title,
        body,
      },

      data: {

        ...safeData,

        userId:
          String(userId),

        timestamp:
          Date.now().toString(),

        app:
          'ThinkTwice',
      },

      android: {

        priority:
          'high',

        notification: {

          channelId:
            'thinktwice_nudges',

          priority:
            'high',

          sound:
            'default',
        },
      },

      apns: {

        payload: {

          aps: {

            sound:
              'default',

            badge:
              1,
          },
        },
      },
    };

    const response =
      await admin
        .messaging()
        .send(message);

    console.log(
      `FCM sent successfully to ${userId}:`,
      response
    );

    return {
      success: true,
      response,
    };

  } catch (error) {

    console.error(
      'FCM send error:',
      error.message
    );

    // Invalid token cleanup
    const invalidTokenErrors = [
      'messaging/registration-token-not-registered',
      'messaging/invalid-registration-token',
    ];

    if (
      invalidTokenErrors.includes(
        error.code
      )
    ) {

      try {

        const db =
          admin.firestore();

        await db
          .collection('users')
          .doc(userId)
          .set(
            {
              fcmToken: null,
            },
            { merge: true }
          );

        console.warn(
          `Removed invalid FCM token for ${userId}`
        );

      } catch (cleanupError) {

        console.error(
          'FCM token cleanup failed:',
          cleanupError.message
        );
      }
    }

    return {
      success: false,
      skipped: true,
      error: error.message,
    };
  }
}

module.exports = {
  sendFCM,
};