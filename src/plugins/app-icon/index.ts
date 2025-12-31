import { registerPlugin } from '@capacitor/core';

export interface AppIconPlugin {
  changeIcon(options: { icon: string }): Promise<{ success: boolean; icon: string }>;
  getCurrentIcon(): Promise<{ icon: string }>;
}

const AppIcon = registerPlugin<AppIconPlugin>('AppIcon', {
  web: () => import('./web').then(m => new m.AppIconWeb()),
});

export default AppIcon;
