import { api } from '@/api/client';

function asRecord(data: unknown): Record<string, unknown> {
  if (data && typeof data === 'object' && !Array.isArray(data)) {
    return data as Record<string, unknown>;
  }
  return {};
}

export async function listConversations(page = 1, pageSize = 50) {
  const { data } = await api.get('/chat/v1/conversations', {
    params: { page, page_size: pageSize },
  });
  return asRecord(data);
}

export async function listMessages(
  conversationId: string,
  pageSize = 50,
  before?: string,
) {
  const params: Record<string, string | number> = { page_size: pageSize };
  if (before) params.before = before;
  const { data } = await api.get(
    `/chat/v1/conversations/${conversationId}/messages`,
    { params },
  );
  return asRecord(data);
}

export async function sendTextMessage(
  conversationId: string,
  content: string,
  senderDisplayName?: string,
) {
  const body: Record<string, string> = {
    type: 'MESSAGE_TYPE_TEXT',
    content,
  };
  const s = senderDisplayName?.trim();
  if (s) body.sender_display_name = s;
  const { data } = await api.post(
    `/chat/v1/conversations/${conversationId}/messages`,
    body,
  );
  return asRecord(data);
}

export async function markConversationRead(conversationId: string) {
  try {
    await api.post(`/chat/v1/conversations/${conversationId}/read`, {});
  } catch {
    // non-fatal
  }
}
