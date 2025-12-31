import type { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
  appId: 'app.lovable.63b3acd1e1d2406a994a04418ca1d5d9',
  appName: 'Beatryx',
  webDir: 'dist',
  server: {
    url: 'https://63b3acd1-e1d2-406a-994a-04418ca1d5d9.lovableproject.com?forceHideBadge=true',
    cleartext: true
  },
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
    }
  }
};

export default config;
