import React, { createContext, useContext, useEffect, useState } from 'react';

type Theme = 'light' | 'dark' | 'system';
type AccentColor = 'coral' | 'blue' | 'purple' | 'green' | 'pink' | 'amber' | 'cyan' | 'rose';
type AppTheme = 'default' | 'midnight' | 'forest' | 'sunset' | 'ocean' | 'lavender' | 'monochrome';

interface ThemeContextType {
  theme: Theme;
  setTheme: (theme: Theme) => void;
  accentColor: AccentColor;
  setAccentColor: (color: AccentColor) => void;
  appTheme: AppTheme;
  setAppTheme: (theme: AppTheme) => void;
  actualTheme: 'light' | 'dark';
}

const ThemeContext = createContext<ThemeContextType | undefined>(undefined);

// Accent colors with HSL values
const accentColors: Record<AccentColor, { primary: string; accent: string }> = {
  coral: { primary: '24 95% 53%', accent: '340 82% 52%' },
  blue: { primary: '217 91% 60%', accent: '199 89% 48%' },
  purple: { primary: '262 83% 58%', accent: '280 73% 53%' },
  green: { primary: '142 71% 45%', accent: '168 76% 42%' },
  pink: { primary: '330 81% 60%', accent: '340 82% 52%' },
  amber: { primary: '38 92% 50%', accent: '25 95% 53%' },
  cyan: { primary: '186 94% 42%', accent: '199 89% 48%' },
  rose: { primary: '350 89% 60%', accent: '340 82% 52%' },
};

// App themes with complete color schemes
const appThemes: Record<AppTheme, {
  light: Record<string, string>;
  dark: Record<string, string>;
}> = {
  default: {
    light: {
      '--background': '0 0% 98%',
      '--card': '0 0% 100%',
      '--secondary': '240 5% 92%',
      '--muted': '240 5% 96%',
    },
    dark: {
      '--background': '240 10% 6%',
      '--card': '240 10% 9%',
      '--secondary': '240 8% 14%',
      '--muted': '240 8% 14%',
    },
  },
  midnight: {
    light: {
      '--background': '230 25% 95%',
      '--card': '230 30% 98%',
      '--secondary': '230 20% 88%',
      '--muted': '230 20% 92%',
    },
    dark: {
      '--background': '230 25% 5%',
      '--card': '230 25% 8%',
      '--secondary': '230 20% 12%',
      '--muted': '230 20% 12%',
    },
  },
  forest: {
    light: {
      '--background': '140 15% 96%',
      '--card': '140 20% 99%',
      '--secondary': '140 15% 90%',
      '--muted': '140 15% 94%',
    },
    dark: {
      '--background': '150 20% 5%',
      '--card': '150 20% 8%',
      '--secondary': '150 15% 12%',
      '--muted': '150 15% 12%',
    },
  },
  sunset: {
    light: {
      '--background': '30 30% 97%',
      '--card': '30 40% 99%',
      '--secondary': '30 25% 90%',
      '--muted': '30 25% 94%',
    },
    dark: {
      '--background': '20 30% 5%',
      '--card': '20 30% 8%',
      '--secondary': '20 25% 12%',
      '--muted': '20 25% 12%',
    },
  },
  ocean: {
    light: {
      '--background': '200 30% 97%',
      '--card': '200 40% 99%',
      '--secondary': '200 25% 90%',
      '--muted': '200 25% 94%',
    },
    dark: {
      '--background': '200 35% 5%',
      '--card': '200 35% 8%',
      '--secondary': '200 30% 12%',
      '--muted': '200 30% 12%',
    },
  },
  lavender: {
    light: {
      '--background': '270 25% 97%',
      '--card': '270 30% 99%',
      '--secondary': '270 20% 90%',
      '--muted': '270 20% 94%',
    },
    dark: {
      '--background': '270 25% 5%',
      '--card': '270 25% 8%',
      '--secondary': '270 20% 12%',
      '--muted': '270 20% 12%',
    },
  },
  monochrome: {
    light: {
      '--background': '0 0% 98%',
      '--card': '0 0% 100%',
      '--secondary': '0 0% 92%',
      '--muted': '0 0% 96%',
    },
    dark: {
      '--background': '0 0% 5%',
      '--card': '0 0% 8%',
      '--secondary': '0 0% 14%',
      '--muted': '0 0% 14%',
    },
  },
};

export function ThemeProvider({ children }: { children: React.ReactNode }) {
  const [theme, setTheme] = useState<Theme>(() => {
    const stored = localStorage.getItem('theme');
    return (stored as Theme) || 'dark';
  });
  
  const [accentColor, setAccentColor] = useState<AccentColor>(() => {
    const stored = localStorage.getItem('accentColor');
    return (stored as AccentColor) || 'coral';
  });

  const [appTheme, setAppTheme] = useState<AppTheme>(() => {
    const stored = localStorage.getItem('appTheme');
    return (stored as AppTheme) || 'default';
  });

  const [actualTheme, setActualTheme] = useState<'light' | 'dark'>('dark');

  // Apply theme mode (light/dark)
  useEffect(() => {
    const root = window.document.documentElement;
    
    const getSystemTheme = () => {
      return window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
    };

    const applyTheme = () => {
      const effectiveTheme = theme === 'system' ? getSystemTheme() : theme;
      
      root.classList.remove('light', 'dark');
      root.classList.add(effectiveTheme);
      setActualTheme(effectiveTheme);
    };

    applyTheme();
    localStorage.setItem('theme', theme);

    const mediaQuery = window.matchMedia('(prefers-color-scheme: dark)');
    const handleChange = () => {
      if (theme === 'system') applyTheme();
    };
    
    mediaQuery.addEventListener('change', handleChange);
    return () => mediaQuery.removeEventListener('change', handleChange);
  }, [theme]);

  // Apply accent color
  useEffect(() => {
    const root = window.document.documentElement;
    const colors = accentColors[accentColor];
    
    root.style.setProperty('--primary', colors.primary);
    root.style.setProperty('--accent', colors.accent);
    root.style.setProperty('--ring', colors.primary);
    root.style.setProperty('--progress-fill', colors.primary);
    
    localStorage.setItem('accentColor', accentColor);
  }, [accentColor]);

  // Apply app theme
  useEffect(() => {
    const root = window.document.documentElement;
    const themeColors = appThemes[appTheme][actualTheme];
    
    Object.entries(themeColors).forEach(([property, value]) => {
      root.style.setProperty(property, value);
    });
    
    localStorage.setItem('appTheme', appTheme);
  }, [appTheme, actualTheme]);

  return (
    <ThemeContext.Provider value={{ 
      theme, 
      setTheme, 
      accentColor, 
      setAccentColor, 
      appTheme, 
      setAppTheme,
      actualTheme 
    }}>
      {children}
    </ThemeContext.Provider>
  );
}

export function useTheme() {
  const context = useContext(ThemeContext);
  if (context === undefined) {
    throw new Error('useTheme must be used within a ThemeProvider');
  }
  return context;
}

export { accentColors, appThemes };
export type { AccentColor, AppTheme, Theme };
