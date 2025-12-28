import React, { useState } from 'react';
import { motion } from 'framer-motion';
import { Search, X } from 'lucide-react';
import { Input } from '@/components/ui/input';
import { TrackList } from '@/components/library/TrackList';
import { usePlayer } from '@/contexts/PlayerContext';

const categories = [
  { id: '1', name: 'Pop', color: 'from-pink-500 to-rose-500' },
  { id: '2', name: 'Rock', color: 'from-red-500 to-orange-500' },
  { id: '3', name: 'Hip Hop', color: 'from-purple-500 to-indigo-500' },
  { id: '4', name: 'Electronic', color: 'from-cyan-500 to-blue-500' },
  { id: '5', name: 'Jazz', color: 'from-amber-500 to-yellow-500' },
  { id: '6', name: 'Classical', color: 'from-emerald-500 to-green-500' },
];

export function SearchScreen() {
  const [searchQuery, setSearchQuery] = useState('');
  const { queue } = usePlayer();

  const filteredTracks = queue.filter(
    (track) =>
      track.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
      track.artist.toLowerCase().includes(searchQuery.toLowerCase())
  );

  return (
    <div className="flex flex-col gap-6 pb-40">
      {/* Header */}
      <motion.div
        initial={{ opacity: 0, y: -20 }}
        animate={{ opacity: 1, y: 0 }}
        className="pt-4"
      >
        <h1 className="text-2xl font-bold text-foreground mb-4">Search</h1>
        
        {/* Search Input */}
        <div className="relative">
          <Search className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-muted-foreground" />
          <Input
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder="Songs, artists, albums..."
            className="pl-12 pr-10 h-12 rounded-xl bg-secondary border-0 text-foreground placeholder:text-muted-foreground"
          />
          {searchQuery && (
            <button
              onClick={() => setSearchQuery('')}
              className="absolute right-4 top-1/2 -translate-y-1/2 p-1 rounded-full hover:bg-muted transition-colors"
            >
              <X className="w-4 h-4 text-muted-foreground" />
            </button>
          )}
        </div>
      </motion.div>

      {/* Content */}
      {searchQuery ? (
        <section>
          <h2 className="text-lg font-semibold text-foreground mb-4">
            Results for "{searchQuery}"
          </h2>
          {filteredTracks.length > 0 ? (
            <TrackList tracks={filteredTracks} />
          ) : (
            <p className="text-muted-foreground text-center py-8">
              No results found
            </p>
          )}
        </section>
      ) : (
        <section>
          <h2 className="text-lg font-semibold text-foreground mb-4">
            Browse Categories
          </h2>
          <div className="grid grid-cols-2 gap-3">
            {categories.map((category, index) => (
              <motion.div
                key={category.id}
                initial={{ opacity: 0, scale: 0.9 }}
                animate={{ opacity: 1, scale: 1 }}
                transition={{ delay: index * 0.05 }}
                className={`bg-gradient-to-br ${category.color} rounded-xl p-4 h-24 flex items-end cursor-pointer hover:opacity-90 transition-opacity`}
              >
                <span className="text-lg font-bold text-white">{category.name}</span>
              </motion.div>
            ))}
          </div>
        </section>
      )}
    </div>
  );
}
