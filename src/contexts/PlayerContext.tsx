/**
 * Enhanced Player Context with real audio playback
 * Manages tracks, playback state, queue, and integrates with audio engine
 */
import React, { createContext, useContext, useState, useCallback, useRef, useEffect } from 'react';
import { usePlaylistPersistence } from '@/hooks/usePlaylistPersistence';
import { updateMediaSessionMetadata } from '@/hooks/useKeyboardShortcuts';

export interface Track {
  id: string;
  title: string;
  artist: string;
  album: string;
  duration: number;
  artwork: string;
  audioUrl?: string;
}

interface PlayerContextType {
  currentTrack: Track | null;
  isPlaying: boolean;
  currentTime: number;
  duration: number;
  volume: number;
  isShuffle: boolean;
  repeatMode: 'off' | 'all' | 'one';
  queue: Track[];
  isLoading: boolean;
  play: (track?: Track) => void;
  pause: () => void;
  stop: () => void;
  togglePlay: () => void;
  next: () => void;
  previous: () => void;
  seek: (time: number) => void;
  setVolume: (volume: number) => void;
  toggleShuffle: () => void;
  toggleRepeat: () => void;
  addToQueue: (track: Track) => void;
  removeFromQueue: (trackId: string) => void;
  setQueue: (tracks: Track[]) => void;
  clearQueue: () => void;
}

const PlayerContext = createContext<PlayerContextType | undefined>(undefined);

// Mock tracks for demo
const mockTracks: Track[] = [
  {
    id: '1',
    title: 'Midnight Dreams',
    artist: 'Luna Eclipse',
    album: 'Starlight Sessions',
    duration: 234,
    artwork: 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400&h=400&fit=crop',
    audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
  },
  {
    id: '2',
    title: 'Ocean Waves',
    artist: 'Coastal Beats',
    album: 'Serenity',
    duration: 198,
    artwork: 'https://images.unsplash.com/photo-1459749411175-04bf5292ceea?w=400&h=400&fit=crop',
    audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
  },
  {
    id: '3',
    title: 'Urban Jungle',
    artist: 'Metro Pulse',
    album: 'City Nights',
    duration: 267,
    artwork: 'https://images.unsplash.com/photo-1514320291840-2e0a9bf2a9ae?w=400&h=400&fit=crop',
    audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
  },
  {
    id: '4',
    title: 'Electric Soul',
    artist: 'Neon Hearts',
    album: 'Digital Love',
    duration: 312,
    artwork: 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=400&h=400&fit=crop',
    audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3',
  },
  {
    id: '5',
    title: 'Mountain High',
    artist: 'Peak Sound',
    album: 'Altitude',
    duration: 245,
    artwork: 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=400&h=400&fit=crop',
    audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3',
  },
  {
    id: '6',
    title: 'Sunset Boulevard',
    artist: 'Golden Hour',
    album: 'California Dreams',
    duration: 289,
    artwork: 'https://images.unsplash.com/photo-1508700115892-45ecd05ae2ad?w=400&h=400&fit=crop',
    audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-6.mp3',
  },
];

