import React, { useState } from 'react';
import { motion } from 'framer-motion';
import { ListMusic, Heart, Clock, Plus, Grid, List } from 'lucide-react';
import { TrackList } from '@/components/library/TrackList';
import { PlaylistCard } from '@/components/library/PlaylistCard';
import { usePlayer } from '@/contexts/PlayerContext';
import { cn } from '@/lib/utils';

type ViewMode = 'grid' | 'list';
type Filter = 'all' | 'playlists' | 'liked' | 'recent';

const playlists = [
  {
    id: '1',
    title: 'My Favorites',
    subtitle: 'Your top picks',
    artwork: 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400&h=400&fit=crop',
    trackCount: 45,
  },
  {
    id: '2',
    title: 'Discover Weekly',
    subtitle: 'Fresh finds',
    artwork: 'https://images.unsplash.com/photo-1459749411175-04bf5292ceea?w=400&h=400&fit=crop',
    trackCount: 30,
  },
  {
    id: '3',
    title: 'Road Trip',
    subtitle: 'Long drives',
    artwork: 'https://images.unsplash.com/photo-1494891848038-7bd202a2afeb?w=400&h=400&fit=crop',
    trackCount: 22,
  },
];

export function LibraryScreen() {
  const [viewMode, setViewMode] = useState<ViewMode>('grid');
  const [filter, setFilter] = useState<Filter>('all');
  const { queue } = usePlayer();

  const filters: { id: Filter; label: string; icon: React.ElementType }[] = [
    { id: 'all', label: 'All', icon: ListMusic },
    { id: 'playlists', label: 'Playlists', icon: ListMusic },
    { id: 'liked', label: 'Liked', icon: Heart },
    { id: 'recent', label: 'Recent', icon: Clock },
  ];

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
          <button className="p-2 rounded-full hover:bg-secondary transition-colors">
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
      {filter === 'all' || filter === 'playlists' ? (
        <section>
          <h2 className="text-lg font-semibold text-foreground mb-4">Playlists</h2>
          {viewMode === 'grid' ? (
            <div className="grid grid-cols-2 gap-4">
              {playlists.map((playlist) => (
                <PlaylistCard
                  key={playlist.id}
                  title={playlist.title}
                  subtitle={playlist.subtitle}
                  artwork={playlist.artwork}
                  trackCount={playlist.trackCount}
                />
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
                  className="flex items-center gap-3 p-2 rounded-lg hover:bg-secondary/50 cursor-pointer transition-colors"
                >
                  <img
                    src={playlist.artwork}
                    alt={playlist.title}
                    className="w-14 h-14 rounded-lg object-cover"
                  />
                  <div className="flex-1 min-w-0">
                    <p className="font-semibold text-foreground truncate">{playlist.title}</p>
                    <p className="text-sm text-muted-foreground">
                      Playlist • {playlist.trackCount} songs
                    </p>
                  </div>
                </motion.div>
              ))}
            </div>
          )}
        </section>
      ) : null}

      {filter === 'all' || filter === 'liked' || filter === 'recent' ? (
        <section>
          <TrackList 
            tracks={queue} 
            title={filter === 'liked' ? 'Liked Songs' : filter === 'recent' ? 'Recently Played' : 'All Songs'} 
          />
        </section>
      ) : null}
    </div>
  );
}
