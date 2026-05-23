import { create } from 'zustand';

import * as chatApi from '@/api/chat';
import {
  decodeJwtSub,
  parseConversation,
  parseMessage,
} from '@/lib/chat';
import type { ChatConversation, ChatMessage } from '@/types/chat';
import { useAuth } from '@/store/auth';

const WS_URL =
  import.meta.env.VITE_CHAT_WS_URL ?? 'ws://localhost:8070/ws';

const POLL_MS = 20_000;

type ChatState = {
  conversations: ChatConversation[];
  messagesByConversationId: Record<string, ChatMessage[]>;
  selectedConversationId: string | null;
  openConversationId: string | null;
  isBootstrapping: boolean;
  wsConnected: boolean;
  error: string | null;
  _ws: WebSocket | null;
  _pollTimer: ReturnType<typeof setInterval> | null;
  _bootstrapped: boolean;

  myId: () => string | null;
  myDisplayName: () => string;
  totalUnread: () => number;

  bootstrap: () => Promise<void>;
  teardown: () => void;
  refreshConversations: (silent?: boolean) => Promise<void>;
  selectConversation: (id: string) => Promise<void>;
  clearSelection: () => void;
  loadMessages: (conversationId: string) => Promise<void>;
  sendMessage: (conversationId: string, text: string) => Promise<void>;
  markRead: (conversationId: string) => Promise<void>;
};

function getMyId(): string | null {
  const auth = useAuth.getState();
  const fromProfile = auth.user?.id?.trim();
  if (fromProfile) return fromProfile;
  return decodeJwtSub(auth.accessToken);
}

function getMyDisplayName(): string {
  const u = useAuth.getState().user;
  if (!u) return 'Owner';
  const full = u.fullName?.trim();
  if (full) return full;
  const un = u.username?.trim();
  if (un) return un;
  const em = u.email?.trim();
  if (em) {
    const at = em.indexOf('@');
    if (at > 0) return em.slice(0, at);
  }
  return 'Owner';
}

