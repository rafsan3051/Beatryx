/**
 * Custom hook for fetching audio files from device storage (Android/iOS)
 * Uses Capacitor Filesystem API to read music files
 */
import { useCallback, useState, useRef } from 'react';
import { Filesystem, Directory } from '@capacitor/filesystem';
import { Track } from '@/contexts/PlayerContext';
import { Capacitor } from '@capacitor/core';

// Common music directories on Android
const MUSIC_DIRECTORIES = [
  '/Music',
  '/Music/Downloads',
  '/Downloads',
  '/Documents',
  '/DCIM',
  '/Podcasts',
];

// Alternative paths for some devices
const ALTERNATIVE_MUSIC_PATHS = [
  '/storage/emulated/0/Music',
  '/storage/emulated/0/Downloads',
  '/sdcard/Music',
  '/sdcard/Downloads',
];

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

const DEFAULT_ARTWORK = 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400&h=400&fit=crop';

interface UseDeviceStorageOptions {
  onProgress?: (message: string) => void;
}

export function useDeviceStorage(options: UseDeviceStorageOptions = {}) {
  const { onProgress } = options;
  
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const scannedHashesRef = useRef<Set<string>>(new Set());

  /**
   * Check if the file is a supported audio format
   */
  const isSupportedAudio = (filename: string): boolean => {
    const lowerName = filename.toLowerCase();
    return SUPPORTED_EXTENSIONS.some(ext => lowerName.endsWith(ext));
  };

  /**
   * Generate a hash for file identification
   */
  const getFileHash = (filename: string, modTime?: number): string => {
    return `${filename}-${modTime || 0}`;
  };

  /**
   * Extract metadata from filename
   */
  const extractMetadata = (filename: string): { title: string; artist: string } => {
    let title = filename;
    
    // Remove extension
    SUPPORTED_EXTENSIONS.forEach(ext => {
      title = title.replace(new RegExp(ext + '$', 'i'), '');
    });

    // Try to parse "Artist - Title" format
    let artist = 'Unknown Artist';
    if (title.includes(' - ')) {
      const parts = title.split(' - ');
      artist = parts[0].trim();
      title = parts.slice(1).join(' - ').trim();
    }

    return { title, artist };
  };

  /**
   * Generate unique ID for tracks
   */
  const generateId = (): string => {
    return `device-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
  };

  /**
   * Read a file and convert to blob URL
   */
  const readFileAsBlob = async (path: string): Promise<string> => {
    try {
      const result = await Filesystem.readFile({
        path,
        directory: Directory.ExternalStorage,
      });

      // Convert base64 to blob URL
      const base64String = result.data as string;
      const byteCharacters = atob(base64String);
      const byteNumbers = new Array(byteCharacters.length);
      for (let i = 0; i < byteCharacters.length; i++) {
        byteNumbers[i] = byteCharacters.charCodeAt(i);
      }
      const byteArray = new Uint8Array(byteNumbers);
      const blob = new Blob([byteArray], { type: 'audio/mpeg' });
      return URL.createObjectURL(blob);
    } catch (err) {
      console.error(`Error reading file ${path}:`, err);
      throw err;
    }
  };

  /**
   * Scan a directory recursively for audio files
   */
  const scanDirectory = useCallback(async (dirPath: string, maxDepth = 3, currentDepth = 0): Promise<Track[]> => {
    const tracks: Track[] = [];

    if (currentDepth >= maxDepth) return tracks;

    try {
      onProgress?.(`Scanning: ${dirPath}`);
      
      const result = await Filesystem.readdir({
        path: dirPath,
        directory: Directory.ExternalStorage,
      });

      for (const file of result.files) {
        try {
          // Check if it's a directory
          if (file.type === 'directory') {
            // Recursively scan subdirectories
            const subDirTracks = await scanDirectory(
              `${dirPath}/${file.name}`,
              maxDepth,
              currentDepth + 1
            );
            tracks.push(...subDirTracks);
          } else if (file.type === 'file' && isSupportedAudio(file.name)) {
            // It's an audio file
            const filePath = `${dirPath}/${file.name}`;
            const hash = getFileHash(file.name);

            // Skip if already scanned
            if (scannedHashesRef.current.has(hash)) {
              continue;
            }

            scannedHashesRef.current.add(hash);

            const { title, artist } = extractMetadata(file.name);

            try {
              const audioUrl = await readFileAsBlob(filePath);
              
              const track: Track = {
                id: generateId(),
                title,
                artist,
                album: 'Device Music',
                duration: 0, // Will be set when audio loads
                artwork: DEFAULT_ARTWORK,
                audioUrl,
              };

              tracks.push(track);
            } catch (err) {
              console.warn(`Failed to process audio file: ${file.name}`, err);
            }
          }
        } catch (err) {
          console.warn(`Error processing file ${file.name}:`, err);
        }
      }
    } catch (err) {
      console.warn(`Error scanning directory ${dirPath}:`, err);
    }

    return tracks;
  }, [onProgress]);

  /**
   * Fetch all audio files from device storage
   */
  const fetchDeviceMusic = useCallback(async (): Promise<Track[]> => {
    setIsLoading(true);
    setError(null);
    scannedHashesRef.current.clear();

    // Check if running on native platform
    if (!Capacitor.isNativePlatform()) {
      setError('Device storage access only works on mobile devices');
      setIsLoading(false);
      return [];
    }

    try {
      onProgress?.('Initializing file system access...');
      
      let allTracks: Track[] = [];
      const dirsToTry = [...MUSIC_DIRECTORIES];

      // On Android, add alternative paths
      if (Capacitor.getPlatform() === 'android') {
        dirsToTry.push(...ALTERNATIVE_MUSIC_PATHS);
      }

      // Try to scan common music directories
      for (const dir of dirsToTry) {
        try {
          onProgress?.(`Scanning ${dir}...`);
          // Use scanDirectory from closure, which is safe
          const dirTracks = await new Promise<Track[]>((resolve) => {
            (async () => {
              const result = await scanDirectory(dir);
              resolve(result);
            })();
          });
          allTracks = [...allTracks, ...dirTracks];
        } catch (err) {
          console.warn(`Could not scan ${dir}:`, err);
        }
      }

      if (allTracks.length === 0) {
        setError('No audio files found on device. Check your Music/Downloads folders and permissions.');
      }

      return allTracks;
    } catch (err: unknown) {
      const errorMsg = err instanceof Error ? err.message : 'Failed to access device storage';
      console.error('Error fetching device music:', err);
      setError(errorMsg);
      
      // Check if it's a permission error
      if (errorMsg?.includes('Permission denied') || errorMsg?.includes('PERMISSION')) {
        setError('Storage permission denied. Please enable it in Settings → Apps → Beatryx → Permissions');
      }

      return [];
    } finally {
      setIsLoading(false);
      onProgress?.('');
    }
  }, [onProgress, scanDirectory]);

  /**
   * Check if device storage is available
   */
  const isDeviceStorageAvailable = useCallback((): boolean => {
    return Capacitor.isNativePlatform();
  }, []);

  return {
    isLoading,
    error,
    fetchDeviceMusic,
    isDeviceStorageAvailable,
  };
}
