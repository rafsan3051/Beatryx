import React from 'react';
import { motion } from 'framer-motion';
import { Play, Pause, SkipForward } from 'lucide-react';
import { usePlayer } from '@/contexts/PlayerContext';
import { cn } from '@/lib/utils';

interface MiniPlayerProps {
  onClick: () => void;
}

export function MiniPlayer({ onClick }: MiniPlayerProps) {
  const { currentTrack, isPlaying, currentTime, duration, togglePlay, next } = usePlayer();

  if (!currentTrack) return null;

  const progress = duration > 0 ? (currentTime / duration) * 100 : 0;

  return (
    <motion.div
      initial={{ y: 100, opacity: 0 }}
      animate={{ y: 0, opacity: 1 }}
      className="fixed bottom-20 left-3 right-3 z-40"
    >
      <div 
        className="relative glass rounded-2xl overflow-hidden shadow-soft border border-border/50"
      >
        {/* Progress bar */}
        <div className="absolute top-0 left-0 right-0 h-0.5 bg-progress-track">
          <motion.div 
            className="h-full bg-primary"
            style={{ width: `${progress}%` }}
            transition={{ duration: 0.1 }}
          />
        </div>

        <div className="flex items-center p-3 gap-3">
          {/* Album Art */}
          <motion.div 
            onClick={onClick}
            className="relative w-12 h-12 rounded-xl overflow-hidden flex-shrink-0 cursor-pointer"
            whileTap={{ scale: 0.95 }}
          >
            <img 
              src={currentTrack.artwork} 
              alt={currentTrack.album}
              className={cn(
                "w-full h-full object-cover",
                isPlaying && "animate-pulse"
              )}
            />
          </motion.div>

          {/* Track Info */}
          <div 
            onClick={onClick}
            className="flex-1 min-w-0 cursor-pointer"
          >
            <p className="font-semibold text-foreground truncate text-sm">
              {currentTrack.title}
            </p>
            <p className="text-xs text-muted-foreground truncate">
              {currentTrack.artist}
            </p>
          </div>

          {/* Controls */}
          <div className="flex items-center gap-1">
            <button 
              onClick={(e) => {
                e.stopPropagation();
                togglePlay();
              }}
              className="w-10 h-10 rounded-full flex items-center justify-center hover:bg-secondary transition-colors"
            >
              {isPlaying ? (
                <Pause className="w-5 h-5 text-foreground" fill="currentColor" />
              ) : (
                <Play className="w-5 h-5 text-foreground ml-0.5" fill="currentColor" />
              )}
            </button>
            <button 
              onClick={(e) => {
                e.stopPropagation();
                next();
              }}
              className="w-10 h-10 rounded-full flex items-center justify-center hover:bg-secondary transition-colors"
            >
              <SkipForward className="w-5 h-5 text-foreground" fill="currentColor" />
            </button>
          </div>
        </div>
      </div>
    </motion.div>
  );
}
