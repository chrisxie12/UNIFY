import { initializeApp, getApps, getApp } from 'firebase/app';

export const firebaseConfig = {
  apiKey:            'AIzaSyB5bC3Aqd_bmsnjc6RefyDb0Fr31PlRj8o',
  authDomain:        'unify-b92fd.firebaseapp.com',
  projectId:         'unify-b92fd',
  storageBucket:     'unify-b92fd.firebasestorage.app',
  messagingSenderId: '752669005350',
  appId:             '1:752669005350:web:88aa322e433e0b4f18f8e7',
};

export const firebaseApp =
  getApps().length === 0 ? initializeApp(firebaseConfig) : getApp();

// Get this from: Firebase Console → Authentication → Sign-in method
// → Google → Web SDK configuration → Web client ID
export const GOOGLE_WEB_CLIENT_ID =
  process.env.EXPO_PUBLIC_GOOGLE_WEB_CLIENT_ID ?? '';
