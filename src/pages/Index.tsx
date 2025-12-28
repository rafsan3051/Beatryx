import React, { useState } from 'react';
import { BottomNav } from '@/components/navigation/BottomNav';
import { MiniPlayer } from '@/components/player/MiniPlayer';
import { NowPlaying } from '@/components/player/NowPlaying';
import { HomeScreen } from '@/components/screens/HomeScreen';
import { SearchScreen } from '@/components/screens/SearchScreen';
import { LibraryScreen } from '@/components/screens/LibraryScreen';
import { SettingsScreen } from '@/components/screens/SettingsScreen';
import { usePlayer } from '@/contexts/PlayerContext';

type Tab = 'home' | 'search' | 'library' | 'settings';

const Index = () => {
  const [activeTab, setActiveTab] = useState<Tab>('home');
  const [isNowPlayingExpanded, setIsNowPlayingExpanded] = useState(false);
  const { currentTrack } = usePlayer();

  const renderScreen = () => {
    switch (activeTab) {
      case 'home':
        return <HomeScreen />;
      case 'search':
        return <SearchScreen />;
      case 'library':
        return <LibraryScreen />;
      case 'settings':
        return <SettingsScreen />;
      default:
        return <HomeScreen />;
    }
  };

  return (
    <div className="min-h-screen bg-background">
      {/* Main Content */}
      <main className="px-4 pb-4 max-w-lg mx-auto">
        {renderScreen()}
      </main>

      {/* Mini Player */}
      {currentTrack && !isNowPlayingExpanded && (
        <MiniPlayer onClick={() => setIsNowPlayingExpanded(true)} />
      )}

      {/* Now Playing Full Screen */}
      <NowPlaying 
        isExpanded={isNowPlayingExpanded} 
        onCollapse={() => setIsNowPlayingExpanded(false)} 
      />

      {/* Bottom Navigation */}
      <BottomNav activeTab={activeTab} onTabChange={setActiveTab} />
    </div>
  );
};

export default Index;
