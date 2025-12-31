import React, { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Play, Pause, MoreVertical, Trash2, X, ListPlus, Heart } from 'lucide-react';
import { usePlayer, Track } from '@/contexts/PlayerContext';
import { usePlaylist } from '@/contexts/PlaylistContext';
import { AddToPlaylistModal } from '@/components/playlist/AddToPlaylistModal';
import { cn } from '@/lib/utils';

interface TrackListProps {
  tracks: Track[];
  title?: string;
  onDeleteTrack?: (trackId: string) => void;
  showDelete?: boolean;
}

export function TrackList({ tracks, title, onDeleteTrack, showDelete = true }: TrackListProps) {
  const { currentTrack, isPlaying, play, pause, removeFromQueue } = usePlayer();
  const { toggleLikeTrack, isTrackLiked } = usePlaylist();
  const [menuOpen, setMenuOpen] = useState<string | null>(null);
  const [confirmDelete, setConfirmDelete] = useState<string | null>(null);
  const [addToPlaylistTrack, setAddToPlaylistTrack] = useState<Track | null>(null);

  const handleTrackClick = (track: Track) => {
    if (currentTrack?.id === track.id) {
      isPlaying ? pause() : play();
    } else {
      play(track);
    }
  };

  const handleDelete = (trackId: string) => {
    if (onDeleteTrack) {
      onDeleteTrack(trackId);
    }
    removeFromQueue(trackId);
    setConfirmDelete(null);
    setMenuOpen(null);
  };

  const formatDuration = (seconds: number): string => {
    const mins = Math.floor(seconds / 60);
    const secs = Math.floor(seconds % 60);
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
              className={cn(
                "flex items-center gap-3 p-3 rounded-xl cursor-pointer transition-all relative",
                isActive 
                  ? "bg-primary/10 border border-primary/20" 
                  : "hover:bg-secondary/50"
              )}
            >
              {/* Album Art with Play Overlay */}
              <div 
                onClick={() => handleTrackClick(track)}
                className="relative w-12 h-12 rounded-lg overflow-hidden flex-shrink-0 group"
              >
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
              <div 
                onClick={() => handleTrackClick(track)}
                className="flex-1 min-w-0"
              >
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
                <div className="relative">
                  <button 
                    onClick={(e) => {
                      e.stopPropagation();
                      setMenuOpen(menuOpen === track.id ? null : track.id);
                    }}
                    className="p-2 rounded-full hover:bg-secondary transition-colors"
                  >
                    <MoreVertical className="w-4 h-4 text-muted-foreground" />
                  </button>

                  {/* Dropdown Menu */}
                  <AnimatePresence>
                    {menuOpen === track.id && (
                      <motion.div
                        initial={{ opacity: 0, scale: 0.95 }}
                        animate={{ opacity: 1, scale: 1 }}
                        exit={{ opacity: 0, scale: 0.95 }}
                        className="absolute right-0 top-full mt-1 z-50 bg-secondary border border-border rounded-lg shadow-xl overflow-hidden min-w-[160px]"
                      >
                        <button
                          onClick={(e) => {
                            e.stopPropagation();
                            toggleLikeTrack(track);
                            setMenuOpen(null);
                          }}
                          className="flex items-center gap-2 w-full px-4 py-2.5 text-sm text-foreground hover:bg-primary/10 transition-colors"
                        >
                          <Heart className={cn("w-4 h-4", isTrackLiked(track.id) && "fill-accent text-accent")} />
                          {isTrackLiked(track.id) ? 'Unlike' : 'Like'}
                        </button>
                        <button
                          onClick={(e) => {
                            e.stopPropagation();
                            setAddToPlaylistTrack(track);
                            setMenuOpen(null);
                          }}
                          className="flex items-center gap-2 w-full px-4 py-2.5 text-sm text-foreground hover:bg-primary/10 transition-colors"
                        >
                          <ListPlus className="w-4 h-4" />
                          Add to Playlist
                        </button>
                        {showDelete && (
                          <button
                            onClick={(e) => {
                              e.stopPropagation();
                              setConfirmDelete(track.id);
                            }}
                            className="flex items-center gap-2 w-full px-4 py-2.5 text-sm text-destructive hover:bg-destructive/10 transition-colors"
                          >
                            <Trash2 className="w-4 h-4" />
                            Delete
                          </button>
                        )}
                      </motion.div>
                    )}
                  </AnimatePresence>
                </div>
              </div>

              {/* Delete Confirmation Modal */}
              <AnimatePresence>
                {confirmDelete === track.id && (
                  <motion.div
                    initial={{ opacity: 0 }}
                    animate={{ opacity: 1 }}
                    exit={{ opacity: 0 }}
                    className="fixed inset-0 z-50 flex items-center justify-center bg-background/80 backdrop-blur-sm"
                    onClick={() => setConfirmDelete(null)}
                  >
                    <motion.div
                      initial={{ scale: 0.9, opacity: 0 }}
                      animate={{ scale: 1, opacity: 1 }}
                      exit={{ scale: 0.9, opacity: 0 }}
                      onClick={(e) => e.stopPropagation()}
                      className="bg-card border border-border rounded-2xl p-6 mx-4 max-w-sm w-full shadow-xl"
                    >
                      <div className="flex items-center justify-between mb-4">
                        <h3 className="text-lg font-semibold text-foreground">Delete Track</h3>
                        <button 
                          onClick={() => setConfirmDelete(null)}
                          className="p-1 rounded-full hover:bg-secondary"
                        >
                          <X className="w-5 h-5 text-muted-foreground" />
                        </button>
                      </div>
                      <p className="text-muted-foreground mb-6">
                        Are you sure you want to remove "{track.title}" from your library?
                      </p>
                      <div className="flex gap-3">
                        <button
                          onClick={() => setConfirmDelete(null)}
                          className="flex-1 py-2.5 px-4 rounded-lg bg-secondary text-foreground font-medium hover:bg-secondary/80 transition-colors"
                        >
                          Cancel
                        </button>
                        <button
                          onClick={() => handleDelete(track.id)}
                          className="flex-1 py-2.5 px-4 rounded-lg bg-destructive text-destructive-foreground font-medium hover:bg-destructive/90 transition-colors"
                        >
                          Delete
                        </button>
                      </div>
                    </motion.div>
                  </motion.div>
                )}
              </AnimatePresence>
            </motion.div>
          );
        })}
      </div>

      {/* Close menu when clicking outside */}
      {menuOpen && (
        <div 
          className="fixed inset-0 z-40" 
          onClick={() => setMenuOpen(null)}
        />
      )}

      {/* Add to Playlist Modal */}
      <AddToPlaylistModal
        isOpen={addToPlaylistTrack !== null}
        onClose={() => setAddToPlaylistTrack(null)}
        track={addToPlaylistTrack}
      />
    </div>
  );
}
