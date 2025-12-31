import React from 'react';
import { motion } from 'framer-motion';
import { 
  Sun, Moon, Monitor, Palette, Bell, Download, Shield, HelpCircle,
  ChevronRight, Music, Headphones, Check, Paintbrush, Image
} from 'lucide-react';
import { useTheme, accentColors, appThemes, appIcons, type AppIcon } from '@/contexts/ThemeContext';
import { Switch } from '@/components/ui/switch';
import { cn } from '@/lib/utils';

const accentColorsList = [
  { id: 'coral', name: 'Coral', color: 'bg-orange-500' },
  { id: 'blue', name: 'Ocean', color: 'bg-blue-500' },
  { id: 'purple', name: 'Lavender', color: 'bg-purple-500' },
  { id: 'green', name: 'Forest', color: 'bg-green-500' },
  { id: 'pink', name: 'Rose', color: 'bg-pink-500' },
  { id: 'amber', name: 'Amber', color: 'bg-amber-500' },
  { id: 'cyan', name: 'Cyan', color: 'bg-cyan-500' },
  { id: 'rose', name: 'Cherry', color: 'bg-rose-500' },
] as const;

const appThemesList = [
  { id: 'default', name: 'Default', emoji: '⚪' },
  { id: 'midnight', name: 'Midnight', emoji: '🌙' },
  { id: 'forest', name: 'Forest', emoji: '🌲' },
  { id: 'sunset', name: 'Sunset', emoji: '🌅' },
  { id: 'ocean', name: 'Ocean', emoji: '🌊' },
  { id: 'lavender', name: 'Lavender', emoji: '💜' },
  { id: 'monochrome', name: 'Mono', emoji: '⬛' },
] as const;

const appIconsList: { id: AppIcon; name: string }[] = [
  { id: 'custom', name: 'Beatryx' },
  { id: 'default', name: 'Disc' },
  { id: 'smartphone', name: 'Mobile' },
  { id: 'song-outline', name: 'Note Outline' },
  { id: 'song', name: 'Note Filled' },
  { id: 'music', name: 'Music' },
  { id: 'disc-outline', name: 'Disc Outline' },
  { id: 'square', name: 'Square' },
];

