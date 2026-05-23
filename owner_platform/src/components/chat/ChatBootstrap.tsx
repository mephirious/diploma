import { useEffect } from 'react';
import { useAuth } from '@/store/auth';
import { useChatStore } from '@/store/chat';

/** Starts chat WS + polling while the owner is authenticated. */
export function ChatBootstrap() {
  const isAuthenticated = useAuth((s) => s.isAuthenticated);

  useEffect(() => {
    if (!isAuthenticated) {
      useChatStore.getState().teardown();
      return;
    }
    void useChatStore.getState().bootstrap();
    return () => {
      useChatStore.getState().teardown();
    };
  }, [isAuthenticated]);

  return null;
}
