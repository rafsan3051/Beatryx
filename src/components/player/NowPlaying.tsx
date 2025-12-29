import React, { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { 
  Play, 
  Pause, 
  SkipBack, 
  SkipForward, 
  Shuffle, 
  Repeat, 
  Repeat1, 
  Heart, 
  ListMusic,
  ChevronDown,
  Volume2,
  Timer
} from 'lucide-react';
import { usePlayer } from '@/contexts/PlayerContext';
import { useSleepTimer } from '@/contexts/SleepTimerContext';
import { Slider } from '@/components/ui/slider';
import { SleepTimerModal } from './SleepTimerModal';
import { cn } from '@/lib/utils';

function formatTime(seconds: number): string {
  const mins = Math.floor(seconds / 60);
  const secs = Math.floor(seconds % 60);
  return `${mins}:${secs.toString().padStart(2, '0')}`;
}

interface NowPlayingProps {
  isExpanded: boolean;
  onCollapse: () => void;
}

export function NowPlaying({ isExpanded, onCollapse }: NowPlayingProps) {
  const { 
    currentTrack, 
    isPlaying, 
    currentTime, 
    duration,
    isShuffle,
    repeatMode,
    togglePlay, 
    next, 
    previous,
    seek,
    toggleShuffle,
    toggleRepeat
  } = usePlayer();

  const { sleepTimerMinutes, remainingTime } = useSleepTimer();
  const [isLiked, setIsLiked] = useState(false);
  const [showSleepTimer, setShowSleepTimer] = useState(false);

  const formatTimerDisplay = (seconds: number) => {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins}:${secs.toString().padStart(2, '0')}`;
  };

  if (!currentTrack) return null;

  const progress = duration > 0 ? (currentTime / duration) * 100 : 0;

  return (
    <AnimatePresence>
      {isExpanded && (
        <motion.div
          initial={{ y: '100%' }}
          animate={{ y: 0 }}
          exit={{ y: '100%' }}
          transition={{ type: 'spring', damping: 30, stiffness: 300 }}
          className="fixed inset-0 z-50 bg-background"
        >
          <div className="flex flex-col h-full px-6 py-4 safe-area-inset">
            {/* Header */}
            <div className="flex items-center justify-between mb-8">
              <button 
                onClick={onCollapse}
                className="p-2 -ml-2 rounded-full hover:bg-secondary transition-colors"
              >
                <ChevronDown className="w-6 h-6 text-foreground" />
              </button>
              <span className="text-sm font-medium text-muted-foreground uppercase tracking-wider">
                Now Playing
              </span>
              <button className="p-2 -mr-2 rounded-full hover:bg-secondary transition-colors">
                <ListMusic className="w-6 h-6 text-foreground" />
              </button>
            </div>

            {/* Album Art */}
            <div className="flex-1 flex items-center justify-center px-4 mb-8">
              <motion.div
                animate={{ rotate: isPlaying ? 360 : 0 }}
                transition={{ 
                  duration: 8, 
                  repeat: isPlaying ? Infinity : 0, 
                  ease: 'linear' 
                }}
                className={cn(
                  "relative w-full max-w-[320px] aspect-square rounded-full overflow-hidden shadow-glow",
                  !isPlaying && "animation-paused"
                )}
              >
                <img 
                  src={currentTrack.artwork} 
                  alt={currentTrack.album}
                  className="w-full h-full object-cover"
                />
                <div className="absolute inset-0 flex items-center justify-center">
                  <div className="w-16 h-16 rounded-full bg-background shadow-lg" />
                </div>
              </motion.div>
            </div>

            {/* Track Info */}
            <div className="text-center mb-6">
              <motion.h2 
                key={currentTrack.id}
                initial={{ opacity: 0, y: 10 }}
                animate={{ opacity: 1, y: 0 }}
                className="text-2xl font-bold text-foreground mb-1 truncate"
              >
                {currentTrack.title}
              </motion.h2>
              <p className="text-muted-foreground font-medium">{currentTrack.artist}</p>
            </div>

            {/* Progress */}
            <div className="mb-6">
              <Slider
                value={[progress]}
                max={100}
                step={0.1}
                onValueChange={([value]) => seek((value / 100) * duration)}
                className="mb-2"
              />
              <div className="flex justify-between text-xs text-muted-foreground font-medium">
                <span>{formatTime(currentTime)}</span>
                <span>{formatTime(duration)}</span>
              </div>
            </div>

            {/* Controls */}
            <div className="flex items-center justify-between mb-8">
              <button 
                onClick={toggleShuffle}
                className={cn(
                  "p-3 rounded-full transition-colors",
                  isShuffle ? "text-primary" : "text-muted-foreground hover:text-foreground"
                )}
              >
                <Shuffle className="w-5 h-5" />
              </button>
              
              <button 
                onClick={previous}
                className="p-3 rounded-full text-foreground hover:bg-secondary transition-colors"
              >
                <SkipBack className="w-7 h-7" fill="currentColor" />
              </button>
              
              <button 
                onClick={togglePlay}
                className="w-16 h-16 rounded-full gradient-primary flex items-center justify-center shadow-glow transition-transform hover:scale-105 active:scale-95"
              >
                {isPlaying ? (
                  <Pause className="w-8 h-8 text-primary-foreground" fill="currentColor" />
                ) : (
                  <Play className="w-8 h-8 text-primary-foreground ml-1" fill="currentColor" />
                )}
              </button>
              
              <button 
                onClick={next}
                className="p-3 rounded-full text-foreground hover:bg-secondary transition-colors"
              >
                <SkipForward className="w-7 h-7" fill="currentColor" />
              </button>
              
              <button 
                onClick={toggleRepeat}
                className={cn(
                  "p-3 rounded-full transition-colors",
                  repeatMode !== 'off' ? "text-primary" : "text-muted-foreground hover:text-foreground"
                )}
              >
                {repeatMode === 'one' ? (
                  <Repeat1 className="w-5 h-5" />
                ) : (
                  <Repeat className="w-5 h-5" />
                )}
              </button>
            </div>

            {/* Bottom Actions */}
            <div className="flex items-center justify-between pb-4">
              <button 
                onClick={() => setIsLiked(!isLiked)}
                className="p-3 rounded-full hover:bg-secondary transition-colors"
              >
                <Heart 
                  className={cn(
                    "w-6 h-6 transition-colors",
                    isLiked ? "text-accent fill-accent" : "text-muted-foreground"
                  )} 
                />
              </button>

              {/* Sleep Timer Button */}
              <button
                onClick={() => setShowSleepTimer(true)}
                className={cn(
                  "flex items-center gap-2 px-3 py-2 rounded-full transition-colors",
                  sleepTimerMinutes !== null
                    ? "bg-primary/10 text-primary"
                    : "hover:bg-secondary text-muted-foreground"
                )}
              >
                <Timer className="w-5 h-5" />
                {sleepTimerMinutes !== null && (
                  <span className="text-sm font-medium">
                    {formatTimerDisplay(remainingTime)}
                  </span>
                )}
              </button>
              
              <div className="flex items-center gap-2">
                <Volume2 className="w-5 h-5 text-muted-foreground" />
                <div className="w-24">
                  <Slider defaultValue={[80]} max={100} step={1} />
                </div>
              </div>
            </div>
          </div>

          {/* Sleep Timer Modal */}
          <SleepTimerModal
            isOpen={showSleepTimer}
            onClose={() => setShowSleepTimer(false)}
          />
        </motion.div>
      )}
    </AnimatePresence>
  );
}
