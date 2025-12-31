import type { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
  appId: 'app.lovable.serenessoundstudio',
  appName: 'Beatryx',
  webDir: 'dist',
  android: {
    minWebViewVersion: 55,
    backgroundColor: '#000000',
    // Enable background audio playback
    allowMixedContent: true
  },
  plugins: {
    // Background audio configuration
    CapacitorHttp: {
      enabled: true
    },
    Filesystem: {
      enabled: true
    }
  }
};

export default config;
