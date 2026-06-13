const { getDefaultConfig } = require('expo/metro-config');
const { withNativeWind } = require('nativewind/metro');

// 1. Get the default Expo Metro configuration
const config = getDefaultConfig(__dirname);

// 2. FORCE METRO TO A SINGLE THREAD (Bypasses the jest-worker DataCloneError crash)
config.maxWorkers = 1;

// 3. Prevent Metro from scanning outside the mobile workspace folder
config.watchFolders = [__dirname];

// 4. Export the configuration wrapped with NativeWind layout rules
module.exports = withNativeWind(config, { input: './global.css' });