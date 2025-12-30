import React, { useState } from 'react';
import { AnimatePresence } from 'framer-motion';
import { BottomNav } from '@/components/navigation/BottomNav';
import { MiniPlayer } from '@/components/player/MiniPlayer';
import { NowPlaying } from '@/components/player/NowPlaying';
import { QueueManager } from '@/components/player/QueueManager';
import { SplashScreen } from '@/components/SplashScreen';
import { HomeScreen } from '@/components/screens/HomeScreen';
import { SearchScreen } from '@/components/screens/SearchScreen';
import { LibraryScreen } from '@/components/screens/LibraryScreen';
import { SettingsScreen } from '@/components/screens/SettingsScreen';
import { usePlayer } from '@/contexts/PlayerContext';
import { useKeyboardShortcuts } from '@/hooks/useKeyboardShortcuts';

type Tab = 'home' | 'search' | 'library' | 'settings';

const Index = () => {
  const [showSplash, setShowSplash] = useState(true);
  const [activeTab, setActiveTab] = useState<Tab>('home');
  const [isNowPlayingExpanded, setIsNowPlayingExpanded] = useState(false);
  const [isQueueOpen, setIsQueueOpen] = useState(false);
  const { currentTrack, togglePlay, next, previous, seek, currentTime, setVolume, volume } = usePlayer();

  // Keyboard shortcuts
  useKeyboardShortcuts({
    onPlayPause: togglePlay,
    onNext: next,
    onPrevious: previous,
    onSeekForward: (seconds) => seek(currentTime + seconds),
    onSeekBackward: (seconds) => seek(Math.max(0, currentTime - seconds)),
    onVolumeUp: () => setVolume(Math.min(1, volume + 0.1)),
    onVolumeDown: () => setVolume(Math.max(0, volume - 0.1)),
    enabled: !showSplash,
  });

  const renderScreen = () => {
    switch (activeTab) {
      case 'home': return <HomeScreen />;
      case 'search': return <SearchScreen />;
      case 'library': return <LibraryScreen />;
      case 'settings': return <SettingsScreen />;
      default: return <HomeScreen />;
    }
  };

  return (
    <>
      <AnimatePresence>
        {showSplash && (
          <SplashScreen onComplete={() => setShowSplash(false)} />
        )}
      </AnimatePresence>

      <div className={`min-h-screen bg-background ${showSplash ? 'hidden' : ''}`}>
        <main className="px-4 pb-4 max-w-lg mx-auto">{renderScreen()}</main>
        
        {currentTrack && !isNowPlayingExpanded && (
          <MiniPlayer onClick={() => setIsNowPlayingExpanded(true)} />
        )}
        
        <NowPlaying 
          isExpanded={isNowPlayingExpanded} 
          onCollapse={() => setIsNowPlayingExpanded(false)}
          onOpenQueue={() => setIsQueueOpen(true)}
        />
        
        <QueueManager isOpen={isQueueOpen} onClose={() => setIsQueueOpen(false)} />
        <BottomNav activeTab={activeTab} onTabChange={setActiveTab} />
      </div>
    </>
  );
};

export default Index;
