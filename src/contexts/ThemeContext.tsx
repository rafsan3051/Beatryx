import React, { createContext, useContext, useEffect, useState } from 'react';

type Theme = 'light' | 'dark' | 'system';
type AccentColor = 'coral' | 'blue' | 'purple' | 'green' | 'pink';

interface ThemeContextType {
  theme: Theme;
  setTheme: (theme: Theme) => void;
  accentColor: AccentColor;
  setAccentColor: (color: AccentColor) => void;
  actualTheme: 'light' | 'dark';
}

const ThemeContext = createContext<ThemeContextType | undefined>(undefined);

const accentColors: Record<AccentColor, { primary: string; accent: string }> = {
  coral: { primary: '24 95% 53%', accent: '340 82% 52%' },
  blue: { primary: '217 91% 60%', accent: '199 89% 48%' },
  purple: { primary: '262 83% 58%', accent: '280 73% 53%' },
  green: { primary: '142 71% 45%', accent: '168 76% 42%' },
  pink: { primary: '330 81% 60%', accent: '340 82% 52%' },
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

  const [actualTheme, setActualTheme] = useState<'light' | 'dark'>('dark');

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

  useEffect(() => {
    const root = window.document.documentElement;
    const colors = accentColors[accentColor];
    
    root.style.setProperty('--primary', colors.primary);
    root.style.setProperty('--accent', colors.accent);
    root.style.setProperty('--ring', colors.primary);
    root.style.setProperty('--progress-fill', colors.primary);
    
    localStorage.setItem('accentColor', accentColor);
  }, [accentColor]);

  return (
    <ThemeContext.Provider value={{ theme, setTheme, accentColor, setAccentColor, actualTheme }}>
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
