module.exports = function (api) {
  api.cache(true);
  return {
    presets: [
      ['babel-preset-expo', { jsxImportSource: 'nativewind' }],
      'nativewind/babel',
    ],
    // Reanimated 4 delegates this plugin to react-native-worklets/plugin
    // internally, so react-native-worklets must be in dependencies.
    plugins: ['react-native-reanimated/plugin'],
  };
};
