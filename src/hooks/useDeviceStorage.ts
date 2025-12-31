/**
 * Custom hook for fetching audio files from device storage (Android/iOS)
 * Uses Capacitor Filesystem API to read music files
 */
import { useCallback, useState, useRef } from 'react';
import { Filesystem, Directory } from '@capacitor/filesystem';
import { Track } from '@/contexts/PlayerContext';
import { Capacitor } from '@capacitor/core';

// Common music directories on Android (relative paths for ExternalStorage)
const MUSIC_DIRECTORIES = [
  'Download',
  'Downloads', 
  'Music',
  'Audio',
  'media',
  'Audiobooks',
  'Podcasts',
  'Ringtones',
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
      console.log(`[Beatryx] Reading file: ${path}`);
      
      // Try to get the file URI first
      const fileUri = await Filesystem.getUri({
        path,
        directory: Directory.ExternalStorage,
      });
      
      console.log(`[Beatryx] File URI: ${fileUri.uri}`);
      
      // On Android, we can use the file URI directly
      if (Capacitor.getPlatform() === 'android' && fileUri.uri) {
        return fileUri.uri;
      }
      
      // Fallback: read as base64
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
      const blobUrl = URL.createObjectURL(blob);
      console.log(`[Beatryx] Created blob URL for: ${path}`);
      return blobUrl;
    } catch (err) {
      console.error(`[Beatryx] Error reading file ${path}:`, err);
      throw err;
    }
  };

  /**
   * Scan a directory recursively for audio files
   */
  const scanDirectory = useCallback(async (dirPath: string, maxDepth = 2, currentDepth = 0): Promise<Track[]> => {
    const tracks: Track[] = [];

    if (currentDepth >= maxDepth) return tracks;

    try {
      const displayPath = dirPath || 'root';
      onProgress?.(`Scanning: ${displayPath}`);
      console.log(`[Beatryx] Scanning directory: ${dirPath || 'root'}`);
      
      const result = await Filesystem.readdir({
        path: dirPath,
        directory: Directory.ExternalStorage,
      });

      console.log(`[Beatryx] Found ${result.files.length} items in ${displayPath}`);

      for (const file of result.files) {
        try {
          console.log(`[Beatryx] Processing: ${file.name} (type: ${file.type})`);
          
          // Check if it's a directory
          if (file.type === 'directory') {
            // Recursively scan subdirectories
            const subDirPath = dirPath ? `${dirPath}/${file.name}` : file.name;
            const subDirTracks = await scanDirectory(
              subDirPath,
              maxDepth,
              currentDepth + 1
            );
            tracks.push(...subDirTracks);
          } else if (file.type === 'file' && isSupportedAudio(file.name)) {
            // It's an audio file
            const filePath = dirPath ? `${dirPath}/${file.name}` : file.name;
            const hash = getFileHash(file.name);

            // Skip if already scanned
            if (scannedHashesRef.current.has(hash)) {
              console.log(`[Beatryx] Skipping duplicate: ${file.name}`);
              continue;
            }

            scannedHashesRef.current.add(hash);

            const { title, artist } = extractMetadata(file.name);
            
            console.log(`[Beatryx] Found audio file: ${filePath}`);

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
              console.log(`[Beatryx] Successfully added: ${title} by ${artist}`);
            } catch (err) {
              console.error(`[Beatryx] Failed to process audio file: ${file.name}`, err);
            }
          }
        } catch (err) {
          console.warn(`[Beatryx] Error processing file ${file.name}:`, err);
        }
      }
    } catch (err) {
      console.warn(`[Beatryx] Error scanning directory ${dirPath}:`, err);
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
      
      // First, try to scan the root external storage (where Downloads typically is)
      console.log('[Beatryx] Starting scan from external storage root');
      
      try {
        const rootTracks = await scanDirectory('', 3);
        allTracks = [...allTracks, ...rootTracks];
        console.log(`[Beatryx] Found ${rootTracks.length} tracks in root`);
      } catch (err) {
        console.warn('[Beatryx] Could not scan root directory:', err);
      }

      // Also try specific directories as fallback
      const dirsToTry = MUSIC_DIRECTORIES;
      for (const dir of dirsToTry) {
        try {
          onProgress?.(`Scanning ${dir}...`);
          console.log(`[Beatryx] Trying directory: ${dir}`);
          const dirTracks = await scanDirectory(dir);
          if (dirTracks.length > 0) {
            allTracks = [...allTracks, ...dirTracks];
            console.log(`[Beatryx] Found ${dirTracks.length} tracks in ${dir}`);
          }
        } catch (err) {
          console.warn(`[Beatryx] Could not scan ${dir}:`, err);
        }
      }

      console.log(`[Beatryx] Total tracks found: ${allTracks.length}`);
      
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
    scanForMusic: fetchDeviceMusic,
    isDeviceStorageAvailable,
  };
}
