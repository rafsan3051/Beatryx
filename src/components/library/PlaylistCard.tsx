import React from 'react';
import { motion } from 'framer-motion';
import { Play } from 'lucide-react';

interface PlaylistCardProps {
  title: string;
  subtitle: string;
  artwork: string;
  trackCount?: number;
  onClick?: () => void;
}

export function PlaylistCard({ title, subtitle, artwork, trackCount, onClick }: PlaylistCardProps) {
  return (
    <motion.div
      whileHover={{ y: -4 }}
      whileTap={{ scale: 0.98 }}
      onClick={onClick}
      className="group cursor-pointer"
    >
      <div className="relative rounded-xl overflow-hidden mb-3 shadow-soft">
        <img 
          src={artwork} 
          alt={title}
          className="w-full aspect-square object-cover transition-transform duration-300 group-hover:scale-105"
        />
        <div className="absolute inset-0 bg-gradient-to-t from-background/80 to-transparent opacity-0 group-hover:opacity-100 transition-opacity" />
        <motion.button
          initial={{ opacity: 0, scale: 0.8 }}
          whileHover={{ scale: 1.1 }}
          className="absolute bottom-3 right-3 w-12 h-12 rounded-full gradient-primary flex items-center justify-center shadow-glow opacity-0 group-hover:opacity-100 transition-opacity"
        >
          <Play className="w-5 h-5 text-primary-foreground ml-0.5" fill="currentColor" />
        </motion.button>
      </div>
      <h3 className="font-semibold text-foreground truncate">{title}</h3>
      <p className="text-sm text-muted-foreground">
        {subtitle} {trackCount && `• ${trackCount} tracks`}
      </p>
    </motion.div>
  );
}
