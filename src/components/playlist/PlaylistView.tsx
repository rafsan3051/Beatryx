import React, { useState } from 'react';
import { motion } from 'framer-motion';
import { ArrowLeft, Play, Shuffle, MoreVertical, Trash2, Edit2, Music } from 'lucide-react';
import { Playlist, usePlaylist } from '@/contexts/PlaylistContext';
import { usePlayer } from '@/contexts/PlayerContext';
import { cn } from '@/lib/utils';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';

interface PlaylistViewProps {
  playlist: Playlist;
  onBack: () => void;
}

export function PlaylistView({ playlist, onBack }: PlaylistViewProps) {
  const { play, setQueue, currentTrack, isPlaying } = usePlayer();
  const { removeTrackFromPlaylist, deletePlaylist, updatePlaylist } = usePlaylist();
  const [isEditing, setIsEditing] = useState(false);
  const [editName, setEditName] = useState(playlist.name);

  const handlePlayAll = () => {
    if (playlist.tracks.length === 0) return;
    setQueue(playlist.tracks);
    play(playlist.tracks[0]);
  };

  const handleShufflePlay = () => {
    if (playlist.tracks.length === 0) return;
    const shuffled = [...playlist.tracks].sort(() => Math.random() - 0.5);
    setQueue(shuffled);
    play(shuffled[0]);
  };

  const handlePlayTrack = (index: number) => {
    setQueue(playlist.tracks);
    play(playlist.tracks[index]);
  };

  const handleSaveEdit = () => {
    if (editName.trim()) {
      updatePlaylist(playlist.id, { name: editName.trim() });
    }
    setIsEditing(false);
  };

  const handleDeletePlaylist = () => {
    deletePlaylist(playlist.id);
    onBack();
  };

  const formatDuration = (seconds: number) => {
    const mins = Math.floor(seconds / 60);
    const secs = Math.floor(seconds % 60);
    return `${mins}:${secs.toString().padStart(2, '0')}`;
  };

  const totalDuration = playlist.tracks.reduce((acc, t) => acc + t.duration, 0);
  const totalMins = Math.floor(totalDuration / 60);

  return (
    <motion.div
      initial={{ opacity: 0, x: 20 }}
      animate={{ opacity: 1, x: 0 }}
      exit={{ opacity: 0, x: -20 }}
      className="pt-12 pb-32"
    >
      {/* Header */}
      <div className="flex items-center gap-3 mb-6">
        <button
          onClick={onBack}
          className="p-2 rounded-full hover:bg-secondary transition-colors"
        >
          <ArrowLeft className="w-6 h-6 text-foreground" />
        </button>
        <div className="flex-1">
          {isEditing ? (
            <input
              type="text"
              value={editName}
              onChange={(e) => setEditName(e.target.value)}
              onBlur={handleSaveEdit}
              onKeyDown={(e) => e.key === 'Enter' && handleSaveEdit()}
              className="text-xl font-bold text-foreground bg-transparent border-b-2 border-primary focus:outline-none w-full"
              autoFocus
            />
          ) : (
            <h1 className="text-xl font-bold text-foreground">{playlist.name}</h1>
          )}
        </div>
        <DropdownMenu>
          <DropdownMenuTrigger asChild>
            <button className="p-2 rounded-full hover:bg-secondary transition-colors">
              <MoreVertical className="w-5 h-5 text-muted-foreground" />
            </button>
          </DropdownMenuTrigger>
          <DropdownMenuContent align="end" className="bg-card border-border">
            <DropdownMenuItem onClick={() => setIsEditing(true)} className="gap-2">
              <Edit2 className="w-4 h-4" />
              Rename
            </DropdownMenuItem>
            <DropdownMenuItem onClick={handleDeletePlaylist} className="gap-2 text-destructive">
              <Trash2 className="w-4 h-4" />
              Delete Playlist
            </DropdownMenuItem>
          </DropdownMenuContent>
        </DropdownMenu>
      </div>

      {/* Playlist Info */}
      <div className="flex items-end gap-4 mb-6">
        <div className="w-32 h-32 rounded-xl bg-secondary shadow-lg overflow-hidden">
          {playlist.tracks[0]?.artwork ? (
            <img
              src={playlist.tracks[0].artwork}
              alt={playlist.name}
              className="w-full h-full object-cover"
            />
          ) : (
            <div className="w-full h-full flex items-center justify-center">
              <Music className="w-12 h-12 text-muted-foreground" />
            </div>
          )}
        </div>
        <div className="flex-1">
          <p className="text-muted-foreground text-sm">
            {playlist.tracks.length} track{playlist.tracks.length !== 1 ? 's' : ''} • {totalMins} min
          </p>
          {playlist.description && (
            <p className="text-muted-foreground text-sm mt-1">{playlist.description}</p>
          )}
        </div>
      </div>

      {/* Play Buttons */}
      <div className="flex gap-3 mb-6">
        <button
          onClick={handlePlayAll}
          disabled={playlist.tracks.length === 0}
          className="flex-1 flex items-center justify-center gap-2 py-3 rounded-xl gradient-primary text-primary-foreground font-medium disabled:opacity-50"
        >
          <Play className="w-5 h-5" fill="currentColor" />
          Play All
        </button>
        <button
          onClick={handleShufflePlay}
          disabled={playlist.tracks.length === 0}
          className="flex-1 flex items-center justify-center gap-2 py-3 rounded-xl bg-secondary text-foreground font-medium disabled:opacity-50"
        >
          <Shuffle className="w-5 h-5" />
          Shuffle
        </button>
      </div>

      {/* Track List */}
      {playlist.tracks.length === 0 ? (
        <div className="py-12 text-center">
          <Music className="w-16 h-16 mx-auto mb-4 text-muted-foreground opacity-50" />
          <p className="text-muted-foreground">No tracks in this playlist</p>
          <p className="text-sm text-muted-foreground mt-1">Add tracks from your library</p>
        </div>
      ) : (
        <div className="space-y-1">
          {playlist.tracks.map((track, index) => (
            <motion.div
              key={track.id}
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: index * 0.05 }}
              className={cn(
                "flex items-center gap-3 p-3 rounded-xl transition-colors group",
                currentTrack?.id === track.id ? "bg-primary/10" : "hover:bg-secondary"
              )}
            >
              <button
                onClick={() => handlePlayTrack(index)}
                className="relative flex-shrink-0"
              >
                <img
                  src={track.artwork}
                  alt={track.title}
                  className="w-12 h-12 rounded-lg object-cover"
                />
                {currentTrack?.id === track.id && isPlaying && (
                  <div className="absolute inset-0 flex items-center justify-center bg-black/40 rounded-lg">
                    <div className="flex gap-0.5">
                      {[...Array(3)].map((_, i) => (
                        <motion.div
                          key={i}
                          className="w-1 bg-primary rounded-full"
                          animate={{ height: [8, 16, 8] }}
                          transition={{ duration: 0.5, repeat: Infinity, delay: i * 0.1 }}
                        />
                      ))}
                    </div>
                  </div>
                )}
              </button>

              <div className="flex-1 min-w-0" onClick={() => handlePlayTrack(index)}>
                <p className={cn(
                  "font-medium truncate",
                  currentTrack?.id === track.id ? "text-primary" : "text-foreground"
                )}>
                  {track.title}
                </p>
                <p className="text-sm text-muted-foreground truncate">{track.artist}</p>
              </div>

              <span className="text-sm text-muted-foreground">
                {formatDuration(track.duration)}
              </span>

              <DropdownMenu>
                <DropdownMenuTrigger asChild>
                  <button className="p-2 rounded-full opacity-0 group-hover:opacity-100 hover:bg-secondary/80 transition-all">
                    <MoreVertical className="w-4 h-4 text-muted-foreground" />
                  </button>
                </DropdownMenuTrigger>
                <DropdownMenuContent align="end" className="bg-card border-border">
                  <DropdownMenuItem
                    onClick={() => removeTrackFromPlaylist(playlist.id, track.id)}
                    className="gap-2 text-destructive"
                  >
                    <Trash2 className="w-4 h-4" />
                    Remove from playlist
                  </DropdownMenuItem>
                </DropdownMenuContent>
              </DropdownMenu>
            </motion.div>
          ))}
        </div>
      )}
    </motion.div>
  );
}
