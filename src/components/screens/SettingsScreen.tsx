import React from 'react';
import { motion } from 'framer-motion';
import { 
  Sun, 
  Moon, 
  Monitor, 
  Palette, 
  Bell, 
  Download, 
  Shield, 
  HelpCircle,
  ChevronRight,
  Music,
  Headphones,
  Check
} from 'lucide-react';
import { useTheme } from '@/contexts/ThemeContext';
import { Switch } from '@/components/ui/switch';
import { cn } from '@/lib/utils';

const accentColors = [
  { id: 'coral', name: 'Coral', color: 'bg-orange-500' },
  { id: 'blue', name: 'Ocean', color: 'bg-blue-500' },
  { id: 'purple', name: 'Lavender', color: 'bg-purple-500' },
  { id: 'green', name: 'Forest', color: 'bg-green-500' },
  { id: 'pink', name: 'Rose', color: 'bg-pink-500' },
] as const;

export function SettingsScreen() {
  const { theme, setTheme, accentColor, setAccentColor } = useTheme();

  const themeOptions = [
    { id: 'light', label: 'Light', icon: Sun },
    { id: 'dark', label: 'Dark', icon: Moon },
    { id: 'system', label: 'System', icon: Monitor },
  ] as const;

  const settingsSections = [
    {
      title: 'Playback',
      items: [
        { icon: Headphones, label: 'Audio Quality', value: 'High' },
        { icon: Music, label: 'Crossfade', value: '5s' },
        { icon: Download, label: 'Download Quality', value: 'Very High' },
      ],
    },
    {
      title: 'General',
      items: [
        { icon: Bell, label: 'Notifications', toggle: true },
        { icon: Shield, label: 'Privacy', value: '' },
        { icon: HelpCircle, label: 'Help & Support', value: '' },
      ],
    },
  ];

  return (
    <div className="flex flex-col gap-6 pb-40">
      {/* Header */}
      <motion.div
        initial={{ opacity: 0, y: -20 }}
        animate={{ opacity: 1, y: 0 }}
        className="pt-4"
      >
        <h1 className="text-2xl font-bold text-foreground">Settings</h1>
        <p className="text-muted-foreground mt-1">Customize your experience</p>
      </motion.div>

      {/* Theme Selection */}
      <section className="bg-card rounded-2xl p-4 shadow-soft">
        <h2 className="text-lg font-semibold text-foreground mb-4 flex items-center gap-2">
          <Palette className="w-5 h-5 text-primary" />
          Appearance
        </h2>
        
        {/* Theme Mode */}
        <div className="mb-6">
          <p className="text-sm text-muted-foreground mb-3">Theme</p>
          <div className="grid grid-cols-3 gap-2">
            {themeOptions.map(({ id, label, icon: Icon }) => (
              <button
                key={id}
                onClick={() => setTheme(id)}
                className={cn(
                  "flex flex-col items-center gap-2 p-3 rounded-xl transition-all",
                  theme === id
                    ? "bg-primary text-primary-foreground"
                    : "bg-secondary text-secondary-foreground hover:bg-secondary/80"
                )}
              >
                <Icon className="w-5 h-5" />
                <span className="text-xs font-medium">{label}</span>
              </button>
            ))}
          </div>
        </div>

        {/* Accent Color */}
        <div>
          <p className="text-sm text-muted-foreground mb-3">Accent Color</p>
          <div className="flex gap-3">
            {accentColors.map(({ id, name, color }) => (
              <button
                key={id}
                onClick={() => setAccentColor(id)}
                className={cn(
                  "relative w-10 h-10 rounded-full transition-transform hover:scale-110",
                  color,
                  accentColor === id && "ring-2 ring-offset-2 ring-offset-card ring-foreground"
                )}
                title={name}
              >
                {accentColor === id && (
                  <Check className="absolute inset-0 m-auto w-5 h-5 text-white" />
                )}
              </button>
            ))}
          </div>
        </div>
      </section>

      {/* Other Settings */}
      {settingsSections.map((section, sectionIndex) => (
        <section key={section.title} className="bg-card rounded-2xl overflow-hidden shadow-soft">
          <h2 className="text-sm font-semibold text-muted-foreground px-4 py-3 border-b border-border">
            {section.title}
          </h2>
          <div className="divide-y divide-border">
            {section.items.map((item, index) => (
              <motion.div
                key={item.label}
                initial={{ opacity: 0, x: -20 }}
                animate={{ opacity: 1, x: 0 }}
                transition={{ delay: (sectionIndex * 3 + index) * 0.05 }}
                className="flex items-center justify-between p-4 hover:bg-secondary/30 transition-colors cursor-pointer"
              >
                <div className="flex items-center gap-3">
                  <item.icon className="w-5 h-5 text-muted-foreground" />
                  <span className="font-medium text-foreground">{item.label}</span>
                </div>
                {item.toggle ? (
                  <Switch defaultChecked />
                ) : item.value ? (
                  <div className="flex items-center gap-2">
                    <span className="text-sm text-muted-foreground">{item.value}</span>
                    <ChevronRight className="w-4 h-4 text-muted-foreground" />
                  </div>
                ) : (
                  <ChevronRight className="w-4 h-4 text-muted-foreground" />
                )}
              </motion.div>
            ))}
          </div>
        </section>
      ))}

      {/* App Info */}
      <div className="text-center text-sm text-muted-foreground pt-4">
        <p className="font-medium">Melody Player</p>
        <p>Version 1.0.0</p>
      </div>
    </div>
  );
}
