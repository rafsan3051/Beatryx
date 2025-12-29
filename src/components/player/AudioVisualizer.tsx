/**
 * Audio Visualizer Component
 * Displays frequency spectrum or waveform visualization
 */
import React, { useEffect, useRef } from 'react';
import { motion } from 'framer-motion';
import { cn } from '@/lib/utils';

interface AudioVisualizerProps {
  frequencyData: Uint8Array;
  isPlaying: boolean;
  variant?: 'bars' | 'wave' | 'circle';
  className?: string;
  barCount?: number;
  color?: string;
}

export function AudioVisualizer({
  frequencyData,
  isPlaying,
  variant = 'bars',
  className,
  barCount = 32,
  color,
}: AudioVisualizerProps) {
  const canvasRef = useRef<HTMLCanvasElement>(null);

  // Sample frequency data to match bar count
  const sampledData = React.useMemo(() => {
    if (frequencyData.length === 0) return Array(barCount).fill(0);
    
    const step = Math.floor(frequencyData.length / barCount);
    const sampled: number[] = [];
    
    for (let i = 0; i < barCount; i++) {
      const index = Math.min(i * step, frequencyData.length - 1);
      sampled.push(frequencyData[index] || 0);
    }
    
    return sampled;
  }, [frequencyData, barCount]);

  // Canvas-based wave visualization
  useEffect(() => {
    if (variant !== 'wave' || !canvasRef.current) return;

    const canvas = canvasRef.current;
    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    const width = canvas.width;
    const height = canvas.height;

    ctx.clearRect(0, 0, width, height);

    // Create gradient
    const gradient = ctx.createLinearGradient(0, 0, width, 0);
    gradient.addColorStop(0, 'hsl(var(--primary))');
    gradient.addColorStop(1, 'hsl(var(--accent))');

    ctx.strokeStyle = gradient;
    ctx.lineWidth = 2;
    ctx.beginPath();

    const sliceWidth = width / frequencyData.length;
    let x = 0;

    for (let i = 0; i < frequencyData.length; i++) {
      const v = frequencyData[i] / 255;
      const y = (1 - v) * height / 2 + height / 4;

      if (i === 0) {
        ctx.moveTo(x, y);
      } else {
        ctx.lineTo(x, y);
      }

      x += sliceWidth;
    }

    ctx.lineTo(width, height / 2);
    ctx.stroke();
  }, [frequencyData, variant]);

  if (variant === 'bars') {
    return (
      <div className={cn("flex items-end justify-center gap-0.5 h-16", className)}>
        {sampledData.map((value, index) => {
          const height = isPlaying 
            ? Math.max(4, (value / 255) * 100)
            : 4 + Math.sin(index * 0.5) * 2;
          
          return (
            <motion.div
              key={index}
              className="w-1 rounded-full bg-gradient-to-t from-primary to-accent"
              animate={{ 
                height: `${height}%`,
                opacity: isPlaying ? 0.8 + (value / 255) * 0.2 : 0.3
              }}
              transition={{ 
                duration: 0.1,
                ease: 'linear'
              }}
            />
          );
        })}
      </div>
    );
  }

  if (variant === 'wave') {
    return (
      <canvas
        ref={canvasRef}
        width={300}
        height={60}
        className={cn("w-full", className)}
      />
    );
  }

  if (variant === 'circle') {
    return (
      <div className={cn("relative w-full h-full", className)}>
        <svg viewBox="0 0 100 100" className="w-full h-full">
          {sampledData.map((value, index) => {
            const angle = (index / barCount) * Math.PI * 2 - Math.PI / 2;
            const innerRadius = 30;
            const maxLength = 15;
            const length = isPlaying 
              ? (value / 255) * maxLength + 2
              : 2 + Math.sin(index * 0.3) * 1;

            const x1 = 50 + Math.cos(angle) * innerRadius;
            const y1 = 50 + Math.sin(angle) * innerRadius;
            const x2 = 50 + Math.cos(angle) * (innerRadius + length);
            const y2 = 50 + Math.sin(angle) * (innerRadius + length);

            return (
              <motion.line
                key={index}
                x1={x1}
                y1={y1}
                x2={x2}
                y2={y2}
                stroke="url(#visualizerGradient)"
                strokeWidth="1.5"
                strokeLinecap="round"
                initial={false}
                animate={{ 
                  x2, 
                  y2,
                  opacity: isPlaying ? 0.7 + (value / 255) * 0.3 : 0.3
                }}
                transition={{ duration: 0.05 }}
              />
            );
          })}
          <defs>
            <linearGradient id="visualizerGradient" x1="0%" y1="0%" x2="100%" y2="100%">
              <stop offset="0%" stopColor="hsl(var(--primary))" />
              <stop offset="100%" stopColor="hsl(var(--accent))" />
            </linearGradient>
          </defs>
        </svg>
      </div>
    );
  }

  return null;
}
