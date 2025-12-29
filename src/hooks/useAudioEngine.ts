/**
 * Custom hook for audio playback using Web Audio API
 * Handles audio context, playback, volume, and visualization
 */
import { useRef, useCallback, useState, useEffect } from 'react';

export interface AudioEngineState {
  isPlaying: boolean;
  currentTime: number;
  duration: number;
  volume: number;
  isLoading: boolean;
  error: string | null;
}

export interface EqualizerSettings {
  bass: number; // -12 to 12 dB
  mid: number;
  treble: number;
  preset: 'flat' | 'rock' | 'jazz' | 'classical' | 'electronic' | 'custom';
}

const equalizerPresets: Record<string, Omit<EqualizerSettings, 'preset'>> = {
  flat: { bass: 0, mid: 0, treble: 0 },
  rock: { bass: 4, mid: -2, treble: 3 },
  jazz: { bass: 3, mid: 1, treble: 4 },
  classical: { bass: 0, mid: 0, treble: 3 },
  electronic: { bass: 5, mid: 0, treble: 2 },
};

export function useAudioEngine() {
  const audioRef = useRef<HTMLAudioElement | null>(null);
  const audioContextRef = useRef<AudioContext | null>(null);
  const analyserRef = useRef<AnalyserNode | null>(null);
  const gainNodeRef = useRef<GainNode | null>(null);
  const bassFilterRef = useRef<BiquadFilterNode | null>(null);
  const midFilterRef = useRef<BiquadFilterNode | null>(null);
  const trebleFilterRef = useRef<BiquadFilterNode | null>(null);
  const sourceNodeRef = useRef<MediaElementAudioSourceNode | null>(null);
  const isInitializedRef = useRef(false);

  const [state, setState] = useState<AudioEngineState>({
    isPlaying: false,
    currentTime: 0,
    duration: 0,
    volume: 0.8,
    isLoading: false,
    error: null,
  });

  const [equalizer, setEqualizerState] = useState<EqualizerSettings>(() => {
    const saved = localStorage.getItem('equalizer');
    return saved ? JSON.parse(saved) : { ...equalizerPresets.flat, preset: 'flat' };
  });

  const [frequencyData, setFrequencyData] = useState<Uint8Array>(new Uint8Array(64));

  // Initialize audio element
  useEffect(() => {
    if (!audioRef.current) {
      audioRef.current = new Audio();
      audioRef.current.crossOrigin = 'anonymous';
      
      audioRef.current.addEventListener('timeupdate', () => {
        setState(prev => ({ ...prev, currentTime: audioRef.current?.currentTime || 0 }));
      });

      audioRef.current.addEventListener('loadedmetadata', () => {
        setState(prev => ({ 
          ...prev, 
          duration: audioRef.current?.duration || 0,
          isLoading: false 
        }));
      });

      audioRef.current.addEventListener('ended', () => {
        setState(prev => ({ ...prev, isPlaying: false }));
      });

      audioRef.current.addEventListener('error', (e) => {
        setState(prev => ({ 
          ...prev, 
          error: 'Failed to load audio',
          isLoading: false 
        }));
      });

      audioRef.current.addEventListener('waiting', () => {
        setState(prev => ({ ...prev, isLoading: true }));
      });

      audioRef.current.addEventListener('canplay', () => {
        setState(prev => ({ ...prev, isLoading: false }));
      });
    }

    return () => {
      if (audioRef.current) {
        audioRef.current.pause();
        audioRef.current.src = '';
      }
      if (audioContextRef.current) {
        audioContextRef.current.close();
      }
    };
  }, []);

  // Initialize Web Audio API context and nodes
  const initializeAudioContext = useCallback(() => {
    if (isInitializedRef.current || !audioRef.current) return;

    try {
      audioContextRef.current = new (window.AudioContext || (window as any).webkitAudioContext)();
      
      // Create nodes
      analyserRef.current = audioContextRef.current.createAnalyser();
      analyserRef.current.fftSize = 128;
      
      gainNodeRef.current = audioContextRef.current.createGain();
      
      // Create equalizer filters
      bassFilterRef.current = audioContextRef.current.createBiquadFilter();
      bassFilterRef.current.type = 'lowshelf';
      bassFilterRef.current.frequency.value = 200;
      
      midFilterRef.current = audioContextRef.current.createBiquadFilter();
      midFilterRef.current.type = 'peaking';
      midFilterRef.current.frequency.value = 1000;
      midFilterRef.current.Q.value = 1;
      
      trebleFilterRef.current = audioContextRef.current.createBiquadFilter();
      trebleFilterRef.current.type = 'highshelf';
      trebleFilterRef.current.frequency.value = 4000;

      // Create source from audio element
      sourceNodeRef.current = audioContextRef.current.createMediaElementSource(audioRef.current);
      
      // Connect nodes: source -> bass -> mid -> treble -> gain -> analyser -> destination
      sourceNodeRef.current.connect(bassFilterRef.current);
      bassFilterRef.current.connect(midFilterRef.current);
      midFilterRef.current.connect(trebleFilterRef.current);
      trebleFilterRef.current.connect(gainNodeRef.current);
      gainNodeRef.current.connect(analyserRef.current);
      analyserRef.current.connect(audioContextRef.current.destination);

      isInitializedRef.current = true;
      
      // Apply initial equalizer settings
      applyEqualizerSettings(equalizer);
    } catch (error) {
      console.error('Failed to initialize audio context:', error);
    }
  }, [equalizer]);

  // Apply equalizer settings
  const applyEqualizerSettings = useCallback((settings: EqualizerSettings) => {
    if (bassFilterRef.current) {
      bassFilterRef.current.gain.value = settings.bass;
    }
    if (midFilterRef.current) {
      midFilterRef.current.gain.value = settings.mid;
    }
    if (trebleFilterRef.current) {
      trebleFilterRef.current.gain.value = settings.treble;
    }
  }, []);

  // Update equalizer
  const setEqualizer = useCallback((settings: Partial<EqualizerSettings>) => {
    setEqualizerState(prev => {
      const newSettings = { ...prev, ...settings };
      
      // If preset changed, apply preset values
      if (settings.preset && settings.preset !== 'custom') {
        const presetValues = equalizerPresets[settings.preset];
        Object.assign(newSettings, presetValues);
      } else if (settings.bass !== undefined || settings.mid !== undefined || settings.treble !== undefined) {
        newSettings.preset = 'custom';
      }
      
      applyEqualizerSettings(newSettings);
      localStorage.setItem('equalizer', JSON.stringify(newSettings));
      return newSettings;
    });
  }, [applyEqualizerSettings]);

  // Load audio source
  const loadSource = useCallback((url: string) => {
    if (!audioRef.current) return;
    
    setState(prev => ({ ...prev, isLoading: true, error: null, currentTime: 0 }));
    audioRef.current.src = url;
    audioRef.current.load();
    initializeAudioContext();
  }, [initializeAudioContext]);

  // Play
  const play = useCallback(async () => {
    if (!audioRef.current) return;
    
    try {
      // Resume audio context if suspended
      if (audioContextRef.current?.state === 'suspended') {
        await audioContextRef.current.resume();
      }
      
      await audioRef.current.play();
      setState(prev => ({ ...prev, isPlaying: true, error: null }));
    } catch (error) {
      console.error('Play error:', error);
      setState(prev => ({ ...prev, error: 'Failed to play audio' }));
    }
  }, []);

  // Pause
  const pause = useCallback(() => {
    if (!audioRef.current) return;
    audioRef.current.pause();
    setState(prev => ({ ...prev, isPlaying: false }));
  }, []);

  // Stop
  const stop = useCallback(() => {
    if (!audioRef.current) return;
    audioRef.current.pause();
    audioRef.current.currentTime = 0;
    setState(prev => ({ ...prev, isPlaying: false, currentTime: 0 }));
  }, []);

  // Seek
  const seek = useCallback((time: number) => {
    if (!audioRef.current) return;
    audioRef.current.currentTime = Math.max(0, Math.min(time, audioRef.current.duration || 0));
    setState(prev => ({ ...prev, currentTime: time }));
  }, []);

  // Set volume
  const setVolume = useCallback((volume: number) => {
    const clampedVolume = Math.max(0, Math.min(1, volume));
    if (audioRef.current) {
      audioRef.current.volume = clampedVolume;
    }
    if (gainNodeRef.current) {
      gainNodeRef.current.gain.value = clampedVolume;
    }
    setState(prev => ({ ...prev, volume: clampedVolume }));
    localStorage.setItem('volume', String(clampedVolume));
  }, []);

  // Get frequency data for visualization
  const getFrequencyData = useCallback(() => {
    if (!analyserRef.current) return new Uint8Array(64);
    const data = new Uint8Array(analyserRef.current.frequencyBinCount);
    analyserRef.current.getByteFrequencyData(data);
    return data;
  }, []);

  // Animation frame for visualization
  useEffect(() => {
    let animationId: number;

    const updateVisualization = () => {
      if (state.isPlaying && analyserRef.current) {
        const data = getFrequencyData();
        setFrequencyData(new Uint8Array(data));
      }
      animationId = requestAnimationFrame(updateVisualization);
    };

    if (state.isPlaying) {
      animationId = requestAnimationFrame(updateVisualization);
    }

    return () => {
      if (animationId) {
        cancelAnimationFrame(animationId);
      }
    };
  }, [state.isPlaying, getFrequencyData]);

  // Load saved volume on mount
  useEffect(() => {
    const savedVolume = localStorage.getItem('volume');
    if (savedVolume) {
      setVolume(parseFloat(savedVolume));
    }
  }, [setVolume]);

  return {
    ...state,
    equalizer,
    frequencyData,
    loadSource,
    play,
    pause,
    stop,
    seek,
    setVolume,
    setEqualizer,
    getFrequencyData,
  };
}

export { equalizerPresets };
