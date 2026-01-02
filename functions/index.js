//index.js
const express = require("express");
const cors = require("cors");
const axios = require("axios");
const crypto = require("crypto");

// Firebase imports
const { onRequest } = require("firebase-functions/v2/https");
const { defineSecret } = require("firebase-functions/params");
const functions = require("firebase-functions");
const admin = require("firebase-admin");
const { Webhook } = require("svix");

// Firebase setup
admin.initializeApp();
const db = admin.firestore();
const messaging = admin.messaging();

const app = express();
app.use(cors({ origin: true }));
app.use(express.json());


// claims
const claims = require("./claims");

// export
exports.setAdminRole = claims.setAdminRole;

//Approved/Reject Notification
const approvedFunc = require("./approved");

exports.sendVerificationNotification = approvedFunc.sendVerificationNotification;


//Notification
const notifications = require("./notification");

// Cleanup function
const cleanup = require("./cleanup");

//Message
const notification = require("./notifications");

exports.sendNewMessageNotification = notification.sendNewMessageNotification;


// Secrets
const yocoSecretForPayments = defineSecret("YOCO_SECRET_KEY");
const yocoSecret = defineSecret("YOCO_WEBHOOK_SECRET");


// export cleanup function (pass admin instance)
exports.cleanupInactiveDocuments = cleanup.cleanupInactiveDocuments(admin);

// export notifications
exports.sendSubscriptionExpiredNotifications = notifications.sendSubscriptionExpiredNotifications;

// Your domain for deep links
const YOUR_APP_DOMAIN = "https://patience-da636.web.app";


/**
 * Helper to calculate expiry date
 */
const YocoPaymentService = {
  getExpiryDate: (durationMonths) => {
    const date = new Date();
    date.setMonth(date.getMonth() + durationMonths);

    // Return a Firestore Timestamp object instead of an ISO string
    return admin.firestore.Timestamp.fromDate(date);
  }
};

/**
 * Create Yoco checkout session
 */

app.post("/", async (req, res) => {
  const secretKey = await yocoSecretForPayments.value();

  const { amountInCents, collectionName, docId, userId, planName, planPrice, planDurationMonths } = req.body;

  if (!collectionName || !docId || !userId || !planName || !amountInCents) {
    return res.status(400).json({
      success: false,
      message: "Required parameters are missing (collectionName, docId, userId, planName, amountInCents)",
    });
  }

  try {

    const checkout = await axios.post(
      "https://payments.yoco.com/api/checkouts",
      {
        amount: amountInCents,
        currency: "ZAR",
        metadata: {
          collectionName,
          docId,
          userId,
          planName,
          planPrice,
          planDurationMonths,
        },
      },
      {
        headers: {
          Authorization: `Bearer ${secretKey}`,
          "Content-Type": "application/json",
          Accept: "application/json",
        },
        timeout: 10000,
      }
    );

    return res.status(200).json({
      success: true,
      redirectUrl: checkout.data.redirectUrl,
    });
  } catch (error) {
    const errData = error.response?.data || error.message;
    console.error("Checkout creation failed:", errData);
    return res.status(error.response?.status || 500).json({
      success: false,
      message: errData?.error?.message || "Checkout session failed",
      details: errData,
    });
  }
});

// ----------------------------------------------------------------------------------------------------------------------------------

/**
 * Webhook endpoint for Yoco
 */
exports.yocoWebhook = onRequest({ secrets: [yocoSecret, yocoSecretForPayments] }, async (req, res) => {
  if (req.method !== "POST") {
    console.log("Method not allowed:", req.method);
    return res.status(405).send("Method Not Allowed");
  }

  const headers = {
    "webhook-id": req.get("webhook-id"),
    "webhook-timestamp": req.get("webhook-timestamp"),
    "webhook-signature": req.get("webhook-signature"),
  };

  if (!headers["webhook-id"] || !headers["webhook-timestamp"] || !headers["webhook-signature"]) {
    return res.status(400).send("Missing Yoco headers");
  }

  const rawBody = req.rawBody ? req.rawBody.toString("utf8") : null;
  if (!rawBody) {
    return res.status(400).send("No raw body");
  }

  try {
    const secretValue = await yocoSecret.value();
    const wh = new Webhook(secretValue);
    const event = wh.verify(rawBody, headers);

    if (event.type !== "payment.succeeded") {
      console.log(`Ignoring event type: ${event.type}`);
      return res.status(200).send("Ignoring event type");
    }

    const eventId = event.payload.id;
    const paymentStatus = event.payload.status;
    const checkoutId = event.payload.metadata.checkoutId;

    if (!checkoutId) {
      return res.status(400).send("Missing checkoutId in webhook event");
    }

    const secretKeyForPayments = await yocoSecretForPayments.value();
    const checkoutUrl = `https://payments.yoco.com/api/checkouts/${checkoutId}`;
    const response = await axios.get(checkoutUrl, {
      headers: { Authorization: `Bearer ${secretKeyForPayments}` },
      timeout: 10000,
    });
    const checkoutDetails = response.data;

    // Get all metadata
    const { collectionName, docId, userId, planName, planPrice, planDurationMonths } = checkoutDetails.metadata;

    if (!collectionName || !docId || !userId) {
      return res.status(400).send("Missing required metadata in fetched checkout details");
    }

    const docRef = db.collection(collectionName).doc(docId);

    if (paymentStatus === "succeeded") {

        let paymentData // Declared once

        if(collectionName == 'products'){

        paymentData = {
                'status': 'active'
               }
         }else{

           paymentData = {
            'plan': planName,
            'amount': planPrice,
            'paymentId': eventId,
            'paymentExpiryDate': YocoPaymentService.getExpiryDate(planDurationMonths),
            'paymentStatus': 'success',
            'status': 'active',
            'updatedAt': admin.firestore.FieldValue.serverTimestamp()
             };
         }

          // 'paymentData' is now guaranteed to be an object here
          await docRef.update(paymentData);
      console.log(`Document ${docId} in collection ${collectionName} updated successfully.`);

      // Secondary update to user doc using userId
      const userDocRef = db.collection("Users").doc(userId);
      await userDocRef.update({
        'lastPaymentInfo': paymentData,
        'paymentStatus': 'success',
        'updatedAt': admin.firestore.FieldValue.serverTimestamp()
      });
      console.log(`User document ${userId} in "Users" collection also updated.`);

      // FCM notification logic, correctly using userId
      const userRef = db.collection("Users").doc(userId);
      const userSnap = await userRef.get();

      if (userSnap.exists) {
        const tokens = userSnap.data().fcmTokens || [];
        if (tokens.length > 0) {
          await messaging.sendEachForMulticast({
            tokens,
            notification: {
              title: "Payment Confirmed!",
              body: "Your payment for the plan has been successful."
            },
            data: {
              status: paymentStatus,
            },
            android: {
              priority: "high",
            },
          });
          console.log(`Sent FCM notification to ${tokens.length} devices.`);
        } else {
          console.log(`No FCM tokens found for user ${userId}.`);
        }
      }
    } else {
      console.log(`Payment was not succeeded. No documents updated.`);
    }

    return res.status(200).send("Webhook processed");
  } catch (err) {
    console.error("Webhook verification or processing failed:", err.response?.data || err.message);
    return res.status(400).send("Invalid signature or processing error");
  }
});

// ----------------------------------------------------------------------------------------------------------------------------------

/**
 * Expose checkout creation
 */
exports.createYocoCheckout = onRequest(
  { secrets: [yocoSecretForPayments] },
  app
);




