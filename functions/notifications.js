const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { logger } = require("firebase-functions");
const admin = require("firebase-admin");

exports.sendNewMessageNotification = onDocumentCreated(
  "chatRoomIds/{chatRoomId}/messages/{messageId}",
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) return;

    const message = snapshot.data();

    const receiverId = message.receiverId;
    const senderName = message.senderName || "New Message";
    const messageText = message.message || "";

    try {
      // Fetch user
      const userDoc = await admin.firestore()
        .collection("Users")
        .doc(receiverId)
        .get();

      if (!userDoc.exists) {
        logger.warn("Receiver does not exist:", receiverId);
        return;
      }

      const userData = userDoc.data();

      // Support array or single token
      let tokens = [];

      if (Array.isArray(userData.fcmToken)) {
        tokens = userData.fcmToken;
      } else if (typeof userData.fcmToken === "string") {
        tokens = [userData.fcmToken];
      }

      if (tokens.length === 0) {
        logger.warn("User has no FCM token:", receiverId);
        return;
      }

      // Remove duplicates
      tokens = [...new Set(tokens)];

      const messageToSend = {
        notification: {
          title: senderName,
          body: messageText,
        },
        data: {
          type: "chat",
          senderId: message.senderId,
          chatRoomId: message.chatRoomId,
        },
      };

      // Send one by one so we can clean up invalid tokens
      const validTokens = [];

      for (const token of tokens) {
        try {
          await admin.messaging().send({
            token,
            ...messageToSend,
          });

          validTokens.push(token);
        } catch (error) {
          const code = error.errorInfo?.code || "";

          // Token invalid → delete it
          if (
            code === "messaging/invalid-registration-token" ||
            code === "messaging/registration-token-not-registered"
          ) {
            logger.warn("Removing invalid token:", token);
            continue; // don't include it in validTokens
          }

          // Log other errors
          logger.error("Error sending to token:", token, error);
          validTokens.push(token); // Keep it if error is unrelated
        }
      }

      // Update user document if tokens were removed
      if (validTokens.length !== tokens.length) {
        await admin.firestore()
          .collection("Users")
          .doc(receiverId)
          .update({ fcmToken: validTokens });

        logger.info(
          `Cleaned FCM tokens for user ${receiverId}. Remaining:`,
          validTokens.length
        );
      }

      logger.info("Notification sent successfully to:", receiverId);
    } catch (error) {
      logger.error(
        "Fatal error sending new message notification:",
        error
      );
    }
  }
);
