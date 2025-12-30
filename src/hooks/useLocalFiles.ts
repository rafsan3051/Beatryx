/**
 * Custom hook for handling local audio files
 * Supports mp3, wav, ogg, flac, aac, m4a formats
 * Includes auto-refresh functionality for new files
 */
import { useCallback, useState, useEffect, useRef } from 'react';
import { Track } from '@/contexts/PlayerContext';

// Supported audio formats
const SUPPORTED_FORMATS = [
  'audio/mpeg',      // mp3
  'audio/mp3',       // mp3 alternative
  'audio/wav',       // wav
  'audio/wave',      // wav alternative
  'audio/ogg',       // ogg
  'audio/flac',      // flac
  'audio/aac',       // aac
  'audio/mp4',       // m4a
  'audio/x-m4a',     // m4a alternative
];

const SUPPORTED_EXTENSIONS = ['.mp3', '.wav', '.ogg', '.flac', '.aac', '.m4a'];

// Storage key for tracking known files
const KNOWN_FILES_KEY = 'beatryx-known-files';

/**
 * Extract metadata from audio file using Web Audio API
 */
async function extractMetadata(file: File): Promise<Partial<Track>> {
  return new Promise((resolve) => {
    const url = URL.createObjectURL(file);
    const audio = new Audio();
    
    audio.addEventListener('loadedmetadata', () => {
      // Clean up filename to extract title
      let title = file.name;
      SUPPORTED_EXTENSIONS.forEach(ext => {
        title = title.replace(new RegExp(ext + '$', 'i'), '');
      });
      
      // Try to parse artist - title format
      let artist = 'Unknown Artist';
      if (title.includes(' - ')) {
        const parts = title.split(' - ');
        artist = parts[0].trim();
        title = parts.slice(1).join(' - ').trim();
      }

      resolve({
        title,
        artist,
        duration: Math.floor(audio.duration),
        audioUrl: url,
      });
    });

    audio.addEventListener('error', () => {
      // Fallback if metadata can't be loaded
      let title = file.name;
      SUPPORTED_EXTENSIONS.forEach(ext => {
        title = title.replace(new RegExp(ext + '$', 'i'), '');
      });

      resolve({
        title,
        artist: 'Unknown Artist',
        duration: 0,
        audioUrl: url,
      });
    });

    audio.src = url;
  });
}

/**
 * Generate a random ID for tracks
 */
