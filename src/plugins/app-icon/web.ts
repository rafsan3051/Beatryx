import { WebPlugin } from '@capacitor/core';
import type { AppIconPlugin } from './index';

export class AppIconWeb extends WebPlugin implements AppIconPlugin {
  async changeIcon(options: { icon: string }): Promise<{ success: boolean; icon: string }> {
    console.log('AppIcon web implementation - changeIcon:', options.icon);
    // Web doesn't support changing launcher icons
    return { success: false, icon: options.icon };
  }

  async getCurrentIcon(): Promise<{ icon: string }> {
    console.log('AppIcon web implementation - getCurrentIcon');
    return { icon: 'default' };
  }
}
