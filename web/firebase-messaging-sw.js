/* eslint-disable no-undef */
/**
 * Firebase Messaging service worker for web.
 * Values match `DefaultFirebaseOptions` / Firebase Console (catch-ride95).
 */
importScripts('https://www.gstatic.com/firebasejs/10.14.1/firebase-app-compat.js');
importScripts(
  'https://www.gstatic.com/firebasejs/10.14.1/firebase-messaging-compat.js',
);

firebase.initializeApp({
  apiKey: 'AIzaSyCi1DoXvdJSa7Cv-Nj-4Jr0Vs3HBHXWYK0',
  authDomain: 'catch-ride95.firebaseapp.com',
  projectId: 'catch-ride95',
  storageBucket: 'catch-ride95.firebasestorage.app',
  messagingSenderId: '804782276759',
  appId: '1:804782276759:web:6cd6c0d34285b66f5ae9d2',
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  console.log('[firebase-messaging-sw.js] Background message', payload);
});