export function PlayerProvider({ children }: { children: React.ReactNode }) {
  const { savePlaylist, loadPlaylist, savePlaybackState, loadPlaybackState } = usePlaylistPersistence();
  
  // Initialize state from persistence
  const [queue, setQueueState] = useState<Track[]>(() => {
    const saved = loadPlaylist();
    return saved.length > 0 ? saved : mockTracks;
  });

  const [currentTrack, setCurrentTrack] = useState<Track | null>(() => {
    const state = loadPlaybackState();
    if (state?.currentTrackId) {
      const savedQueue = loadPlaylist();
      return savedQueue.find(t => t.id === state.currentTrackId) || mockTracks[0];
    }
    return mockTracks[0];
  });

  const [isPlaying, setIsPlaying] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [currentTime, setCurrentTime] = useState(() => {
    const state = loadPlaybackState();
    return state?.currentTime || 0;
  });
  const [duration, setDuration] = useState(0);
  const [volume, setVolumeState] = useState(() => {
    const state = loadPlaybackState();
    return state?.volume || 0.8;
  });
  const [isShuffle, setIsShuffle] = useState(() => {
    const state = loadPlaybackState();
    return state?.isShuffle || false;
  });
  const [repeatMode, setRepeatMode] = useState<'off' | 'all' | 'one'>(() => {
    const state = loadPlaybackState();
    return state?.repeatMode || 'off';
  });
  
  const audioRef = useRef<HTMLAudioElement | null>(null);

  // Initialize audio element
  useEffect(() => {
    audioRef.current = new Audio();
    audioRef.current.volume = volume;
    
    const audio = audioRef.current;

    const handleTimeUpdate = () => {
      setCurrentTime(audio.currentTime);
    };

    const handleLoadedMetadata = () => {
      setDuration(audio.duration);
      setIsLoading(false);
    };

    const handleEnded = () => {
      handleNext();
    };

    const handleWaiting = () => setIsLoading(true);
    const handleCanPlay = () => setIsLoading(false);
    const handleError = () => {
      setIsLoading(false);
      console.error('Audio playback error');
    };

    audio.addEventListener('timeupdate', handleTimeUpdate);
    audio.addEventListener('loadedmetadata', handleLoadedMetadata);
    audio.addEventListener('ended', handleEnded);
    audio.addEventListener('waiting', handleWaiting);
    audio.addEventListener('canplay', handleCanPlay);
    audio.addEventListener('error', handleError);

    return () => {
      audio.removeEventListener('timeupdate', handleTimeUpdate);
      audio.removeEventListener('loadedmetadata', handleLoadedMetadata);
      audio.removeEventListener('ended', handleEnded);
      audio.removeEventListener('waiting', handleWaiting);
      audio.removeEventListener('canplay', handleCanPlay);
      audio.removeEventListener('error', handleError);
      audio.pause();
      audio.src = '';
    };
  }, []);

  // Handle next track (needs to be defined before useEffect that uses it)
  const handleNext = useCallback(() => {
    if (!currentTrack || queue.length === 0) return;
    
    const currentIndex = queue.findIndex((t) => t.id === currentTrack.id);
    let nextIndex: number;
    
    if (repeatMode === 'one') {
      // Restart current track
      if (audioRef.current) {
        audioRef.current.currentTime = 0;
        audioRef.current.play();
      }
      return;
    }
    
    if (isShuffle) {
      nextIndex = Math.floor(Math.random() * queue.length);
    } else {
      nextIndex = (currentIndex + 1) % queue.length;
      
      // If not repeat all and at end, stop
      if (repeatMode === 'off' && currentIndex === queue.length - 1) {
        setIsPlaying(false);
        return;
      }
    }
    
    const nextTrack = queue[nextIndex];
    setCurrentTrack(nextTrack);
    setCurrentTime(0);
    
    if (audioRef.current && nextTrack.audioUrl) {
      audioRef.current.src = nextTrack.audioUrl;
      audioRef.current.play().catch(console.error);
      setIsPlaying(true);
    }
  }, [currentTrack, queue, isShuffle, repeatMode]);

  // Load track when currentTrack changes
  useEffect(() => {
    if (currentTrack?.audioUrl && audioRef.current) {
      const wasPlaying = isPlaying;
      audioRef.current.src = currentTrack.audioUrl;
      
      if (wasPlaying) {
        audioRef.current.play().catch(console.error);
      }
      
      // Update media session
      updateMediaSessionMetadata(currentTrack);
    }
  }, [currentTrack?.id]);

  // Save state periodically
  useEffect(() => {
    const interval = setInterval(() => {
      savePlaybackState({
        currentTrackId: currentTrack?.id || null,
        currentTime,
        isShuffle,
        repeatMode,
        volume,
      });
    }, 5000);

    return () => clearInterval(interval);
  }, [currentTrack, currentTime, isShuffle, repeatMode, volume, savePlaybackState]);

  // Save queue when it changes
  useEffect(() => {
    savePlaylist(queue);
  }, [queue, savePlaylist]);

  const play = useCallback((track?: Track) => {
    if (track) {
      setCurrentTrack(track);
      setCurrentTime(0);
      
      if (audioRef.current && track.audioUrl) {
        audioRef.current.src = track.audioUrl;
        audioRef.current.play().catch(console.error);
      }
    } else if (audioRef.current) {
      audioRef.current.play().catch(console.error);
    }
    setIsPlaying(true);
  }, []);

  const pause = useCallback(() => {
    if (audioRef.current) {
      audioRef.current.pause();
    }
    setIsPlaying(false);
  }, []);

  const stop = useCallback(() => {
    if (audioRef.current) {
      audioRef.current.pause();
      audioRef.current.currentTime = 0;
    }
    setIsPlaying(false);
    setCurrentTime(0);
  }, []);

  const togglePlay = useCallback(() => {
    if (isPlaying) {
      pause();
    } else {
      play();
    }
  }, [isPlaying, pause, play]);

  const next = useCallback(() => {
    handleNext();
  }, [handleNext]);

  const previous = useCallback(() => {
    if (!currentTrack || queue.length === 0) return;
    
    // If more than 3 seconds in, restart current track
    if (currentTime > 3) {
      if (audioRef.current) {
        audioRef.current.currentTime = 0;
      }
      setCurrentTime(0);
      return;
    }
    
    const currentIndex = queue.findIndex((t) => t.id === currentTrack.id);
    const prevIndex = currentIndex === 0 ? queue.length - 1 : currentIndex - 1;
    
    const prevTrack = queue[prevIndex];
    setCurrentTrack(prevTrack);
    setCurrentTime(0);
    
    if (audioRef.current && prevTrack.audioUrl) {
      audioRef.current.src = prevTrack.audioUrl;
      if (isPlaying) {
        audioRef.current.play().catch(console.error);
      }
    }
  }, [currentTrack, queue, currentTime, isPlaying]);

  const seek = useCallback((time: number) => {
    if (audioRef.current) {
      audioRef.current.currentTime = time;
    }
    setCurrentTime(time);
  }, []);

  const setVolume = useCallback((newVolume: number) => {
    const clampedVolume = Math.max(0, Math.min(1, newVolume));
    if (audioRef.current) {
      audioRef.current.volume = clampedVolume;
    }
    setVolumeState(clampedVolume);
  }, []);

  const toggleShuffle = useCallback(() => {
    setIsShuffle((prev) => !prev);
  }, []);

  const toggleRepeat = useCallback(() => {
    setRepeatMode((prev) => {
      if (prev === 'off') return 'all';
      if (prev === 'all') return 'one';
      return 'off';
    });
  }, []);

  const addToQueue = useCallback((track: Track) => {
    setQueueState((prev) => [...prev, track]);
  }, []);

  const removeFromQueue = useCallback((trackId: string) => {
    setQueueState((prev) => prev.filter(t => t.id !== trackId));
  }, []);

  const setQueue = useCallback((tracks: Track[]) => {
    setQueueState(tracks);
  }, []);

  const clearQueue = useCallback(() => {
    setQueueState([]);
    setCurrentTrack(null);
    stop();
  }, [stop]);

  return (
    <PlayerContext.Provider
      value={{
        currentTrack,
        isPlaying,
        currentTime,
        duration: currentTrack?.duration || duration,
        volume,
        isShuffle,
        repeatMode,
        queue,
        isLoading,
        play,
        pause,
        stop,
        togglePlay,
        next,
        previous,
        seek,
        setVolume,
        toggleShuffle,
        toggleRepeat,
        addToQueue,
        removeFromQueue,
        setQueue,
        clearQueue,
      }}
    >
      {children}
    </PlayerContext.Provider>
  );
}

export function usePlayer() {
  const context = useContext(PlayerContext);
  if (context === undefined) {
    throw new Error('usePlayer must be used within a PlayerProvider');
  }
  return context;
}
