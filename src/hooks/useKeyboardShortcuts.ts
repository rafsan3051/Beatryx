/**
 * Custom hook for keyboard and media key shortcuts
 * Supports space for play/pause, arrow keys for seeking, and OS media keys
 */
import { useEffect, useCallback } from 'react';

interface KeyboardShortcutsOptions {
  onPlayPause: () => void;
  onNext: () => void;
  onPrevious: () => void;
  onSeekForward: (seconds: number) => void;
  onSeekBackward: (seconds: number) => void;
  onVolumeUp: () => void;
  onVolumeDown: () => void;
  enabled?: boolean;
}

export function useKeyboardShortcuts({
  onPlayPause,
  onNext,
  onPrevious,
  onSeekForward,
  onSeekBackward,
  onVolumeUp,
  onVolumeDown,
  enabled = true,
}: KeyboardShortcutsOptions) {
  
  const handleKeyDown = useCallback((event: KeyboardEvent) => {
    // Don't handle shortcuts if user is typing in an input
    if (
      event.target instanceof HTMLInputElement ||
      event.target instanceof HTMLTextAreaElement ||
      event.target instanceof HTMLSelectElement
    ) {
      return;
    }

    switch (event.code) {
      case 'Space':
        event.preventDefault();
        onPlayPause();
        break;
      case 'ArrowRight':
        if (event.shiftKey) {
          onNext();
        } else {
          onSeekForward(10); // 10 seconds
        }
        break;
      case 'ArrowLeft':
        if (event.shiftKey) {
          onPrevious();
        } else {
          onSeekBackward(10); // 10 seconds
        }
        break;
      case 'ArrowUp':
        event.preventDefault();
        onVolumeUp();
        break;
      case 'ArrowDown':
        event.preventDefault();
        onVolumeDown();
        break;
      case 'KeyN':
        if (event.shiftKey) {
          onNext();
        }
        break;
      case 'KeyP':
        if (event.shiftKey) {
          onPrevious();
        }
        break;
    }
  }, [onPlayPause, onNext, onPrevious, onSeekForward, onSeekBackward, onVolumeUp, onVolumeDown]);

  // Handle Media Session API for OS-level media keys
  useEffect(() => {
    if (!enabled) return;

    if ('mediaSession' in navigator) {
      navigator.mediaSession.setActionHandler('play', onPlayPause);
      navigator.mediaSession.setActionHandler('pause', onPlayPause);
      navigator.mediaSession.setActionHandler('previoustrack', onPrevious);
      navigator.mediaSession.setActionHandler('nexttrack', onNext);
      navigator.mediaSession.setActionHandler('seekbackward', () => onSeekBackward(10));
      navigator.mediaSession.setActionHandler('seekforward', () => onSeekForward(10));
    }

    return () => {
      if ('mediaSession' in navigator) {
        navigator.mediaSession.setActionHandler('play', null);
        navigator.mediaSession.setActionHandler('pause', null);
        navigator.mediaSession.setActionHandler('previoustrack', null);
        navigator.mediaSession.setActionHandler('nexttrack', null);
        navigator.mediaSession.setActionHandler('seekbackward', null);
        navigator.mediaSession.setActionHandler('seekforward', null);
      }
    };
  }, [enabled, onPlayPause, onNext, onPrevious, onSeekForward, onSeekBackward]);

  // Handle keyboard events
  useEffect(() => {
    if (!enabled) return;

    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [enabled, handleKeyDown]);
}

/**
 * Update Media Session metadata
 */
export function updateMediaSessionMetadata(track: {
  title: string;
  artist: string;
  album: string;
  artwork: string;
} | null) {
  if (!('mediaSession' in navigator) || !track) return;

  navigator.mediaSession.metadata = new MediaMetadata({
    title: track.title,
    artist: track.artist,
    album: track.album,
    artwork: [
      { src: track.artwork, sizes: '96x96', type: 'image/jpeg' },
      { src: track.artwork, sizes: '128x128', type: 'image/jpeg' },
      { src: track.artwork, sizes: '192x192', type: 'image/jpeg' },
      { src: track.artwork, sizes: '256x256', type: 'image/jpeg' },
      { src: track.artwork, sizes: '384x384', type: 'image/jpeg' },
      { src: track.artwork, sizes: '512x512', type: 'image/jpeg' },
    ],
  });
}
