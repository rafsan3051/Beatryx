/**
 * App Header Component
 * Displays logo and app branding
 */
import React from 'react';
import { motion } from 'framer-motion';
import { useTheme } from '@/contexts/ThemeContext';
import { RefreshCw } from 'lucide-react';

interface HeaderProps {
  onRefresh?: () => void;
  isRefreshing?: boolean;
}

export function Header({ onRefresh, isRefreshing }: HeaderProps) {
  const { appIcon } = useTheme();

  return (
    <motion.header
      initial={{ opacity: 0, y: -20 }}
      animate={{ opacity: 1, y: 0 }}
      className="flex items-center justify-between py-4 mb-2"
    >
      <div className="flex items-center gap-3">
        <motion.img
          src={`/icons/${appIcon}.png`}
          alt="Beatryx"
          className="w-10 h-10 rounded-xl shadow-lg"
          whileHover={{ scale: 1.05 }}
          whileTap={{ scale: 0.95 }}
        />
        <div>
          <h1 className="text-xl font-bold text-foreground leading-tight">
            Beatryx
          </h1>
          <p className="text-xs text-muted-foreground -mt-0.5">
            beats with an edge
          </p>
        </div>
      </div>

      {onRefresh && (
        <motion.button
          onClick={onRefresh}
          disabled={isRefreshing}
          whileHover={{ scale: 1.05 }}
          whileTap={{ scale: 0.95 }}
          className="p-2.5 rounded-full bg-secondary/50 hover:bg-secondary transition-colors disabled:opacity-50"
          title="Refresh music library"
        >
          <RefreshCw 
            className={`w-5 h-5 text-muted-foreground ${isRefreshing ? 'animate-spin' : ''}`}
          />
        </motion.button>
      )}
    </motion.header>
  );
}
