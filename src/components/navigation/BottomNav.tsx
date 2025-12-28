import React from 'react';
import { Home, Search, Library, Settings } from 'lucide-react';
import { cn } from '@/lib/utils';

type Tab = 'home' | 'search' | 'library' | 'settings';

interface BottomNavProps {
  activeTab: Tab;
  onTabChange: (tab: Tab) => void;
}

const tabs: { id: Tab; label: string; icon: React.ElementType }[] = [
  { id: 'home', label: 'Home', icon: Home },
  { id: 'search', label: 'Search', icon: Search },
  { id: 'library', label: 'Library', icon: Library },
  { id: 'settings', label: 'Settings', icon: Settings },
];

export function BottomNav({ activeTab, onTabChange }: BottomNavProps) {
  return (
    <nav className="fixed bottom-0 left-0 right-0 z-30 glass border-t border-border/50 safe-area-inset-bottom">
      <div className="flex items-center justify-around h-16">
        {tabs.map(({ id, label, icon: Icon }) => {
          const isActive = activeTab === id;
          
          return (
            <button
              key={id}
              onClick={() => onTabChange(id)}
              className={cn(
                "flex flex-col items-center justify-center gap-1 flex-1 h-full transition-colors",
                isActive ? "text-primary" : "text-muted-foreground"
              )}
            >
              <Icon 
                className={cn(
                  "w-5 h-5 transition-transform",
                  isActive && "scale-110"
                )} 
                strokeWidth={isActive ? 2.5 : 2}
              />
              <span className={cn(
                "text-xs font-medium",
                isActive && "text-gradient"
              )}>
                {label}
              </span>
            </button>
          );
        })}
      </div>
    </nav>
  );
}