function generateId(): string {
  return `local-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
}

/**
 * Default artwork for local files
 */
const DEFAULT_ARTWORK = 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400&h=400&fit=crop';

interface UseLocalFilesOptions {
  autoRefreshInterval?: number; // in milliseconds
  onNewFilesDetected?: (newTracks: Track[]) => void;
}

export function useLocalFiles(options: UseLocalFilesOptions = {}) {
  const { 
    autoRefreshInterval = 30000, // Default 30 seconds
    onNewFilesDetected 
  } = options;

  const [isLoading, setIsLoading] = useState(false);
  const [isRefreshing, setIsRefreshing] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [knownFileHashes, setKnownFileHashes] = useState<Set<string>>(() => {
    const saved = localStorage.getItem(KNOWN_FILES_KEY);
    return saved ? new Set(JSON.parse(saved)) : new Set();
  });
  
  const directoryHandleRef = useRef<FileSystemDirectoryHandle | null>(null);
  const refreshIntervalRef = useRef<NodeJS.Timeout | null>(null);

  // Save known files to localStorage
  useEffect(() => {
    localStorage.setItem(KNOWN_FILES_KEY, JSON.stringify([...knownFileHashes]));
  }, [knownFileHashes]);

  /**
   * Generate a simple hash for file identification
   */
  const getFileHash = (file: File): string => {
    return `${file.name}-${file.size}-${file.lastModified}`;
  };

  /**
   * Process uploaded files and convert to Track objects
   */
  const processFiles = useCallback(async (files: FileList | File[]): Promise<Track[]> => {
    setIsLoading(true);
    setError(null);
    const tracks: Track[] = [];
    const newHashes = new Set(knownFileHashes);

    try {
      const fileArray = Array.from(files);
      
      for (const file of fileArray) {
        // Check if file type is supported
        const isSupported = SUPPORTED_FORMATS.includes(file.type) ||
          SUPPORTED_EXTENSIONS.some(ext => file.name.toLowerCase().endsWith(ext));

        if (!isSupported) {
          console.warn(`Unsupported file format: ${file.name} (${file.type})`);
          continue;
        }

        const hash = getFileHash(file);
        newHashes.add(hash);

        const metadata = await extractMetadata(file);
        
        const track: Track = {
          id: generateId(),
          title: metadata.title || file.name,
          artist: metadata.artist || 'Unknown Artist',
          album: 'Local Music',
          duration: metadata.duration || 0,
          artwork: DEFAULT_ARTWORK,
          audioUrl: metadata.audioUrl,
        };

        tracks.push(track);
      }

      setKnownFileHashes(newHashes);

      if (tracks.length === 0 && fileArray.length > 0) {
        setError('No supported audio files found. Please use MP3, WAV, OGG, FLAC, AAC, or M4A files.');
      }
    } catch (err) {
      console.error('Error processing files:', err);
      setError('Failed to process audio files');
    } finally {
      setIsLoading(false);
    }

    return tracks;
  }, [knownFileHashes]);

  /**
   * Scan directory for new files
   */
  const scanDirectory = useCallback(async (): Promise<Track[]> => {
    if (!directoryHandleRef.current) return [];

    setIsRefreshing(true);
    const newTracks: Track[] = [];
    const currentHashes = new Set<string>();

    try {
      const dirHandle = directoryHandleRef.current as any;
      for await (const entry of dirHandle.values()) {
        if (entry.kind === 'file') {
          const file = await entry.getFile();
          const isSupported = SUPPORTED_FORMATS.includes(file.type) ||
            SUPPORTED_EXTENSIONS.some(ext => file.name.toLowerCase().endsWith(ext));

          if (isSupported) {
            const hash = getFileHash(file);
            currentHashes.add(hash);

            // Check if this is a new file
            if (!knownFileHashes.has(hash)) {
              const metadata = await extractMetadata(file);
              const track: Track = {
                id: generateId(),
                title: metadata.title || file.name,
                artist: metadata.artist || 'Unknown Artist',
                album: 'Local Music',
                duration: metadata.duration || 0,
                artwork: DEFAULT_ARTWORK,
                audioUrl: metadata.audioUrl,
              };
              newTracks.push(track);
            }
          }
        }
      }

      // Update known hashes
      setKnownFileHashes(prev => {
        const updated = new Set([...prev, ...currentHashes]);
        return updated;
      });

      if (newTracks.length > 0 && onNewFilesDetected) {
        onNewFilesDetected(newTracks);
      }
    } catch (err) {
      console.error('Error scanning directory:', err);
    } finally {
      setIsRefreshing(false);
    }

    return newTracks;
  }, [knownFileHashes, onNewFilesDetected]);

  /**
   * Open directory picker for monitoring
   */
  const openDirectoryPicker = useCallback(async (): Promise<Track[]> => {
    try {
      // Check if File System Access API is supported
      if (!('showDirectoryPicker' in window)) {
        setError('Directory picker not supported. Please use the file picker instead.');
        return [];
      }

      const dirHandle = await (window as any).showDirectoryPicker({
        mode: 'read',
      });

      directoryHandleRef.current = dirHandle;

      // Process all files in directory
      const files: File[] = [];
      for await (const entry of dirHandle.values()) {
        if (entry.kind === 'file') {
          const file = await entry.getFile();
          files.push(file);
        }
      }

      return await processFiles(files);
    } catch (err: any) {
      if (err.name !== 'AbortError') {
        console.error('Error opening directory:', err);
        setError('Failed to open directory');
      }
      return [];
    }
  }, [processFiles]);

  /**
   * Open file picker dialog
   */
  const openFilePicker = useCallback((): Promise<Track[]> => {
    return new Promise((resolve) => {
      const input = document.createElement('input');
      input.type = 'file';
      input.multiple = true;
      input.accept = SUPPORTED_EXTENSIONS.join(',');
      
      input.onchange = async (e) => {
        const files = (e.target as HTMLInputElement).files;
        if (files && files.length > 0) {
          const tracks = await processFiles(files);
          resolve(tracks);
        } else {
          resolve([]);
        }
      };

      input.click();
    });
  }, [processFiles]);

  /**
   * Manual refresh to check for new files
   */
  const refreshLibrary = useCallback(async (): Promise<Track[]> => {
    return await scanDirectory();
  }, [scanDirectory]);

  /**
   * Start auto-refresh timer
   */
  const startAutoRefresh = useCallback(() => {
    if (refreshIntervalRef.current) {
      clearInterval(refreshIntervalRef.current);
    }

    refreshIntervalRef.current = setInterval(() => {
      scanDirectory();
    }, autoRefreshInterval);
  }, [scanDirectory, autoRefreshInterval]);

  /**
   * Stop auto-refresh timer
   */
  const stopAutoRefresh = useCallback(() => {
    if (refreshIntervalRef.current) {
      clearInterval(refreshIntervalRef.current);
      refreshIntervalRef.current = null;
    }
  }, []);

  /**
   * Delete a track from known files
   */
  const deleteTrack = useCallback((trackHash: string) => {
    setKnownFileHashes(prev => {
      const updated = new Set(prev);
      updated.delete(trackHash);
      return updated;
    });
  }, []);

  /**
   * Clear all known files
   */
  const clearKnownFiles = useCallback(() => {
    setKnownFileHashes(new Set());
    localStorage.removeItem(KNOWN_FILES_KEY);
  }, []);

  // Cleanup on unmount
  useEffect(() => {
    return () => {
      stopAutoRefresh();
    };
  }, [stopAutoRefresh]);

  return {
    isLoading,
    isRefreshing,
    error,
    processFiles,
    openFilePicker,
    openDirectoryPicker,
    refreshLibrary,
    startAutoRefresh,
    stopAutoRefresh,
    deleteTrack,
    clearKnownFiles,
    hasDirectoryAccess: !!directoryHandleRef.current,
    supportedFormats: SUPPORTED_EXTENSIONS,
  };
}
