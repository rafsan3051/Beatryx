import React from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { X, Timer, Check } from 'lucide-react';
import { useSleepTimer } from '@/contexts/SleepTimerContext';
import { cn } from '@/lib/utils';

interface SleepTimerModalProps {
  isOpen: boolean;
  onClose: () => void;
}

const timerOptions = [
  { value: 5, label: '5 minutes' },
  { value: 10, label: '10 minutes' },
  { value: 15, label: '15 minutes' },
  { value: 30, label: '30 minutes' },
  { value: 45, label: '45 minutes' },
  { value: 60, label: '1 hour' },
  { value: 90, label: '1.5 hours' },
  { value: 120, label: '2 hours' },
];

function formatRemainingTime(seconds: number): string {
  const hours = Math.floor(seconds / 3600);
  const mins = Math.floor((seconds % 3600) / 60);
  const secs = seconds % 60;
  
  if (hours > 0) {
    return `${hours}:${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  }
  return `${mins}:${secs.toString().padStart(2, '0')}`;
}

export function SleepTimerModal({ isOpen, onClose }: SleepTimerModalProps) {
  const { sleepTimerMinutes, remainingTime, setSleepTimer, cancelSleepTimer } = useSleepTimer();

  const handleSelect = (minutes: number) => {
    setSleepTimer(minutes);
    onClose();
  };

  const handleCancel = () => {
    cancelSleepTimer();
    onClose();
  };

  return (
    <AnimatePresence>
      {isOpen && (
        <>
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="fixed inset-0 z-50 bg-black/60 backdrop-blur-sm"
            onClick={onClose}
          />
          <motion.div
            initial={{ opacity: 0, scale: 0.95, y: 20 }}
            animate={{ opacity: 1, scale: 1, y: 0 }}
            exit={{ opacity: 0, scale: 0.95, y: 20 }}
            className="fixed inset-x-4 bottom-20 z-50 mx-auto max-w-md"
          >
            <div className="bg-card rounded-2xl shadow-xl overflow-hidden">
              {/* Header */}
              <div className="flex items-center justify-between p-4 border-b border-border">
                <div className="flex items-center gap-2">
                  <Timer className="w-5 h-5 text-primary" />
                  <h2 className="text-lg font-semibold text-foreground">Sleep Timer</h2>
                </div>
                <button
                  onClick={onClose}
                  className="p-2 rounded-full hover:bg-secondary transition-colors"
                >
                  <X className="w-5 h-5 text-muted-foreground" />
                </button>
              </div>

              {/* Active Timer Display */}
              {sleepTimerMinutes !== null && (
                <div className="p-4 bg-primary/10 border-b border-border">
                  <div className="flex items-center justify-between">
                    <div>
                      <p className="text-sm text-muted-foreground">Timer active</p>
                      <p className="text-2xl font-bold text-primary">
                        {formatRemainingTime(remainingTime)}
                      </p>
                    </div>
                    <button
                      onClick={handleCancel}
                      className="px-4 py-2 bg-destructive/10 text-destructive rounded-lg text-sm font-medium hover:bg-destructive/20 transition-colors"
                    >
                      Cancel
                    </button>
                  </div>
                </div>
              )}

              {/* Timer Options */}
              <div className="p-2 max-h-80 overflow-y-auto">
                {timerOptions.map((option) => (
                  <button
                    key={option.value}
                    onClick={() => handleSelect(option.value)}
                    className={cn(
                      "w-full flex items-center justify-between p-4 rounded-xl transition-colors",
                      sleepTimerMinutes === option.value
                        ? "bg-primary/10 text-primary"
                        : "hover:bg-secondary"
                    )}
                  >
                    <span className="font-medium">{option.label}</span>
                    {sleepTimerMinutes === option.value && (
                      <Check className="w-5 h-5" />
                    )}
                  </button>
                ))}
              </div>
            </div>
          </motion.div>
        </>
      )}
    </AnimatePresence>
  );
}
