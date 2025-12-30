import React, { useCallback } from 'react';
import { motion } from 'framer-motion';
import { PlaylistCard } from '@/components/library/PlaylistCard';
import { TrackList } from '@/components/library/TrackList';
import { Header } from '@/components/Header';
import { usePlayer } from '@/contexts/PlayerContext';
import { useLocalFiles } from '@/hooks/useLocalFiles';
import { toast } from 'sonner';

export function HomeScreen() {
  const { queue, removeFromQueue, addToQueue } = usePlayer();

  const handleNewFilesDetected = useCallback((newTracks: any[]) => {
    newTracks.forEach(track => addToQueue(track));
    toast.success(`${newTracks.length} new track${newTracks.length > 1 ? 's' : ''} added!`);
  }, [addToQueue]);

  const { isRefreshing, refreshLibrary } = useLocalFiles({
    autoRefreshInterval: 30000,
    onNewFilesDetected: handleNewFilesDetected,
  });

  const handleRefresh = async () => {
    const newTracks = await refreshLibrary();
    if (newTracks.length === 0) {
      toast.info('No new music files found');
    }
  };

  const handleDeleteTrack = (trackId: string) => {
    removeFromQueue(trackId);
    toast.success('Track removed from library');
  };

  const recentPlaylists = [
    {
      id: '1',
      title: 'Chill Vibes',
      subtitle: 'Relaxing tunes',
      artwork: 'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?w=400&h=400&fit=crop',
      trackCount: 24,
    },
    {
      id: '2',
      title: 'Workout Mix',
      subtitle: 'Energy boost',
      artwork: 'https://images.unsplash.com/photo-1571902943202-507ec2618e8f?w=400&h=400&fit=crop',
      trackCount: 18,
    },
    {
      id: '3',
      title: 'Focus Mode',
      subtitle: 'Concentration',
      artwork: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=400&fit=crop',
      trackCount: 32,
    },
    {
      id: '4',
      title: 'Night Drive',
      subtitle: 'Late night',
      artwork: 'https://images.unsplash.com/photo-1494891848038-7bd202a2afeb?w=400&h=400&fit=crop',
      trackCount: 15,
    },
  ];

  return (
    <div className="flex flex-col gap-6 pb-40">
      {/* Header with Logo */}
      <Header onRefresh={handleRefresh} isRefreshing={isRefreshing} />

      {/* Quick Access */}
      <section>
        <h2 className="text-lg font-semibold text-foreground mb-4">Quick Access</h2>
        <div className="grid grid-cols-2 gap-3">
          {recentPlaylists.slice(0, 4).map((playlist, index) => (
            <motion.div
              key={playlist.id}
              initial={{ opacity: 0, scale: 0.9 }}
              animate={{ opacity: 1, scale: 1 }}
              transition={{ delay: index * 0.1 }}
              className="flex items-center gap-3 bg-secondary/50 rounded-lg overflow-hidden hover:bg-secondary transition-colors cursor-pointer"
            >
              <img 
                src={playlist.artwork} 
                alt={playlist.title}
                className="w-14 h-14 object-cover"
              />
              <span className="font-medium text-foreground text-sm truncate pr-3">
                {playlist.title}
              </span>
            </motion.div>
          ))}
        </div>
      </section>

      {/* Featured Playlists */}
      <section>
        <h2 className="text-lg font-semibold text-foreground mb-4">Made for You</h2>
        <div className="grid grid-cols-2 gap-4">
          {recentPlaylists.map((playlist) => (
            <PlaylistCard
              key={playlist.id}
              title={playlist.title}
              subtitle={playlist.subtitle}
              artwork={playlist.artwork}
              trackCount={playlist.trackCount}
            />
          ))}
        </div>
      </section>

      {/* Recently Played with delete option */}
      <section>
        <TrackList 
          tracks={queue} 
          title="Your Music" 
          onDeleteTrack={handleDeleteTrack}
          showDelete={true}
        />
      </section>
    </div>
  );
}
