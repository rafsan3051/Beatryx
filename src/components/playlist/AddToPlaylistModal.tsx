import React, { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { X, Plus, Check, Music } from 'lucide-react';
import { usePlaylist } from '@/contexts/PlaylistContext';
import { Track } from '@/contexts/PlayerContext';
import { cn } from '@/lib/utils';

interface AddToPlaylistModalProps {
  isOpen: boolean;
  onClose: () => void;
  track: Track | null;
}

export function AddToPlaylistModal({ isOpen, onClose, track }: AddToPlaylistModalProps) {
  const { playlists, addTrackToPlaylist, createPlaylist } = usePlaylist();
  const [showCreate, setShowCreate] = useState(false);
  const [newPlaylistName, setNewPlaylistName] = useState('');

  const handleAddToPlaylist = (playlistId: string) => {
    if (!track) return;
    addTrackToPlaylist(playlistId, track);
    onClose();
  };

  const handleCreateAndAdd = () => {
    if (!newPlaylistName.trim() || !track) return;
    const playlist = createPlaylist(newPlaylistName.trim());
    addTrackToPlaylist(playlist.id, track);
    setNewPlaylistName('');
    setShowCreate(false);
    onClose();
  };

  const isTrackInPlaylist = (playlistId: string) => {
    const playlist = playlists.find(p => p.id === playlistId);
    return playlist?.tracks.some(t => t.id === track?.id) || false;
  };

  return (
    <AnimatePresence>
      {isOpen && (
        <>
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="fixed inset-0 z-50 bg-black/60 backdrop-blur-sm"
            onClick={onClose}
          />
          <motion.div
            initial={{ opacity: 0, scale: 0.95, y: 20 }}
            animate={{ opacity: 1, scale: 1, y: 0 }}
            exit={{ opacity: 0, scale: 0.95, y: 20 }}
            className="fixed inset-x-4 bottom-20 z-50 mx-auto max-w-md"
          >
            <div className="bg-card rounded-2xl shadow-xl overflow-hidden">
              {/* Header */}
              <div className="flex items-center justify-between p-4 border-b border-border">
                <h2 className="text-lg font-semibold text-foreground">Add to Playlist</h2>
                <button
                  onClick={onClose}
                  className="p-2 rounded-full hover:bg-secondary transition-colors"
                >
                  <X className="w-5 h-5 text-muted-foreground" />
                </button>
              </div>

              {/* Track Info */}
              {track && (
                <div className="flex items-center gap-3 p-4 bg-secondary/50">
                  <img
                    src={track.artwork}
                    alt={track.title}
                    className="w-12 h-12 rounded-lg object-cover"
                  />
                  <div className="flex-1 min-w-0">
                    <p className="font-medium text-foreground truncate">{track.title}</p>
                    <p className="text-sm text-muted-foreground truncate">{track.artist}</p>
                  </div>
                </div>
              )}

              {/* Create New Playlist */}
              {showCreate ? (
                <div className="p-4 border-b border-border">
                  <div className="flex gap-2">
                    <input
                      type="text"
                      placeholder="Playlist name"
                      value={newPlaylistName}
                      onChange={(e) => setNewPlaylistName(e.target.value)}
                      className="flex-1 px-3 py-2 bg-secondary rounded-lg text-foreground placeholder:text-muted-foreground focus:outline-none focus:ring-2 focus:ring-primary"
                      autoFocus
                    />
                    <button
                      onClick={handleCreateAndAdd}
                      disabled={!newPlaylistName.trim()}
                      className="px-4 py-2 bg-primary text-primary-foreground rounded-lg font-medium disabled:opacity-50"
                    >
                      Add
                    </button>
                  </div>
                </div>
              ) : (
                <button
                  onClick={() => setShowCreate(true)}
                  className="w-full flex items-center gap-3 p-4 hover:bg-secondary transition-colors border-b border-border"
                >
                  <div className="w-12 h-12 rounded-lg bg-primary/10 flex items-center justify-center">
                    <Plus className="w-6 h-6 text-primary" />
                  </div>
                  <span className="font-medium text-foreground">Create new playlist</span>
                </button>
              )}

              {/* Playlist List */}
              <div className="max-h-60 overflow-y-auto">
                {playlists.length === 0 ? (
                  <div className="p-8 text-center text-muted-foreground">
                    <Music className="w-12 h-12 mx-auto mb-2 opacity-50" />
                    <p>No playlists yet</p>
                  </div>
                ) : (
                  playlists.map((playlist) => {
                    const isAdded = isTrackInPlaylist(playlist.id);
                    return (
                      <button
                        key={playlist.id}
                        onClick={() => !isAdded && handleAddToPlaylist(playlist.id)}
                        disabled={isAdded}
                        className={cn(
                          "w-full flex items-center gap-3 p-4 transition-colors",
                          isAdded ? "opacity-50" : "hover:bg-secondary"
                        )}
                      >
                        <div className="w-12 h-12 rounded-lg bg-secondary flex items-center justify-center overflow-hidden">
                          {playlist.tracks[0]?.artwork ? (
                            <img
                              src={playlist.tracks[0].artwork}
                              alt={playlist.name}
                              className="w-full h-full object-cover"
                            />
                          ) : (
                            <Music className="w-6 h-6 text-muted-foreground" />
                          )}
                        </div>
                        <div className="flex-1 text-left">
                          <p className="font-medium text-foreground">{playlist.name}</p>
                          <p className="text-sm text-muted-foreground">
                            {playlist.tracks.length} track{playlist.tracks.length !== 1 ? 's' : ''}
                          </p>
                        </div>
                        {isAdded && (
                          <Check className="w-5 h-5 text-primary" />
                        )}
                      </button>
                    );
                  })
                )}
              </div>
            </div>
          </motion.div>
        </>
      )}
    </AnimatePresence>
  );
}
