import type { ChatConversation, ChatMessage } from '@/types/chat';

export function decodeJwtSub(token: string | null): string | null {
  if (!token) return null;
  try {
    const parts = token.split('.');
    if (parts.length !== 3) return null;
    const b64 = parts[1].replace(/-/g, '+').replace(/_/g, '/');
    const json = JSON.parse(atob(b64)) as { sub?: string };
    const sub = json.sub?.trim();
    return sub || null;
  } catch {
    return null;
  }
}

export function parseTimestamp(v: unknown): Date | null {
  if (v == null) return null;
  if (typeof v === 'string') {
    const d = new Date(v);
    return Number.isNaN(d.getTime()) ? null : d;
  }
  if (typeof v === 'object' && v !== null && 'seconds' in v) {
    const sec = Number((v as { seconds?: number }).seconds);
    if (!Number.isFinite(sec)) return null;
    return new Date(sec * 1000);
  }
  return null;
}

function peerTitle(otherUserId: string | null): string {
  if (!otherUserId) return 'Chat';
  const t = otherUserId.trim();
  if (t.length <= 13) return t;
  return `${t.slice(0, 8)}…`;
}

export function parseConversation(
  raw: Record<string, unknown>,
  myId: string,
): ChatConversation {
  const id = String(raw.id ?? '');
  const participants = Array.isArray(raw.participants)
    ? raw.participants.map((p) =>
        p && typeof p === 'object' ? (p as Record<string, unknown>) : {},
      )
    : [];

  const names: Record<string, string> = {};
  let otherId: string | null = null;
  let otherDisplay: string | null = null;

  for (const p of participants) {
    const uid = String(p.user_id ?? p.userId ?? '').trim();
    const dn = String(p.display_name ?? p.displayName ?? '').trim();
    if (uid && dn) names[uid] = dn;
  }

  for (const p of participants) {
    const uid = String(p.user_id ?? p.userId ?? '').trim();
    if (uid && uid !== myId) {
      otherId = uid;
      otherDisplay = names[uid] ?? null;
      break;
    }
  }

  const title = String(raw.title ?? '').trim();
  const name =
    title || otherDisplay || peerTitle(otherId);

  const lastMsg = raw.last_message ?? raw.lastMessage;
  let lastText = '';
  let lastTime =
    parseTimestamp(raw.last_message_at ?? raw.lastMessageAt) ??
    parseTimestamp(raw.created_at ?? raw.createdAt) ??
    new Date();

  if (lastMsg && typeof lastMsg === 'object') {
    const lm = lastMsg as Record<string, unknown>;
    const c = String(lm.content ?? '').trim();
    if (c) lastText = c;
    lastTime =
      parseTimestamp(lm.created_at ?? lm.createdAt) ?? lastTime;
  }

  const unreadRaw = raw.unread_count ?? raw.unreadCount;
  const unread =
    typeof unreadRaw === 'number'
      ? unreadRaw
      : Number.parseInt(String(unreadRaw ?? '0'), 10) || 0;

  return {
    id,
    name,
    lastMessage: lastText,
    lastMessageTime: lastTime,
    unreadCount: unread,
    otherUserId: otherId,
    participantDisplayNames: names,
  };
}

export function parseMessage(
  raw: Record<string, unknown>,
  myId: string,
  conversations: ChatConversation[],
): ChatMessage {
  const id = String(raw.id ?? '');
  const conversationId = String(
    raw.conversation_id ?? raw.conversationId ?? '',
  );
  const senderId = String(raw.sender_id ?? raw.senderId ?? '');
  const text = String(raw.content ?? '');
  const timestamp =
    parseTimestamp(raw.created_at ?? raw.createdAt) ?? new Date();
  const isMe = senderId === myId;

  let senderName = 'User';
  if (isMe) {
    senderName = 'You';
  } else {
    const conv = conversations.find((c) => c.id === conversationId);
    const dn = conv?.participantDisplayNames[senderId];
    senderName = dn || peerTitle(senderId);
  }

  return {
    id,
    conversationId,
    senderId,
    senderName,
    text,
    timestamp,
    isMe,
  };
}

export function formatChatTime(time: Date): string {
  const diff = Date.now() - time.getTime();
  const min = Math.floor(diff / 60000);
  if (min < 1) return 'now';
  if (min < 60) return `${min}m`;
  const h = Math.floor(min / 60);
  if (h < 24) return `${h}h`;
  const d = Math.floor(h / 24);
  if (d < 7) return `${d}d`;
  const local = new Date(time);
  return `${local.getDate()}/${local.getMonth() + 1}`;
}

export function formatMessageClock(time: Date): string {
  const local = new Date(time);
  const h = local.getHours().toString().padStart(2, '0');
  const m = local.getMinutes().toString().padStart(2, '0');
  return `${h}:${m}`;
}
