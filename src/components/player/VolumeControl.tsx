/**
 * Volume Control Component
 * Full-featured volume slider with mute toggle
 */
import React, { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Volume, Volume1, Volume2, VolumeX } from 'lucide-react';
import { Slider } from '@/components/ui/slider';
import { cn } from '@/lib/utils';

interface VolumeControlProps {
  volume: number;
  onVolumeChange: (volume: number) => void;
  orientation?: 'horizontal' | 'vertical';
  showLabel?: boolean;
  className?: string;
}

export function VolumeControl({
  volume,
  onVolumeChange,
  orientation = 'horizontal',
  showLabel = false,
  className,
}: VolumeControlProps) {
  const [previousVolume, setPreviousVolume] = useState(volume);
  const [showTooltip, setShowTooltip] = useState(false);

  const isMuted = volume === 0;

  const toggleMute = () => {
    if (isMuted) {
      onVolumeChange(previousVolume || 0.5);
    } else {
      setPreviousVolume(volume);
      onVolumeChange(0);
    }
  };

  const getVolumeIcon = () => {
    if (isMuted) return VolumeX;
    if (volume < 0.33) return Volume;
    if (volume < 0.66) return Volume1;
    return Volume2;
  };

  const VolumeIcon = getVolumeIcon();
  const volumePercent = Math.round(volume * 100);

  if (orientation === 'vertical') {
    return (
      <div className={cn("flex flex-col items-center gap-2", className)}>
        <button
          onClick={toggleMute}
          className="p-2 rounded-full hover:bg-secondary transition-colors"
          onMouseEnter={() => setShowTooltip(true)}
          onMouseLeave={() => setShowTooltip(false)}
        >
          <VolumeIcon className={cn(
            "w-5 h-5",
            isMuted ? "text-muted-foreground" : "text-foreground"
          )} />
        </button>
        
        <div className="h-24 py-2">
          <Slider
            orientation="vertical"
            value={[volume * 100]}
            max={100}
            step={1}
            onValueChange={([value]) => onVolumeChange(value / 100)}
          />
        </div>

        {showLabel && (
          <span className="text-xs text-muted-foreground font-mono">
            {volumePercent}%
          </span>
        )}
      </div>
    );
  }

  return (
    <div className={cn("flex items-center gap-2", className)}>
      <button
        onClick={toggleMute}
        className="p-1.5 rounded-full hover:bg-secondary transition-colors relative"
        onMouseEnter={() => setShowTooltip(true)}
        onMouseLeave={() => setShowTooltip(false)}
      >
        <VolumeIcon className={cn(
          "w-5 h-5",
          isMuted ? "text-muted-foreground" : "text-foreground"
        )} />
        
        <AnimatePresence>
          {showTooltip && (
            <motion.div
              initial={{ opacity: 0, y: 4 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: 4 }}
              className="absolute -top-8 left-1/2 -translate-x-1/2 px-2 py-1 rounded bg-popover text-popover-foreground text-xs whitespace-nowrap shadow-lg"
            >
              {isMuted ? 'Unmute' : 'Mute'}
            </motion.div>
          )}
        </AnimatePresence>
      </button>
      
      <div className="w-20 md:w-24">
        <Slider
          value={[volume * 100]}
          max={100}
          step={1}
          onValueChange={([value]) => onVolumeChange(value / 100)}
        />
      </div>

      {showLabel && (
        <span className="text-xs text-muted-foreground font-mono w-8">
          {volumePercent}%
        </span>
      )}
    </div>
  );
}
