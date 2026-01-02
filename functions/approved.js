const { onCall } = require('firebase-functions/v2/https');
const admin = require('firebase-admin');

// Initialize here if not already initialized
if (!admin.apps.length) {
  admin.initializeApp();
}

exports.sendVerificationNotification = onCall(async (request) => {
  console.log("=== Function Called ===");
  console.log("Auth object:", JSON.stringify(request.auth));
  console.log("Has auth:", !!request.auth);
  console.log("Has admin claim:", request.auth?.token?.admin);
  
  // check authentication
  if (!request.auth) {
    throw new HttpsError(
      'unauthenticated',
      'User must be authenticated to send notifications.'
    );
  }

  // check admin
  if (!request.auth.token.admin) {
    throw new HttpsError(
      'permission-denied',
      'Only admins can send verification notifications.'
    );
  }

  const { userId, type, accommodationName, reason } = request.data;

  if (!userId || !type) {
    throw new HttpsError(
      'invalid-argument',
      'userId and type are required.'
    );
  }

  try {
    const userDoc = await admin.firestore().collection('Users').doc(userId).get();

    if (!userDoc.exists) {
      console.log(`User ${userId} not found`);
      return { success: false, message: 'User not found' };
    }

    const userData = userDoc.data();
    const fcmToken = userData.fcmToken;

    if (!fcmToken) {
      console.log(`No FCM token for ${userId}`);
      return { success: false, message: 'No FCM token found for user' };
    }

    // create notification
    let notification = {};
    let data_payload = {};

    if (type === 'approved') {
      notification = {
        title: 'Verification Approved',
        body: `Your accommodation "${accommodationName}" has been verified.`
      };

      data_payload = {
        type: 'verification_approved',
        accommodationName: accommodationName || '',
        timestamp: new Date().toISOString()
      };
    }
    else if (type === 'rejected') {
      notification = {
        title: 'Verification Rejected',
        body: reason
          ? `Your accommodation "${accommodationName}" verification was rejected. Reason: ${reason}`
          : `Your accommodation "${accommodationName}" verification was rejected.`
      };

      data_payload = {
        type: 'verification_rejected',
        accommodationName: accommodationName || '',
        reason: reason || '',
        timestamp: new Date().toISOString()
      };
    }
    else {
      throw new HttpsError(
        'invalid-argument',
        'Type must be either "approved" or "rejected".'
      );
    }

    const message = {
      notification: notification,
      data: data_payload,
      token: fcmToken,
      android: {
        priority: 'high',
        notification: {
          sound: 'default',
          channelId: 'verification_channel'
        }
      },
      apns: {
        payload: {
          aps: {
            sound: 'default',
            badge: 1
          }
        }
      }
    };

    const response = await admin.messaging().send(message);

    console.log('Successfully sent notification:', response);

    return {
      success: true,
      message: 'Notification sent successfully',
      messageId: response
    };

  } catch (e) {
    console.error('Error sending notification:', e);

    // handle FCM invalid token errors
    if (
      e.code === 'messaging/invalid-registration-token' ||
      e.code === 'messaging/registration-token-not-registered'
    ) {
      await admin.firestore().collection('Users').doc(userId).update({
        fcmToken: admin.firestore.FieldValue.delete()
      });
      return { success: false, message: 'Invalid FCM token removed' };
    }

    throw new HttpsError(
      'internal',
      'Failed to send notification: ' + e.message
    );
  }
});