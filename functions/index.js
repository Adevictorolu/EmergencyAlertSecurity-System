const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

// Email notification to Admin when a new alert is created
exports.notifyAdminOnNewAlert = functions.firestore
  .document("alerts/{alertId}")
  .onCreate(async (snap, context) => {
    const alertData = snap.data();
    
    // In a real scenario, you'd fetch admin emails or use SendGrid/Nodemailer
    const mailOptions = {
      to: "admin@dualert.com", 
      message: {
        subject: `[DUalert] New Emergency: ${alertData.title}`,
        text: `A new emergency alert was reported:\n\nTitle: ${alertData.title}\nDescription: ${alertData.description}`,
      },
    };

    // Store in a 'mail' collection if using Firebase Trigger Email extension
    return admin.firestore().collection("mail").add(mailOptions);
  });

// Email notification to User when alert is handled
exports.notifyUserOnAlertHandled = functions.firestore
  .document("alerts/{alertId}")
  .onUpdate(async (change, context) => {
    const beforeData = change.before.data();
    const afterData = change.after.data();

    // Check if the 'handled' status changed from false to true
    if (beforeData.handled === false && afterData.handled === true) {
      
      // Fetch user data to get email
      const userDoc = await admin.firestore().collection('users').doc(afterData.senderUid).get();
      if (!userDoc.exists) return null;
      const userData = userDoc.data();

      // Trigger Email
      const mailOptions = {
        to: userData.email,
        message: {
          subject: `[DUalert] Update: Your Alert has been Handled`,
          text: `Hello ${userData.fullName},\n\nYour alert titled "${afterData.title}" has been successfully handled by an administrator.`,
        },
      };

      return admin.firestore().collection("mail").add(mailOptions);
    }
    return null;
  });
