const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

// Send a notification to Device B
exports.sendNotificationToDeviceB = functions.https.onCall(async (data, context) => {
  const { deviceBToken, message } = data;

  // Create a notification payload
  const payload = {
    notification: {
      title: 'New Message',
      body: message,
    },
  };

  // Send the notification to Device B
  await admin.messaging().sendToDevice(deviceBToken, payload);

  return { success: true };
});
