/**
 * Custom hook for persisting playlist state between sessions
 */
import { useEffect, useCallback } from 'react';
import { Track } from '@/contexts/PlayerContext';

const STORAGE_KEY = 'melody_player_playlist';
const CURRENT_TRACK_KEY = 'melody_player_current_track';
const PLAYBACK_STATE_KEY = 'melody_player_playback_state';

interface PlaybackState {
  currentTrackId: string | null;
  currentTime: number;
  isShuffle: boolean;
  repeatMode: 'off' | 'all' | 'one';
  volume: number;
}

export function usePlaylistPersistence() {
  /**
   * Save playlist to localStorage
   */
  const savePlaylist = useCallback((tracks: Track[]) => {
    try {
      // Filter out blob URLs as they won't persist
      const persistableTracks = tracks.map(track => ({
        ...track,
        audioUrl: track.audioUrl?.startsWith('blob:') ? undefined : track.audioUrl,
      }));
      localStorage.setItem(STORAGE_KEY, JSON.stringify(persistableTracks));
    } catch (error) {
      console.error('Failed to save playlist:', error);
    }
  }, []);

  /**
   * Load playlist from localStorage
   */
  const loadPlaylist = useCallback((): Track[] => {
    try {
      const saved = localStorage.getItem(STORAGE_KEY);
      if (saved) {
        return JSON.parse(saved);
      }
    } catch (error) {
      console.error('Failed to load playlist:', error);
    }
    return [];
  }, []);

  /**
   * Save playback state
   */
  const savePlaybackState = useCallback((state: PlaybackState) => {
    try {
      localStorage.setItem(PLAYBACK_STATE_KEY, JSON.stringify(state));
    } catch (error) {
      console.error('Failed to save playback state:', error);
    }
  }, []);

  /**
   * Load playback state
   */
  const loadPlaybackState = useCallback((): PlaybackState | null => {
    try {
      const saved = localStorage.getItem(PLAYBACK_STATE_KEY);
      if (saved) {
        return JSON.parse(saved);
      }
    } catch (error) {
      console.error('Failed to load playback state:', error);
    }
    return null;
  }, []);

  /**
   * Clear all persisted data
   */
  const clearPersistedData = useCallback(() => {
    localStorage.removeItem(STORAGE_KEY);
    localStorage.removeItem(CURRENT_TRACK_KEY);
    localStorage.removeItem(PLAYBACK_STATE_KEY);
  }, []);

  return {
    savePlaylist,
    loadPlaylist,
    savePlaybackState,
    loadPlaybackState,
    clearPersistedData,
  };
}
