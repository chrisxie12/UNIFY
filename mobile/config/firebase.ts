import { initializeApp, getApps, getApp, type FirebaseApp } from 'firebase/app';
import type { Auth } from 'firebase/auth';

export const firebaseConfig = {
  apiKey:            'AIzaSyB5bC3Aqd_bmsnjc6RefyDb0Fr31PlRj8o',
  authDomain:        'unify-b92fd.firebaseapp.com',
  projectId:         'unify-b92fd',
  storageBucket:     'unify-b92fd.firebasestorage.app',
  messagingSenderId: '752669005350',
  appId:             '1:752669005350:web:88aa322e433e0b4f18f8e7',
};

// Never call getAuth()/initializeAuth() at module level in React Native —
// Firebase's auth component registration races with the RN bridge init and
// throws "Component auth has not been registered yet".
// Use getFirebaseAuth() inside components/handlers instead.

const _app: FirebaseApp =
  getApps().length === 0 ? initializeApp(firebaseConfig) : getApp();

let _auth: Auth | null = null;

export function getFirebaseAuth(): Auth {
  if (_auth) return _auth;
  // require() defers execution until first call, after RN bridge is ready.
  /* eslint-disable @typescript-eslint/no-require-imports, @typescript-eslint/no-explicit-any */
  const { initializeAuth, getAuth, getReactNativePersistence } =
    require('firebase/auth') as any;
  const AsyncStorage =
    require('@react-native-async-storage/async-storage').default as any;
  /* eslint-enable */
  try {
    _auth = initializeAuth(_app, {
      persistence: getReactNativePersistence(AsyncStorage),
    });
  } catch {
    // Auth already initialised (Fast Refresh / hot-reload)
    _auth = getAuth(_app);
  }
  return _auth!;
}

export const firebaseApp = _app;
