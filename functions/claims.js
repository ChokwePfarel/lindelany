const functions = require("firebase-functions");
const admin = require("firebase-admin");

exports.setAdminRole = functions.https.onCall(async (data, context) => {

  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "You must be signed in."
    );
  }

  // Only allow existing admins
  if (!context.auth.token.admin) {
    throw new functions.https.HttpsError(
      "permission-denied",
      "Only admins can assign admin roles."
    );
  }

  const uid = data.uid;

  await admin.auth().setCustomUserClaims(uid, { admin: true });

  return { message: `User ${uid} is now an admin.` };
});

