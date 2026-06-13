import { initializeApp, getApps, getApp, type FirebaseApp } from 'firebase/app';
import { initializeAuth, getAuth, getReactNativePersistence, type Auth } from 'firebase/auth';
import AsyncStorage from '@react-native-async-storage/async-storage';

export const firebaseConfig = {
  apiKey:            'AIzaSyB5bC3Aqd_bmsnjc6RefyDb0Fr31PlRj8o',
  authDomain:        'unify-b92fd.firebaseapp.com',
  projectId:         'unify-b92fd',
  storageBucket:     'unify-b92fd.firebasestorage.app',
  messagingSenderId: '752669005350',
  appId:             '1:752669005350:web:88aa322e433e0b4f18f8e7',
};

// initializeApp is safe at module level.
// initializeAuth MUST be deferred (called inside getFirebaseAuth) —
// calling it during Metro's module scan phase crashes with
// "Component auth has not been registered yet".
const _app: FirebaseApp =
  getApps().length === 0 ? initializeApp(firebaseConfig) : getApp();

let _auth: Auth | null = null;

export function getFirebaseAuth(): Auth {
  if (_auth) return _auth;
  try {
    _auth = initializeAuth(_app, {
      persistence: getReactNativePersistence(AsyncStorage),
    });
  } catch {
    // initializeAuth throws if auth was already initialised (Fast Refresh).
    _auth = getAuth(_app);
  }
  return _auth;
}

export const firebaseApp = _app;
