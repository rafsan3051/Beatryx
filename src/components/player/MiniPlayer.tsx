import React from 'react';
import { motion, PanInfo, useMotionValue, useTransform } from 'framer-motion';
import { Play, Pause, SkipForward, ChevronUp } from 'lucide-react';
import { usePlayer } from '@/contexts/PlayerContext';
import { cn } from '@/lib/utils';

interface MiniPlayerProps {
  onClick: () => void;
}

export function MiniPlayer({ onClick }: MiniPlayerProps) {
  const { currentTrack, isPlaying, currentTime, duration, togglePlay, next } = usePlayer();
  const y = useMotionValue(0);
  const opacity = useTransform(y, [-100, 0], [0.8, 1]);
  const scale = useTransform(y, [-100, 0], [0.95, 1]);

  if (!currentTrack) return null;

  const progress = duration > 0 ? (currentTime / duration) * 100 : 0;

  const handleDragEnd = (event: MouseEvent | TouchEvent | PointerEvent, info: PanInfo) => {
    if (info.offset.y < -50 || info.velocity.y < -500) {
      onClick();
    }
  };

  return (
    <motion.div
      initial={{ y: 100, opacity: 0 }}
      animate={{ y: 0, opacity: 1 }}
      className="fixed bottom-20 left-3 right-3 z-40"
      drag="y"
      dragConstraints={{ top: -100, bottom: 0 }}
      dragElastic={0.2}
      onDragEnd={handleDragEnd}
      style={{ y, opacity, scale }}
    >
      <div 
        className="relative glass rounded-2xl overflow-hidden shadow-soft border border-border/50 backdrop-blur-xl"
      >
        {/* Drag indicator */}
        <div className="absolute top-2 left-1/2 -translate-x-1/2 w-12 h-1 bg-muted-foreground/30 rounded-full" />
        
        {/* Progress bar */}
        <div className="absolute top-0 left-0 right-0 h-0.5 bg-progress-track">
          <motion.div 
            className="h-full bg-gradient-to-r from-primary via-accent to-primary"
            style={{ width: `${progress}%` }}
            transition={{ duration: 0.1 }}
          />
        </div>

        <div className="flex items-center p-3 gap-3 pt-5">
          {/* Album Art */}
          <motion.div 
            onClick={onClick}
            className="relative w-12 h-12 rounded-xl overflow-hidden flex-shrink-0 cursor-pointer shadow-lg"
            whileTap={{ scale: 0.95 }}
            animate={isPlaying ? {
              boxShadow: [
                "0 0 0 0 rgba(var(--primary-rgb), 0.4)",
                "0 0 0 10px rgba(var(--primary-rgb), 0)",
              ],
            } : {}}
            transition={{ duration: 1.5, repeat: Infinity }}
          >
            <img 
              src={currentTrack.artwork} 
              alt={currentTrack.album}
              className="w-full h-full object-cover"
            />
            <div className="absolute inset-0 bg-gradient-to-t from-black/20 to-transparent" />
          </motion.div>

          {/* Track Info */}
          <div 
            onClick={onClick}
            className="flex-1 min-w-0 cursor-pointer"
          >
            <div className="flex items-center gap-2">
              <div className="flex-1 min-w-0">
                <p className="font-semibold text-foreground truncate text-sm">
                  {currentTrack.title}
                </p>
                <p className="text-xs text-muted-foreground truncate">
                  {currentTrack.artist}
                </p>
              </div>
              <ChevronUp className="w-4 h-4 text-muted-foreground/50 flex-shrink-0 animate-bounce" />
            </div>
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
