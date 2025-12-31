import React, { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { X, Music, Plus } from 'lucide-react';
import { usePlaylist } from '@/contexts/PlaylistContext';
import { Input } from '@/components/ui/input';
import { Button } from '@/components/ui/button';

interface CreatePlaylistModalProps {
  isOpen: boolean;
  onClose: () => void;
}

export function CreatePlaylistModal({ isOpen, onClose }: CreatePlaylistModalProps) {
  const [name, setName] = useState('');
  const [description, setDescription] = useState('');
  const { createPlaylist } = usePlaylist();

  const handleCreate = () => {
    if (!name.trim()) return;
    createPlaylist(name.trim(), description.trim() || undefined);
    setName('');
    setDescription('');
    onClose();
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
            className="fixed inset-x-4 top-1/2 -translate-y-1/2 z-50 mx-auto max-w-md"
          >
            <div className="bg-card rounded-2xl shadow-xl overflow-hidden">
              {/* Header */}
              <div className="flex items-center justify-between p-4 border-b border-border">
                <div className="flex items-center gap-2">
                  <Plus className="w-5 h-5 text-primary" />
                  <h2 className="text-lg font-semibold text-foreground">Create Playlist</h2>
                </div>
                <button
                  onClick={onClose}
                  className="p-2 rounded-full hover:bg-secondary transition-colors"
                >
                  <X className="w-5 h-5 text-muted-foreground" />
                </button>
              </div>

              {/* Content */}
              <div className="p-4 space-y-4">
                <div className="flex justify-center">
                  <div className="w-24 h-24 rounded-xl bg-secondary flex items-center justify-center">
                    <Music className="w-12 h-12 text-muted-foreground" />
                  </div>
                </div>

                <div className="space-y-3">
                  <Input
                    placeholder="Playlist name"
                    value={name}
                    onChange={(e) => setName(e.target.value)}
                    className="bg-secondary border-0"
                    autoFocus
                  />
                  <Input
                    placeholder="Description (optional)"
                    value={description}
                    onChange={(e) => setDescription(e.target.value)}
                    className="bg-secondary border-0"
                  />
                </div>

                <Button
                  onClick={handleCreate}
                  disabled={!name.trim()}
                  className="w-full gradient-primary"
                >
                  Create Playlist
                </Button>
              </div>
            </div>
          </motion.div>
        </>
      )}
    </AnimatePresence>
  );
}
