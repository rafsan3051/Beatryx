import React, { useState } from 'react';
import { motion, AnimatePresence, PanInfo, useMotionValue, useTransform } from 'framer-motion';
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
  Timer,
  ArrowLeft
} from 'lucide-react';
import { usePlayer } from '@/contexts/PlayerContext';
import { useSleepTimer } from '@/contexts/SleepTimerContext';
import { usePlaylist } from '@/contexts/PlaylistContext';
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
  onOpenQueue?: () => void;
}

export function NowPlaying({ isExpanded, onCollapse, onOpenQueue }: NowPlayingProps) {
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
  const { toggleLikeTrack, isTrackLiked } = usePlaylist();
  const [showSleepTimer, setShowSleepTimer] = useState(false);
  
  const y = useMotionValue(0);
  const opacity = useTransform(y, [0, 300], [1, 0]);

  const isLiked = currentTrack ? isTrackLiked(currentTrack.id) : false;

  const formatTimerDisplay = (seconds: number) => {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins}:${secs.toString().padStart(2, '0')}`;
  };

  const handleDragEnd = (event: MouseEvent | TouchEvent | PointerEvent, info: PanInfo) => {
    if (info.offset.y > 100 || info.velocity.y > 500) {
      onCollapse();
    }
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
          drag="y"
          dragConstraints={{ top: 0, bottom: 300 }}
          dragElastic={0.2}
          onDragEnd={handleDragEnd}
          style={{ y, opacity }}
          className="fixed inset-0 z-50 bg-gradient-to-b from-background via-background to-background/95"
        >
          <div className="flex flex-col h-full px-6 py-4 safe-area-inset">
            {/* Drag indicator */}
            <div className="absolute top-2 left-1/2 -translate-x-1/2 w-12 h-1.5 bg-muted-foreground/30 rounded-full" />
            
            {/* Header */}
            <div className="flex items-center justify-between mb-8 mt-4">
              <button 
                onClick={onCollapse}
                className="p-2 -ml-2 rounded-full hover:bg-secondary/80 transition-all active:scale-95"
              >
                <ArrowLeft className="w-6 h-6 text-foreground" />
              </button>
              <span className="text-sm font-semibold text-muted-foreground uppercase tracking-wider">
                Now Playing
              </span>
              <button 
                onClick={onOpenQueue} 
                className="p-2 -mr-2 rounded-full hover:bg-secondary/80 transition-all active:scale-95"
              >
                <ListMusic className="w-6 h-6 text-foreground" />
              </button>
            </div>

            {/* Album Art */}
            <div className="flex-1 flex items-center justify-center px-4 mb-8">
              <div className="relative">
                {/* Glowing background effect */}
                <motion.div
                  animate={{
                    scale: isPlaying ? [1, 1.1, 1] : 1,
                    opacity: isPlaying ? [0.3, 0.5, 0.3] : 0,
                  }}
                  transition={{ duration: 3, repeat: Infinity, ease: "easeInOut" }}
                  className="absolute inset-0 -m-8 bg-primary/20 rounded-full blur-3xl"
                />
                
                <motion.div
                  animate={{ rotate: isPlaying ? 360 : 0 }}
                  transition={{ 
                    duration: 20, 
                    repeat: isPlaying ? Infinity : 0, 
                    ease: 'linear' 
                  }}
                  className={cn(
                    "relative w-full max-w-[320px] aspect-square rounded-full overflow-hidden shadow-2xl ring-4 ring-border/50",
                    !isPlaying && "animation-paused"
                  )}
                >
                  <img 
                    src={currentTrack.artwork} 
                    alt={currentTrack.album}
                    className="w-full h-full object-cover"
                  />
                  {/* Center hole effect */}
                  <div className="absolute inset-0 flex items-center justify-center">
                    <div className="w-20 h-20 rounded-full bg-background/90 shadow-2xl backdrop-blur-sm border-4 border-border/30" />
                  </div>
                  {/* Vinyl grooves effect */}
                  <div className="absolute inset-0 opacity-10">
                    {[...Array(8)].map((_, i) => (
                      <div
                        key={i}
                        className="absolute inset-0 rounded-full border border-background"
                        style={{
                          margin: `${(i + 1) * 20}px`,
                        }}
                      />
                    ))}
                  </div>
                </motion.div>
              </div>
            </div>

            {/* Track Info */}
            <div className="text-center mb-6 space-y-1">
              <motion.h2 
                key={currentTrack.id}
                initial={{ opacity: 0, y: 10 }}
                animate={{ opacity: 1, y: 0 }}
                className="text-2xl font-bold text-foreground mb-1 truncate px-4"
              >
                {currentTrack.title}
              </motion.h2>
              <p className="text-lg text-muted-foreground font-medium">{currentTrack.artist}</p>
              <p className="text-sm text-muted-foreground/70">{currentTrack.album}</p>
            </div>

            {/* Progress */}
            <div className="mb-6 px-2">
              <Slider
                value={[progress]}
                max={100}
                step={0.1}
                onValueChange={([value]) => seek((value / 100) * duration)}
                className="mb-3"
              />
              <div className="flex justify-between text-sm text-muted-foreground font-semibold">
                <span>{formatTime(currentTime)}</span>
                <span>-{formatTime(duration - currentTime)}</span>
              </div>
            </div>

            {/* Controls */}
            <div className="flex items-center justify-between mb-8 px-4">
              <motion.button 
                whileTap={{ scale: 0.9 }}
                onClick={toggleShuffle}
                className={cn(
                  "p-3 rounded-full transition-all",
                  isShuffle ? "text-primary bg-primary/10" : "text-muted-foreground hover:text-foreground hover:bg-secondary"
                )}
              >
                <Shuffle className="w-5 h-5" />
              </motion.button>
              
              <motion.button 
                whileTap={{ scale: 0.9 }}
                onClick={previous}
                className="p-3 rounded-full text-foreground hover:bg-secondary transition-all"
              >
                <SkipBack className="w-8 h-8" fill="currentColor" />
              </motion.button>
              
              <motion.button 
                whileTap={{ scale: 0.95 }}
                onClick={togglePlay}
                className="w-20 h-20 rounded-full gradient-primary flex items-center justify-center shadow-glow transition-all hover:scale-105 active:scale-95"
              >
                {isPlaying ? (
                  <Pause className="w-10 h-10 text-primary-foreground" fill="currentColor" />
                ) : (
                  <Play className="w-10 h-10 text-primary-foreground ml-1" fill="currentColor" />
                )}
              </motion.button>
              
              <motion.button 
                whileTap={{ scale: 0.9 }}
                onClick={next}
                className="p-3 rounded-full text-foreground hover:bg-secondary transition-all"
              >
                <SkipForward className="w-8 h-8" fill="currentColor" />
              </motion.button>
              
              <motion.button 
                whileTap={{ scale: 0.9 }}
                onClick={toggleRepeat}
                className={cn(
                  "p-3 rounded-full transition-all",
                  repeatMode !== 'off' ? "text-primary bg-primary/10" : "text-muted-foreground hover:text-foreground hover:bg-secondary"
                )}
              >
                {repeatMode === 'one' ? (
                  <Repeat1 className="w-5 h-5" />
                ) : (
                  <Repeat className="w-5 h-5" />
                )}
              </motion.button>
            </div>

            {/* Bottom Actions */}
            <div className="flex items-center justify-between pb-4">
              <button 
                onClick={() => currentTrack && toggleLikeTrack(currentTrack)}
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
