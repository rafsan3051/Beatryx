/**
 * Equalizer Component
 * Provides bass, mid, treble controls and presets
 */
import React from 'react';
import { motion } from 'framer-motion';
import { Sliders, Music2 } from 'lucide-react';
import { Slider } from '@/components/ui/slider';
import { cn } from '@/lib/utils';
import type { EqualizerSettings } from '@/hooks/useAudioEngine';

interface EqualizerProps {
  settings: EqualizerSettings;
  onSettingsChange: (settings: Partial<EqualizerSettings>) => void;
  className?: string;
}

const presets = [
  { id: 'flat', name: 'Flat', icon: '—' },
  { id: 'rock', name: 'Rock', icon: '🎸' },
  { id: 'jazz', name: 'Jazz', icon: '🎷' },
  { id: 'classical', name: 'Classical', icon: '🎻' },
  { id: 'electronic', name: 'Electronic', icon: '🎹' },
] as const;

export function Equalizer({ settings, onSettingsChange, className }: EqualizerProps) {
  const bands = [
    { id: 'bass', label: 'Bass', value: settings.bass, frequency: '60Hz' },
    { id: 'mid', label: 'Mid', value: settings.mid, frequency: '1kHz' },
    { id: 'treble', label: 'Treble', value: settings.treble, frequency: '4kHz' },
  ] as const;

  return (
    <div className={cn("space-y-6", className)}>
      {/* Header */}
      <div className="flex items-center gap-2">
        <Sliders className="w-5 h-5 text-primary" />
        <h3 className="font-semibold text-foreground">Equalizer</h3>
      </div>

      {/* Presets */}
      <div className="space-y-2">
        <p className="text-sm text-muted-foreground">Presets</p>
        <div className="flex gap-2 flex-wrap">
          {presets.map((preset) => (
            <button
              key={preset.id}
              onClick={() => onSettingsChange({ preset: preset.id as EqualizerSettings['preset'] })}
              className={cn(
                "px-3 py-1.5 rounded-full text-sm font-medium transition-all",
                settings.preset === preset.id
                  ? "bg-primary text-primary-foreground"
                  : "bg-secondary text-secondary-foreground hover:bg-secondary/80"
              )}
            >
              <span className="mr-1">{preset.icon}</span>
              {preset.name}
            </button>
          ))}
        </div>
      </div>

      {/* Sliders */}
      <div className="space-y-4">
        <p className="text-sm text-muted-foreground">Custom</p>
        <div className="grid grid-cols-3 gap-6">
          {bands.map((band) => (
            <div key={band.id} className="flex flex-col items-center gap-3">
              <div className="h-32 flex items-center">
                <Slider
                  orientation="vertical"
                  value={[band.value]}
                  min={-12}
                  max={12}
                  step={1}
                  onValueChange={([value]) => 
                    onSettingsChange({ [band.id]: value })
                  }
                  className="h-full"
                />
              </div>
              <div className="text-center">
                <p className="text-sm font-medium text-foreground">{band.label}</p>
                <p className="text-xs text-muted-foreground">{band.frequency}</p>
                <p className={cn(
                  "text-xs font-mono mt-1",
                  band.value > 0 ? "text-green-500" : band.value < 0 ? "text-red-500" : "text-muted-foreground"
                )}>
                  {band.value > 0 ? '+' : ''}{band.value}dB
                </p>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Reset Button */}
      <button
        onClick={() => onSettingsChange({ preset: 'flat' })}
        className="w-full py-2 rounded-lg bg-secondary text-secondary-foreground hover:bg-secondary/80 transition-colors text-sm font-medium"
      >
        Reset to Flat
      </button>
    </div>
  );
}
