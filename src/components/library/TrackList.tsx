import React from 'react';
import { motion } from 'framer-motion';
import { Play, Pause, MoreVertical } from 'lucide-react';
import { usePlayer, Track } from '@/contexts/PlayerContext';
import { cn } from '@/lib/utils';

interface TrackListProps {
  tracks: Track[];
  title?: string;
}

export function TrackList({ tracks, title }: TrackListProps) {
  const { currentTrack, isPlaying, play, pause } = usePlayer();

  const handleTrackClick = (track: Track) => {
    if (currentTrack?.id === track.id) {
      isPlaying ? pause() : play();
    } else {
      play(track);
    }
  };

  const formatDuration = (seconds: number): string => {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins}:${secs.toString().padStart(2, '0')}`;
  };

  return (
    <div>
      {title && (
        <h2 className="text-xl font-bold text-foreground mb-4 px-1">{title}</h2>
      )}
      <div className="space-y-2">
        {tracks.map((track, index) => {
          const isActive = currentTrack?.id === track.id;
          const isCurrentPlaying = isActive && isPlaying;

          return (
            <motion.div
              key={track.id}
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: index * 0.05 }}
              onClick={() => handleTrackClick(track)}
              className={cn(
                "flex items-center gap-3 p-3 rounded-xl cursor-pointer transition-all",
                isActive 
                  ? "bg-primary/10 border border-primary/20" 
                  : "hover:bg-secondary/50"
              )}
            >
              {/* Album Art with Play Overlay */}
              <div className="relative w-12 h-12 rounded-lg overflow-hidden flex-shrink-0 group">
                <img 
                  src={track.artwork} 
                  alt={track.album}
                  className="w-full h-full object-cover"
                />
                <div className={cn(
                  "absolute inset-0 bg-background/60 flex items-center justify-center transition-opacity",
                  isActive ? "opacity-100" : "opacity-0 group-hover:opacity-100"
                )}>
                  {isCurrentPlaying ? (
                    <Pause className="w-5 h-5 text-primary" fill="currentColor" />
                  ) : (
                    <Play className="w-5 h-5 text-primary ml-0.5" fill="currentColor" />
                  )}
                </div>
              </div>

              {/* Track Info */}
              <div className="flex-1 min-w-0">
                <p className={cn(
                  "font-semibold truncate",
                  isActive ? "text-primary" : "text-foreground"
                )}>
                  {track.title}
                </p>
                <p className="text-sm text-muted-foreground truncate">
                  {track.artist}
                </p>
              </div>

              {/* Duration & More */}
              <div className="flex items-center gap-2">
                <span className="text-sm text-muted-foreground font-medium">
                  {formatDuration(track.duration)}
                </span>
                <button 
                  onClick={(e) => e.stopPropagation()}
                  className="p-2 rounded-full hover:bg-secondary transition-colors"
                >
                  <MoreVertical className="w-4 h-4 text-muted-foreground" />
                </button>
              </div>
            </motion.div>
          );
        })}
      </div>
    </div>
  );
}
