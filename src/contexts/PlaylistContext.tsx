import React, { createContext, useContext, useState, useCallback, useEffect } from 'react';
import { Track } from './PlayerContext';

export interface Playlist {
  id: string;
  name: string;
  description?: string;
  artwork?: string;
  tracks: Track[];
  createdAt: number;
  updatedAt: number;
}

interface PlaylistContextType {
  playlists: Playlist[];
  createPlaylist: (name: string, description?: string) => Playlist;
  deletePlaylist: (playlistId: string) => void;
  updatePlaylist: (playlistId: string, updates: Partial<Omit<Playlist, 'id' | 'createdAt'>>) => void;
  addTrackToPlaylist: (playlistId: string, track: Track) => void;
  removeTrackFromPlaylist: (playlistId: string, trackId: string) => void;
  getPlaylist: (playlistId: string) => Playlist | undefined;
  likedTracks: Track[];
  toggleLikeTrack: (track: Track) => void;
  isTrackLiked: (trackId: string) => boolean;
}

const PlaylistContext = createContext<PlaylistContextType | undefined>(undefined);

const PLAYLISTS_STORAGE_KEY = 'beatryx_playlists';
const LIKED_TRACKS_KEY = 'beatryx_liked_tracks';

export function PlaylistProvider({ children }: { children: React.ReactNode }) {
  const [playlists, setPlaylists] = useState<Playlist[]>(() => {
    try {
      const saved = localStorage.getItem(PLAYLISTS_STORAGE_KEY);
      return saved ? JSON.parse(saved) : [];
    } catch {
      return [];
    }
  });

  const [likedTracks, setLikedTracks] = useState<Track[]>(() => {
    try {
      const saved = localStorage.getItem(LIKED_TRACKS_KEY);
      return saved ? JSON.parse(saved) : [];
    } catch {
      return [];
    }
  });

  // Persist playlists
  useEffect(() => {
    localStorage.setItem(PLAYLISTS_STORAGE_KEY, JSON.stringify(playlists));
  }, [playlists]);

  // Persist liked tracks
  useEffect(() => {
    localStorage.setItem(LIKED_TRACKS_KEY, JSON.stringify(likedTracks));
  }, [likedTracks]);

  const createPlaylist = useCallback((name: string, description?: string): Playlist => {
    const newPlaylist: Playlist = {
      id: `playlist_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
      name,
      description,
      tracks: [],
      createdAt: Date.now(),
      updatedAt: Date.now(),
    };
    setPlaylists(prev => [...prev, newPlaylist]);
    return newPlaylist;
  }, []);

  const deletePlaylist = useCallback((playlistId: string) => {
    setPlaylists(prev => prev.filter(p => p.id !== playlistId));
  }, []);

  const updatePlaylist = useCallback((playlistId: string, updates: Partial<Omit<Playlist, 'id' | 'createdAt'>>) => {
    setPlaylists(prev => prev.map(p => 
      p.id === playlistId 
        ? { ...p, ...updates, updatedAt: Date.now() }
        : p
    ));
  }, []);

  const addTrackToPlaylist = useCallback((playlistId: string, track: Track) => {
    setPlaylists(prev => prev.map(p => {
      if (p.id !== playlistId) return p;
      if (p.tracks.some(t => t.id === track.id)) return p; // Already exists
      return {
        ...p,
        tracks: [...p.tracks, track],
        updatedAt: Date.now(),
      };
    }));
  }, []);

  const removeTrackFromPlaylist = useCallback((playlistId: string, trackId: string) => {
    setPlaylists(prev => prev.map(p => 
      p.id === playlistId
        ? { ...p, tracks: p.tracks.filter(t => t.id !== trackId), updatedAt: Date.now() }
        : p
    ));
  }, []);

  const getPlaylist = useCallback((playlistId: string) => {
    return playlists.find(p => p.id === playlistId);
  }, [playlists]);

  const toggleLikeTrack = useCallback((track: Track) => {
    setLikedTracks(prev => {
      const exists = prev.some(t => t.id === track.id);
      if (exists) {
        return prev.filter(t => t.id !== track.id);
      }
      return [...prev, track];
    });
  }, []);

  const isTrackLiked = useCallback((trackId: string) => {
    return likedTracks.some(t => t.id === trackId);
  }, [likedTracks]);

  return (
    <PlaylistContext.Provider
      value={{
        playlists,
        createPlaylist,
        deletePlaylist,
        updatePlaylist,
        addTrackToPlaylist,
        removeTrackFromPlaylist,
        getPlaylist,
        likedTracks,
        toggleLikeTrack,
        isTrackLiked,
      }}
    >
      {children}
    </PlaylistContext.Provider>
  );
}

export function usePlaylist() {
  const context = useContext(PlaylistContext);
  if (!context) {
    throw new Error('usePlaylist must be used within a PlaylistProvider');
  }
  return context;
}
