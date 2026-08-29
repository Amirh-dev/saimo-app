// Firebase Cloud Messaging service worker for web background notifications.
// firebase_messaging registers this file automatically at the web root.
importScripts(
  'https://www.gstatic.com/firebasejs/10.13.2/firebase-app-compat.js',
);
importScripts(
  'https://www.gstatic.com/firebasejs/10.13.2/firebase-messaging-compat.js',
);

firebase.initializeApp({
  apiKey: 'AIzaSyDYdXaoynjBzipY88t36l1YAXuh-0cmUWA',
  authDomain: 'saimo-95714.firebaseapp.com',
  projectId: 'saimo-95714',
  storageBucket: 'saimo-95714.firebasestorage.app',
  messagingSenderId: '1027951095819',
  appId: '1:1027951095819:web:1de602e687b5698d7fd70e',
  measurementId: 'G-97PTCTEH7W',
});

const messaging = firebase.messaging();

// Data-only messages: render a notification ourselves. Messages that carry a
// `notification` block are shown by the browser automatically.
messaging.onBackgroundMessage((payload) => {
  const data = payload.data || {};
  const title = data.title || 'پیام جدید';
  self.registration.showNotification(title, {
    body: data.body || '',
    icon: '/icons/Icon-192.png',
    data,
  });
});
