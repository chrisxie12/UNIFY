import { initializeApp, getApps, getApp, type FirebaseApp } from 'firebase/app';
import { initializeAuth, getAuth } from 'firebase/auth';
// getReactNativePersistence lives in the RN bundle; Metro resolves it correctly at
// runtime via @firebase/auth's "react-native" package.json field. TSC uses the
// node bundle which doesn't export it, hence the ts-ignore below.
// eslint-disable-next-line @typescript-eslint/ban-ts-comment
// @ts-ignore
import { getReactNativePersistence } from '@firebase/auth/dist/rn/index.js';
import AsyncStorage from '@react-native-async-storage/async-storage';

export const firebaseConfig = {
  apiKey:            'AIzaSyB5bC3Aqd_bmsnjc6RefyDb0Fr31PlRj8o',
  authDomain:        'unify-b92fd.firebaseapp.com',
  projectId:         'unify-b92fd',
  storageBucket:     'unify-b92fd.firebasestorage.app',
  messagingSenderId: '752669005350',
  appId:             '1:752669005350:web:88aa322e433e0b4f18f8e7',
};

export const isFirebaseConfigured = true;

// Use initializeAuth (not getAuth) on first init — required for React Native.
// On subsequent hot-reloads the app is already initialised so use getAuth.
let app: FirebaseApp;
let _auth: ReturnType<typeof getAuth>;

if (getApps().length === 0) {
  app = initializeApp(firebaseConfig);
  _auth = initializeAuth(app, {
    persistence: getReactNativePersistence(AsyncStorage),
  });
} else {
  app = getApp();
  _auth = getAuth(app);
}

export const firebaseApp = app;
export const auth = _auth;
