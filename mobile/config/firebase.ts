import { initializeApp, getApps, type FirebaseApp } from 'firebase/app';
import { getAuth } from 'firebase/auth';

// getAnalytics is web-only and not supported in React Native — omitted intentionally.
export const firebaseConfig = {
  apiKey:            'AIzaSyB5bC3Aqd_bmsnjc6RefyDb0Fr31PlRj8o',
  authDomain:        'unify-b92fd.firebaseapp.com',
  projectId:         'unify-b92fd',
  storageBucket:     'unify-b92fd.firebasestorage.app',
  messagingSenderId: '752669005350',
  appId:             '1:752669005350:web:88aa322e433e0b4f18f8e7',
};

export const isFirebaseConfigured = true;

let app: FirebaseApp;
if (getApps().length === 0) {
  app = initializeApp(firebaseConfig);
} else {
  app = getApps()[0];
}

export const firebaseApp = app;
export const auth = getAuth(app);