export function SettingsScreen() {
  const { theme, setTheme, accentColor, setAccentColor, appTheme, setAppTheme, appIcon, setAppIcon } = useTheme();

  const themeOptions = [
    { id: 'light', label: 'Light', icon: Sun },
    { id: 'dark', label: 'Dark', icon: Moon },
    { id: 'system', label: 'System', icon: Monitor },
  ] as const;

  return (
    <div className="flex flex-col gap-6 pb-40">
      <motion.div initial={{ opacity: 0, y: -20 }} animate={{ opacity: 1, y: 0 }} className="pt-4">
        <h1 className="text-2xl font-bold text-foreground">Settings</h1>
        <p className="text-muted-foreground mt-1">Customize your experience</p>
      </motion.div>

      {/* Appearance */}
      <section className="bg-card rounded-2xl p-4 shadow-soft">
        <h2 className="text-lg font-semibold text-foreground mb-4 flex items-center gap-2">
          <Palette className="w-5 h-5 text-primary" />
          Appearance
        </h2>
        
        <div className="mb-6">
          <p className="text-sm text-muted-foreground mb-3">Mode</p>
          <div className="grid grid-cols-3 gap-2">
            {themeOptions.map(({ id, label, icon: Icon }) => (
              <button key={id} onClick={() => setTheme(id)}
                className={cn("flex flex-col items-center gap-2 p-3 rounded-xl transition-all",
                  theme === id ? "bg-primary text-primary-foreground" : "bg-secondary text-secondary-foreground hover:bg-secondary/80"
                )}>
                <Icon className="w-5 h-5" />
                <span className="text-xs font-medium">{label}</span>
              </button>
            ))}
          </div>
        </div>

        <div className="mb-6">
          <p className="text-sm text-muted-foreground mb-3">Accent Color</p>
          <div className="flex gap-2 flex-wrap">
            {accentColorsList.map(({ id, name, color }) => (
              <button key={id} onClick={() => setAccentColor(id as any)}
                className={cn("relative w-9 h-9 rounded-full transition-transform hover:scale-110", color,
                  accentColor === id && "ring-2 ring-offset-2 ring-offset-card ring-foreground"
                )} title={name}>
                {accentColor === id && <Check className="absolute inset-0 m-auto w-4 h-4 text-white" />}
              </button>
            ))}
          </div>
        </div>

        <div className="mb-6">
          <p className="text-sm text-muted-foreground mb-3">Theme Style</p>
          <div className="grid grid-cols-4 gap-2">
            {appThemesList.map(({ id, name, emoji }) => (
              <button key={id} onClick={() => setAppTheme(id as any)}
                className={cn("flex flex-col items-center gap-1 p-2 rounded-xl transition-all text-center",
                  appTheme === id ? "bg-primary text-primary-foreground" : "bg-secondary text-secondary-foreground hover:bg-secondary/80"
                )}>
                <span className="text-lg">{emoji}</span>
                <span className="text-xs font-medium">{name}</span>
              </button>
            ))}
          </div>
        </div>

        <div>
          <p className="text-sm text-muted-foreground mb-3 flex items-center gap-2">
            <Image className="w-4 h-4" />
            App Icon
          </p>
          <div className="grid grid-cols-4 gap-3">
            {appIconsList.map(({ id, name }) => (
              <button 
                key={id} 
                onClick={() => setAppIcon(id)}
                type="button"
                className={cn("relative flex flex-col items-center gap-2 p-3 rounded-xl transition-all hover:scale-105",
                  appIcon === id 
                    ? "bg-primary/20 ring-2 ring-primary" 
                    : "bg-secondary hover:bg-secondary/80"
                )}>
                <img 
                  src={appIcons[id]} 
                  alt={name} 
                  className="w-10 h-10 rounded-lg object-cover"
                  onError={(e) => {
                    // Fallback for SVG or missing images
                    const target = e.target as HTMLImageElement;
                    if (!target.src.includes('fallback')) {
                      target.src = appIcons['default'];
                    }
                  }}
                />
                <span className="text-xs font-medium text-foreground truncate w-full text-center">{name}</span>
                {appIcon === id && (
                  <div className="absolute top-1 right-1 w-4 h-4 bg-primary rounded-full flex items-center justify-center">
                    <Check className="w-3 h-3 text-primary-foreground" />
                  </div>
                )}
              </button>
            ))}
          </div>
        </div>
      </section>

      {/* Playback Settings */}
      <section className="bg-card rounded-2xl overflow-hidden shadow-soft">
        <h2 className="text-sm font-semibold text-muted-foreground px-4 py-3 border-b border-border">Playback</h2>
        <div className="divide-y divide-border">
          {[
            { icon: Headphones, label: 'Audio Quality', value: 'High' },
            { icon: Music, label: 'Crossfade', value: '5s' },
            { icon: Download, label: 'Download Quality', value: 'Very High' },
          ].map((item, i) => (
            <div key={i} className="flex items-center justify-between p-4 hover:bg-secondary/30 transition-colors cursor-pointer">
              <div className="flex items-center gap-3">
                <item.icon className="w-5 h-5 text-muted-foreground" />
                <span className="font-medium text-foreground">{item.label}</span>
              </div>
              <div className="flex items-center gap-2">
                <span className="text-sm text-muted-foreground">{item.value}</span>
                <ChevronRight className="w-4 h-4 text-muted-foreground" />
              </div>
            </div>
          ))}
        </div>
      </section>

      {/* Keyboard Shortcuts Info */}
      <section className="bg-card rounded-2xl p-4 shadow-soft">
        <h2 className="text-sm font-semibold text-muted-foreground mb-3">Keyboard Shortcuts</h2>
        <div className="space-y-2 text-sm">
          <div className="flex justify-between"><span className="text-muted-foreground">Play/Pause</span><kbd className="px-2 py-0.5 rounded bg-secondary text-foreground">Space</kbd></div>
          <div className="flex justify-between"><span className="text-muted-foreground">Skip ±10s</span><kbd className="px-2 py-0.5 rounded bg-secondary text-foreground">← →</kbd></div>
          <div className="flex justify-between"><span className="text-muted-foreground">Next/Prev Track</span><kbd className="px-2 py-0.5 rounded bg-secondary text-foreground">Shift + ← →</kbd></div>
          <div className="flex justify-between"><span className="text-muted-foreground">Volume</span><kbd className="px-2 py-0.5 rounded bg-secondary text-foreground">↑ ↓</kbd></div>
        </div>
      </section>

      <div className="text-center text-sm text-muted-foreground pt-4">
        <p className="font-medium">Beatryx</p>
        <p>Version 2.0.0</p>
      </div>
    </div>
  );
}
