import React, { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { ListMusic, Heart, Clock, Plus, Grid, List, Music } from 'lucide-react';
import { TrackList } from '@/components/library/TrackList';
import { PlaylistCard } from '@/components/library/PlaylistCard';
import { CreatePlaylistModal } from '@/components/playlist/CreatePlaylistModal';
import { PlaylistView } from '@/components/playlist/PlaylistView';
import { usePlayer } from '@/contexts/PlayerContext';
import { usePlaylist, Playlist } from '@/contexts/PlaylistContext';
import { cn } from '@/lib/utils';

type ViewMode = 'grid' | 'list';
type Filter = 'all' | 'playlists' | 'liked' | 'recent';

export function LibraryScreen() {
  const [viewMode, setViewMode] = useState<ViewMode>('grid');
  const [filter, setFilter] = useState<Filter>('all');
  const [showCreateModal, setShowCreateModal] = useState(false);
  const [selectedPlaylist, setSelectedPlaylist] = useState<Playlist | null>(null);
  const { queue, play, setQueue } = usePlayer();
  const { playlists, likedTracks } = usePlaylist();

  const filters: { id: Filter; label: string; icon: React.ElementType }[] = [
    { id: 'all', label: 'All', icon: ListMusic },
    { id: 'playlists', label: 'Playlists', icon: ListMusic },
    { id: 'liked', label: 'Liked', icon: Heart },
    { id: 'recent', label: 'Recent', icon: Clock },
  ];

  const handlePlaylistClick = (playlist: Playlist) => {
    setSelectedPlaylist(playlist);
  };

  const handlePlayLiked = () => {
    if (likedTracks.length > 0) {
      setQueue(likedTracks);
      play(likedTracks[0]);
    }
  };

  // Show playlist view if one is selected
  if (selectedPlaylist) {
    const currentPlaylist = playlists.find(p => p.id === selectedPlaylist.id);
    if (currentPlaylist) {
      return (
        <PlaylistView
          playlist={currentPlaylist}
          onBack={() => setSelectedPlaylist(null)}
        />
      );
    }
  }

  return (
    <div className="flex flex-col gap-6 pb-40">
      {/* Header */}
      <motion.div
        initial={{ opacity: 0, y: -20 }}
        animate={{ opacity: 1, y: 0 }}
        className="pt-4 flex items-center justify-between"
      >
        <h1 className="text-2xl font-bold text-foreground">Your Library</h1>
        <div className="flex items-center gap-2">
          <button 
            onClick={() => setShowCreateModal(true)}
            className="p-2 rounded-full hover:bg-secondary transition-colors"
          >
            <Plus className="w-5 h-5 text-foreground" />
          </button>
          <button
            onClick={() => setViewMode(viewMode === 'grid' ? 'list' : 'grid')}
            className="p-2 rounded-full hover:bg-secondary transition-colors"
          >
            {viewMode === 'grid' ? (
              <List className="w-5 h-5 text-foreground" />
            ) : (
              <Grid className="w-5 h-5 text-foreground" />
            )}
          </button>
        </div>
      </motion.div>

      {/* Filters */}
      <div className="flex gap-2 overflow-x-auto pb-2 -mx-1 px-1 no-scrollbar">
        {filters.map(({ id, label }) => (
          <button
            key={id}
            onClick={() => setFilter(id)}
            className={cn(
              "px-4 py-2 rounded-full text-sm font-medium whitespace-nowrap transition-colors",
              filter === id
                ? "bg-primary text-primary-foreground"
                : "bg-secondary text-secondary-foreground hover:bg-secondary/80"
            )}
          >
            {label}
          </button>
        ))}
      </div>

      {/* Content */}
      <AnimatePresence mode="wait">
        {(filter === 'all' || filter === 'playlists') && (
          <motion.section
            key="playlists"
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -20 }}
          >
            <div className="flex items-center justify-between mb-4">
              <h2 className="text-lg font-semibold text-foreground">Playlists</h2>
              <button
                onClick={() => setShowCreateModal(true)}
                className="text-sm text-primary font-medium"
              >
                Create New
              </button>
            </div>
            
            {playlists.length === 0 ? (
              <div className="py-8 text-center">
                <Music className="w-16 h-16 mx-auto mb-4 text-muted-foreground opacity-50" />
                <p className="text-muted-foreground">No playlists yet</p>
                <button
                  onClick={() => setShowCreateModal(true)}
                  className="mt-3 px-4 py-2 bg-primary text-primary-foreground rounded-full text-sm font-medium"
                >
                  Create Your First Playlist
                </button>
              </div>
            ) : viewMode === 'grid' ? (
              <div className="grid grid-cols-2 gap-4">
                {playlists.map((playlist) => (
                  <div key={playlist.id} onClick={() => handlePlaylistClick(playlist)}>
                    <PlaylistCard
                      title={playlist.name}
                      subtitle={playlist.description || `${playlist.tracks.length} tracks`}
                      artwork={playlist.tracks[0]?.artwork || ''}
                      trackCount={playlist.tracks.length}
                    />
                  </div>
                ))}
              </div>
            ) : (
              <div className="space-y-2">
                {playlists.map((playlist, index) => (
                  <motion.div
                    key={playlist.id}
                    initial={{ opacity: 0, x: -20 }}
                    animate={{ opacity: 1, x: 0 }}
                    transition={{ delay: index * 0.05 }}
                    onClick={() => handlePlaylistClick(playlist)}
                    className="flex items-center gap-3 p-2 rounded-lg hover:bg-secondary/50 cursor-pointer transition-colors"
                  >
                    <div className="w-14 h-14 rounded-lg bg-secondary overflow-hidden">
                      {playlist.tracks[0]?.artwork ? (
                        <img
                          src={playlist.tracks[0].artwork}
                          alt={playlist.name}
                          className="w-full h-full object-cover"
                        />
                      ) : (
                        <div className="w-full h-full flex items-center justify-center">
                          <Music className="w-6 h-6 text-muted-foreground" />
                        </div>
                      )}
                    </div>
                    <div className="flex-1 min-w-0">
                      <p className="font-semibold text-foreground truncate">{playlist.name}</p>
                      <p className="text-sm text-muted-foreground">
                        Playlist • {playlist.tracks.length} songs
                      </p>
                    </div>
                  </motion.div>
                ))}
              </div>
            )}
          </motion.section>
        )}

        {(filter === 'all' || filter === 'liked') && (
          <motion.section
            key="liked"
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -20 }}
          >
            {filter === 'liked' && (
              <div className="mb-4">
                <div className="flex items-center gap-4 p-4 bg-gradient-to-r from-primary/20 to-accent/20 rounded-xl">
                  <div className="w-16 h-16 rounded-xl bg-primary/20 flex items-center justify-center">
                    <Heart className="w-8 h-8 text-primary" fill="currentColor" />
                  </div>
                  <div className="flex-1">
                    <h3 className="font-bold text-foreground">Liked Songs</h3>
                    <p className="text-sm text-muted-foreground">{likedTracks.length} tracks</p>
                  </div>
                  {likedTracks.length > 0 && (
                    <button
                      onClick={handlePlayLiked}
                      className="p-3 rounded-full gradient-primary"
                    >
                      <ListMusic className="w-5 h-5 text-primary-foreground" />
                    </button>
                  )}
                </div>
              </div>
            )}
            <TrackList 
              tracks={filter === 'liked' ? likedTracks : queue} 
              title={filter === 'liked' ? 'Liked Songs' : 'All Songs'} 
            />
          </motion.section>
        )}

        {filter === 'recent' && (
          <motion.section
            key="recent"
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -20 }}
          >
            <TrackList 
              tracks={queue} 
              title="Recently Played" 
            />
          </motion.section>
        )}
      </AnimatePresence>

      {/* Create Playlist Modal */}
      <CreatePlaylistModal
        isOpen={showCreateModal}
        onClose={() => setShowCreateModal(false)}
      />
    </div>
  );
}
