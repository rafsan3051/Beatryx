/**
 * Queue Manager Component
 * Displays and manages the playback queue with drag and drop reordering
 */
import React, { useState } from 'react';
import { motion, AnimatePresence, Reorder } from 'framer-motion';
import { 
  X, 
  GripVertical, 
  Play, 
  Trash2, 
  Music,
  FolderOpen 
} from 'lucide-react';
import { Track, usePlayer } from '@/contexts/PlayerContext';
import { useLocalFiles } from '@/hooks/useLocalFiles';
import { cn } from '@/lib/utils';

interface QueueManagerProps {
  isOpen: boolean;
  onClose: () => void;
}

export function QueueManager({ isOpen, onClose }: QueueManagerProps) {
  const { queue, currentTrack, play, setQueue, addToQueue } = usePlayer();
  const { openFilePicker, isLoading } = useLocalFiles();
  const [items, setItems] = useState(queue);

  // Sync with queue
  React.useEffect(() => {
    setItems(queue);
  }, [queue]);

  const handleReorder = (newOrder: Track[]) => {
    setItems(newOrder);
    setQueue(newOrder);
  };

  const handleRemove = (trackId: string) => {
    const newQueue = queue.filter(t => t.id !== trackId);
    setQueue(newQueue);
  };

  const handleAddFiles = async () => {
    const tracks = await openFilePicker();
    tracks.forEach(track => addToQueue(track));
  };

  const formatDuration = (seconds: number) => {
    const mins = Math.floor(seconds / 60);
    const secs = Math.floor(seconds % 60);
    return `${mins}:${secs.toString().padStart(2, '0')}`;
  };

  return (
    <AnimatePresence>
      {isOpen && (
        <motion.div
          initial={{ x: '100%' }}
          animate={{ x: 0 }}
          exit={{ x: '100%' }}
          transition={{ type: 'spring', damping: 30, stiffness: 300 }}
          className="fixed inset-0 z-50 bg-background"
        >
          <div className="flex flex-col h-full">
            {/* Header */}
            <div className="flex items-center justify-between p-4 border-b border-border">
              <div>
                <h2 className="text-lg font-bold text-foreground">Play Queue</h2>
                <p className="text-sm text-muted-foreground">{queue.length} tracks</p>
              </div>
              <button 
                onClick={onClose}
                className="p-2 rounded-full hover:bg-secondary transition-colors"
              >
                <X className="w-6 h-6 text-foreground" />
              </button>
            </div>

            {/* Add Files Button */}
            <div className="p-4 border-b border-border">
              <button
                onClick={handleAddFiles}
                disabled={isLoading}
                className="w-full flex items-center justify-center gap-2 py-3 rounded-xl bg-primary text-primary-foreground font-medium hover:bg-primary/90 transition-colors disabled:opacity-50"
              >
                <FolderOpen className="w-5 h-5" />
                {isLoading ? 'Loading...' : 'Add Local Files'}
              </button>
            </div>

            {/* Queue List */}
            <div className="flex-1 overflow-y-auto">
              {queue.length === 0 ? (
                <div className="flex flex-col items-center justify-center h-full text-muted-foreground">
                  <Music className="w-16 h-16 mb-4 opacity-30" />
                  <p className="font-medium">Queue is empty</p>
                  <p className="text-sm">Add some tracks to get started</p>
                </div>
              ) : (
                <Reorder.Group 
                  axis="y" 
                  values={items} 
                  onReorder={handleReorder}
                  className="p-2"
                >
                  {items.map((track, index) => (
                    <Reorder.Item
                      key={track.id}
                      value={track}
                      className={cn(
                        "flex items-center gap-3 p-3 rounded-xl mb-2 cursor-grab active:cursor-grabbing",
                        currentTrack?.id === track.id
                          ? "bg-primary/10 border border-primary/20"
                          : "bg-card hover:bg-secondary/50"
                      )}
                    >
                      <GripVertical className="w-5 h-5 text-muted-foreground flex-shrink-0" />
                      
                      <div 
                        className="flex items-center gap-3 flex-1 min-w-0"
                        onClick={() => play(track)}
                      >
                        <div className="relative w-12 h-12 rounded-lg overflow-hidden flex-shrink-0">
                          <img 
                            src={track.artwork} 
                            alt={track.album}
                            className="w-full h-full object-cover"
                          />
                          {currentTrack?.id === track.id && (
                            <div className="absolute inset-0 bg-black/40 flex items-center justify-center">
                              <div className="flex gap-0.5">
                                {[0, 1, 2].map(i => (
                                  <motion.div
                                    key={i}
                                    className="w-0.5 bg-white rounded-full"
                                    animate={{ height: [4, 12, 4] }}
                                    transition={{
                                      duration: 0.5,
                                      repeat: Infinity,
                                      delay: i * 0.1,
                                    }}
                                  />
                                ))}
                              </div>
                            </div>
                          )}
                        </div>

                        <div className="flex-1 min-w-0">
                          <p className={cn(
                            "font-medium truncate",
                            currentTrack?.id === track.id ? "text-primary" : "text-foreground"
                          )}>
                            {track.title}
                          </p>
                          <p className="text-sm text-muted-foreground truncate">
                            {track.artist}
                          </p>
                        </div>

                        <span className="text-sm text-muted-foreground">
                          {formatDuration(track.duration)}
                        </span>
                      </div>

                      <button
                        onClick={() => handleRemove(track.id)}
                        className="p-2 rounded-full hover:bg-destructive/10 text-muted-foreground hover:text-destructive transition-colors flex-shrink-0"
                      >
                        <Trash2 className="w-4 h-4" />
                      </button>
                    </Reorder.Item>
                  ))}
                </Reorder.Group>
              )}
            </div>
          </div>
        </motion.div>
      )}
    </AnimatePresence>
  );
}