export const useChatStore = create<ChatState>((set, get) => ({
  conversations: [],
  messagesByConversationId: {},
  selectedConversationId: null,
  openConversationId: null,
  isBootstrapping: false,
  wsConnected: false,
  error: null,
  _ws: null,
  _pollTimer: null,
  _bootstrapped: false,

  myId: getMyId,
  myDisplayName: getMyDisplayName,
  totalUnread: () =>
    get().conversations.reduce((s, c) => s + c.unreadCount, 0),

  bootstrap: async () => {
    const myId = getMyId();
    if (!myId || get()._bootstrapped) return;

    set({ isBootstrapping: true, error: null, _bootstrapped: true });
    try {
      await get().refreshConversations();
      connectWebSocket(set, get);
      const timer = setInterval(() => {
        void get().refreshConversations(true);
      }, POLL_MS);
      set({ _pollTimer: timer });
    } catch (e) {
      set({
        error: e instanceof Error ? e.message : String(e),
      });
    } finally {
      set({ isBootstrapping: false });
    }
  },

  teardown: () => {
    const { _ws, _pollTimer } = get();
    if (_pollTimer) clearInterval(_pollTimer);
    if (_ws) {
      try {
        _ws.close();
      } catch {
        /* ignore */
      }
    }
    set({
      conversations: [],
      messagesByConversationId: {},
      selectedConversationId: null,
      openConversationId: null,
      isBootstrapping: false,
      wsConnected: false,
      error: null,
      _ws: null,
      _pollTimer: null,
      _bootstrapped: false,
    });
  },

  refreshConversations: async (silent = false) => {
    const myId = getMyId();
    if (!myId) return;

    try {
      const body = await chatApi.listConversations(1, 50);
      const list = body.conversations;
      const rawList = Array.isArray(list) ? list : [];
      const cache = get().messagesByConversationId;
      const next: ChatConversation[] = [];

      for (const raw of rawList) {
        if (!raw || typeof raw !== 'object') continue;
        let conv = parseConversation(raw as Record<string, unknown>, myId);
        if (!conv.lastMessage.trim()) {
          const msgs = cache[conv.id];
          const last = msgs?.[msgs.length - 1];
          if (last?.text.trim()) {
            conv = { ...conv, lastMessage: last.text, lastMessageTime: last.timestamp };
          }
        }
        next.push(conv);
      }

      next.sort(
        (a, b) => b.lastMessageTime.getTime() - a.lastMessageTime.getTime(),
      );
      set({ conversations: next });
      subscribeAll(get);
    } catch (e) {
      if (!silent) {
        set({
          error: e instanceof Error ? e.message : String(e),
        });
      }
    }
  },

  selectConversation: async (id) => {
    set({
      selectedConversationId: id,
      openConversationId: id,
    });
    await get().loadMessages(id);
    await get().markRead(id);
  },

  clearSelection: () => {
    set({ selectedConversationId: null, openConversationId: null });
  },

  loadMessages: async (conversationId) => {
    const myId = getMyId();
    if (!myId || !conversationId) return;

    const body = await chatApi.listMessages(conversationId, 50);
    const list = body.messages;
    const rawList = Array.isArray(list) ? list : [];
    const convs = get().conversations;
    const parsed: ChatMessage[] = rawList
      .filter((m): m is Record<string, unknown> => !!m && typeof m === 'object')
      .map((m) => parseMessage(m, myId, convs))
      .sort((a, b) => a.timestamp.getTime() - b.timestamp.getTime());

    set((s) => ({
      messagesByConversationId: {
        ...s.messagesByConversationId,
        [conversationId]: parsed,
      },
    }));
  },

  sendMessage: async (conversationId, text) => {
    const myId = getMyId();
    if (!myId) throw new Error('Not authenticated');

    const trimmed = text.trim();
    if (!trimmed) return;

    const sent = await chatApi.sendTextMessage(
      conversationId,
      trimmed,
      getMyDisplayName(),
    );
    const msg = parseMessage(sent, myId, get().conversations);
    appendMessage(set, get, msg);
    bumpFromSent(set, get, msg);
    void get().refreshConversations(true);
  },

  markRead: async (conversationId) => {
    await chatApi.markConversationRead(conversationId);
    set((s) => ({
      conversations: s.conversations.map((c) =>
        c.id === conversationId ? { ...c, unreadCount: 0 } : c,
      ),
    }));
  },
}));

function connectWebSocket(
  set: typeof useChatStore.setState,
  get: typeof useChatStore.getState,
) {
  const token = useAuth.getState().accessToken;
  if (!token) return;

  const old = get()._ws;
  if (old) {
    try {
      old.close();
    } catch {
      /* ignore */
    }
  }

  const url = new URL(WS_URL);
  url.searchParams.set('token', token);

  try {
    const ws = new WebSocket(url.toString());
    set({ _ws: ws, wsConnected: true });

    ws.onmessage = (ev) => {
      const raw = typeof ev.data === 'string' ? ev.data : '';
      if (!raw) return;
      try {
        const m = JSON.parse(raw) as { type?: string; message?: unknown };
        if (m.type === 'new_message' && m.message && typeof m.message === 'object') {
          handleInbound(set, get, m.message as Record<string, unknown>);
        }
      } catch {
        /* ignore */
      }
    };

    ws.onerror = () => set({ wsConnected: false });
    ws.onclose = () => set({ wsConnected: false });
    ws.onopen = () => {
      set({ wsConnected: true });
      subscribeAll(get);
    };
  } catch {
    set({ wsConnected: false });
  }
}

function subscribeAll(get: typeof useChatStore.getState) {
  const ws = get()._ws;
  if (!ws || ws.readyState !== WebSocket.OPEN) return;
  const ids = get().conversations.map((c) => c.id).filter(Boolean);
  if (ids.length === 0) return;
  try {
    ws.send(
      JSON.stringify({ type: 'subscribe', conversation_ids: ids }),
    );
  } catch {
    /* ignore */
  }
}

