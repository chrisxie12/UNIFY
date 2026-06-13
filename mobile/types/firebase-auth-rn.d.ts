// Declares the React Native-specific export that lives in @firebase/auth's
// RN bundle (dist/rn/index.js, resolved by Metro via the "react-native"
// package.json field). TypeScript's node resolver sees the node bundle
// which doesn't export this, so we extend the module here.
import type { Persistence } from 'firebase/auth';

declare module 'firebase/auth' {
  export function getReactNativePersistence(
    storage: import('@react-native-async-storage/async-storage').AsyncStorageStatic,
  ): Persistence;
}
