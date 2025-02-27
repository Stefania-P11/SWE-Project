const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.addMessage = functions.https.onCall((data, context) => {
  const message = data.message;
  return admin.firestore().collection('messages').add({
    text: message,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  })
  .then(() => {
    return { result: "Message added successfully!" };
  })
  .catch((error) => {
    throw new functions.https.HttpsError('unknown', error.message);
  });
});
