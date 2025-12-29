import React, { createContext, useContext, useState, useCallback, useEffect, useRef } from 'react';
import { usePlayer } from './PlayerContext';
import { toast } from 'sonner';

interface SleepTimerContextType {
  sleepTimerMinutes: number | null;
  remainingTime: number;
  setSleepTimer: (minutes: number | null) => void;
  cancelSleepTimer: () => void;
}

const SleepTimerContext = createContext<SleepTimerContextType | undefined>(undefined);

export function SleepTimerProvider({ children }: { children: React.ReactNode }) {
  const { pause } = usePlayer();
  const [sleepTimerMinutes, setSleepTimerMinutes] = useState<number | null>(null);
  const [remainingTime, setRemainingTime] = useState(0);
  const timerInterval = useRef<NodeJS.Timeout | null>(null);

  useEffect(() => {
    if (sleepTimerMinutes !== null) {
      setRemainingTime(sleepTimerMinutes * 60);
      
      timerInterval.current = setInterval(() => {
        setRemainingTime((prev) => {
          if (prev <= 1) {
            pause();
            setSleepTimerMinutes(null);
            toast.success('Sleep timer ended - music paused');
            return 0;
          }
          return prev - 1;
        });
      }, 1000);
    }

    return () => {
      if (timerInterval.current) {
        clearInterval(timerInterval.current);
      }
    };
  }, [sleepTimerMinutes, pause]);

  const setSleepTimer = useCallback((minutes: number | null) => {
    if (timerInterval.current) {
      clearInterval(timerInterval.current);
    }
    setSleepTimerMinutes(minutes);
    if (minutes) {
      toast.success(`Sleep timer set for ${minutes} minutes`);
    }
  }, []);

  const cancelSleepTimer = useCallback(() => {
    if (timerInterval.current) {
      clearInterval(timerInterval.current);
    }
    setSleepTimerMinutes(null);
    setRemainingTime(0);
    toast.info('Sleep timer cancelled');
  }, []);

  return (
    <SleepTimerContext.Provider
      value={{
        sleepTimerMinutes,
        remainingTime,
        setSleepTimer,
        cancelSleepTimer,
      }}
    >
      {children}
    </SleepTimerContext.Provider>
  );
}

export function useSleepTimer() {
  const context = useContext(SleepTimerContext);
  if (context === undefined) {
    throw new Error('useSleepTimer must be used within a SleepTimerProvider');
  }
  return context;
}