function handleInbound(
  set: typeof useChatStore.setState,
  get: typeof useChatStore.getState,
  inner: Record<string, unknown>,
) {
  const myId = getMyId();
  if (!myId) return;

  const convId = String(
    inner.conversation_id ?? inner.conversationId ?? '',
  ).trim();
  if (!convId) return;

  const msg = parseMessage(inner, myId, get().conversations);
  const open = get().openConversationId;
  const fromOther = msg.senderId !== myId;
  const existed = get().conversations.some((c) => c.id === convId);

  if (!existed) {
    const placeholder: ChatConversation = {
      id: convId,
      name: fromOther ? shortId(msg.senderId) : 'Chat',
      lastMessage: msg.text,
      lastMessageTime: msg.timestamp,
      unreadCount: fromOther && open !== convId ? 1 : 0,
      otherUserId: fromOther ? msg.senderId : null,
      participantDisplayNames: {},
    };
    upsertConversation(set, get, placeholder);
    void get().refreshConversations(true);
  } else {
    bumpInbound(set, get, msg);
    if (fromOther && open !== convId) {
      incrementUnread(set, get, convId);
    }
  }

  appendMessage(set, get, msg);
}

function shortId(id: string): string {
  const t = id.trim();
  if (t.length <= 13) return t;
  return `${t.slice(0, 8)}…`;
}

function appendMessage(
  set: typeof useChatStore.setState,
  get: typeof useChatStore.getState,
  msg: ChatMessage,
) {
  const existing = get().messagesByConversationId[msg.conversationId] ?? [];
  if (existing.some((m) => m.id === msg.id)) return;
  const merged = [...existing, msg].sort(
    (a, b) => a.timestamp.getTime() - b.timestamp.getTime(),
  );
  set((s) => ({
    messagesByConversationId: {
      ...s.messagesByConversationId,
      [msg.conversationId]: merged,
    },
  }));
}

function upsertConversation(
  set: typeof useChatStore.setState,
  _get: typeof useChatStore.getState,
  conv: ChatConversation,
) {
  set((s) => {
    const others = s.conversations.filter((c) => c.id !== conv.id);
    const next = [conv, ...others].sort(
      (a, b) => b.lastMessageTime.getTime() - a.lastMessageTime.getTime(),
    );
    return { conversations: next };
  });
}

function bumpFromSent(
  set: typeof useChatStore.setState,
  get: typeof useChatStore.getState,
  msg: ChatMessage,
) {
  set((s) => {
    const next = s.conversations.map((c) =>
      c.id === msg.conversationId
        ? {
            ...c,
            lastMessage: msg.text,
            lastMessageTime: msg.timestamp,
          }
        : c,
    );
    next.sort(
      (a, b) => b.lastMessageTime.getTime() - a.lastMessageTime.getTime(),
    );
    return { conversations: next };
  });
  subscribeAll(get);
}

function bumpInbound(
  set: typeof useChatStore.setState,
  _get: typeof useChatStore.getState,
  msg: ChatMessage,
) {
  set((s) => {
    const idx = s.conversations.findIndex((c) => c.id === msg.conversationId);
    if (idx < 0) return s;
    const c = s.conversations[idx];
    const updated = {
      ...c,
      lastMessage: msg.text,
      lastMessageTime: msg.timestamp,
    };
    const next = [...s.conversations];
    next[idx] = updated;
    next.sort(
      (a, b) => b.lastMessageTime.getTime() - a.lastMessageTime.getTime(),
    );
    return { conversations: next };
  });
}

function incrementUnread(
  set: typeof useChatStore.setState,
  _get: typeof useChatStore.getState,
  conversationId: string,
) {
  set((s) => {
    const next = s.conversations.map((c) =>
      c.id === conversationId
        ? { ...c, unreadCount: c.unreadCount + 1 }
        : c,
    );
    next.sort(
      (a, b) => b.lastMessageTime.getTime() - a.lastMessageTime.getTime(),
    );
    return { conversations: next };
  });
}
