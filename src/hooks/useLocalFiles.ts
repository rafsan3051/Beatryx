/**
 * Custom hook for handling local audio files
 * Supports mp3, wav, ogg, flac, aac, m4a formats
 */
import { useCallback, useState } from 'react';
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

export function useLocalFiles() {
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  /**
   * Process uploaded files and convert to Track objects
   */
  const processFiles = useCallback(async (files: FileList | File[]): Promise<Track[]> => {
    setIsLoading(true);
    setError(null);
    const tracks: Track[] = [];

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
  }, []);

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

  return {
    isLoading,
    error,
    processFiles,
    openFilePicker,
    supportedFormats: SUPPORTED_EXTENSIONS,
  };
}
