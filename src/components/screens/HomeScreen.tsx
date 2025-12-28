import React from 'react';
import { motion } from 'framer-motion';
import { PlaylistCard } from '@/components/library/PlaylistCard';
import { TrackList } from '@/components/library/TrackList';
import { usePlayer } from '@/contexts/PlayerContext';

export function HomeScreen() {
  const { queue } = usePlayer();

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
    <div className="flex flex-col gap-8 pb-40">
      {/* Header */}
      <motion.div 
        initial={{ opacity: 0, y: -20 }}
        animate={{ opacity: 1, y: 0 }}
        className="pt-4"
      >
        <h1 className="text-3xl font-bold text-foreground">
          Good evening
        </h1>
        <p className="text-muted-foreground mt-1">
          What would you like to listen to?
        </p>
      </motion.div>

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

      {/* Recently Played */}
      <section>
        <TrackList tracks={queue} title="Recently Played" />
      </section>
    </div>
  );
}
