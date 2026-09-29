const { onSchedule } = require("firebase-functions/v2/scheduler");
const admin = require("firebase-admin");
const { FieldPath } = require("firebase-admin/firestore"); // <-- FIX

exports.sendSubscriptionExpiredNotifications = onSchedule("every 24 hours", async (event) => {
  const now = new Date();
  const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());

  // Get expired accommodations
  const expiredSubscriptionsSnapshot = await admin.firestore()
    .collection("Accommodation")
    .where("paymentExpiryDate", "<=", today)
    .get();

  if (expiredSubscriptionsSnapshot.empty) {
    console.log("No expired subscriptions today.");
    return null;
  }

  // Collect unique userIds
  const userIdsSet = new Set();
  expiredSubscriptionsSnapshot.forEach(doc => {
    const accommodation = doc.data();
    if (accommodation.userId) {
      userIdsSet.add(accommodation.userId);
    }
  });
  const userIds = Array.from(userIdsSet);

  if (userIds.length === 0) {
    console.log("No users found for expired subscriptions.");
    return null;
  }

  // Map to keep track of which token belongs to which user
  const userTokens = [];

  // Firestore `in` only allows 10 IDs at a time, so chunk queries
  const chunkSize = 10;
  for (let i = 0; i < userIds.length; i += chunkSize) {
    const chunk = userIds.slice(i, i + chunkSize);

    const usersSnapshot = await admin.firestore()
      .collection("Users")
      .where(FieldPath.documentId(), "in", chunk) //
      .get();

    usersSnapshot.forEach(userDoc => {
      const user = userDoc.data();
      if (user.fcmToken) {
        userTokens.push({
          userId: userDoc.id,
          token: user.fcmToken,
        });
      }
    });
  }

  if (userTokens.length === 0) {
    console.log("No tokens found for expired subscriptions.");
    return null;
  }

  // Send notifications
  const message = {
    notification: {
      title: "Subscription Expired!",
      body: "Your subscription has ended. Renew now to continue accessing all features.",
    },
    data: {
      action: "open_subscription_page",
    },
    tokens: userTokens.map(u => u.token),
  };

  try {
    const response = await admin.messaging().sendEachForMulticast(message);
    console.log("Successfully sent message:", response.successCount, "failures:", response.failureCount);

    // Cleanup invalid tokens
    const invalidTokens = [];
    response.responses.forEach((res, idx) => {
      if (!res.success) {
        const tokenInfo = userTokens[idx];
        const errorCode = res.error.code;
        console.warn(`Token for user ${tokenInfo.userId} failed: ${errorCode}`);

        if (
          errorCode === "messaging/invalid-argument" ||
          errorCode === "messaging/registration-token-not-registered"
        ) {
          invalidTokens.push(tokenInfo);
        }
      }
    });

    // Remove invalid tokens from Users collection
    if (invalidTokens.length > 0) {
      const batch = admin.firestore().batch();
      invalidTokens.forEach(({ userId }) => {
        const userRef = admin.firestore().collection("Users").doc(userId);
        batch.update(userRef, { fcmToken: admin.firestore.FieldValue.delete() });
      });

      await batch.commit();
      console.log("Cleaned up invalid tokens for", invalidTokens.length, "users");
    }
  } catch (error) {
    console.error("Error sending message:", error);
  }

  return null;
});
