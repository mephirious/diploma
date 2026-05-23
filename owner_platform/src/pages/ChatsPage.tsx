import { useEffect, useRef, useState } from 'react';
import { MessageCircle, Send } from 'lucide-react';
import { useTranslation } from 'react-i18next';

import { PageHeader } from '@/components/common/PageHeader';
import { EmptyState } from '@/components/ui/EmptyState';
import { cn } from '@/lib/cn';
import { formatChatTime, formatMessageClock } from '@/lib/chat';
import { useChatStore } from '@/store/chat';
import type { ChatConversation, ChatMessage } from '@/types/chat';

export function ChatsPage() {
  const { t } = useTranslation();
  const conversations = useChatStore((s) => s.conversations);
  const selectedId = useChatStore((s) => s.selectedConversationId);
  const isBootstrapping = useChatStore((s) => s.isBootstrapping);
  const error = useChatStore((s) => s.error);
  const selectConversation = useChatStore((s) => s.selectConversation);

  const selected = conversations.find((c) => c.id === selectedId) ?? null;

  return (
    <div className="-mx-4 md:-mx-8 -my-6 md:-my-8 flex h-[calc(100vh-4rem)] min-h-[32rem] flex-col">
      <div className="shrink-0 border-b border-black/5 px-4 py-4 dark:border-white/10 md:px-8">
        <PageHeader title={t('chats.title')} subtitle={t('chats.subtitle')} />
        {error ? <p className="mt-2 text-sm text-danger">{error}</p> : null}
      </div>

      <div className="flex min-h-0 flex-1 overflow-hidden md:mx-8 md:mb-8 md:rounded-2xl md:border md:border-black/5 md:dark:border-white/10 md:bg-surface-light/50 md:dark:bg-surface-dark/50">
        <aside
          className={cn(
            'flex w-full shrink-0 flex-col border-r border-black/5 dark:border-white/10 md:w-80 lg:w-96',
            selectedId ? 'hidden md:flex' : 'flex',
          )}
        >
          {isBootstrapping && conversations.length === 0 ? (
            <div className="flex flex-1 items-center justify-center text-sm text-muted-light dark:text-muted-dark">
              {t('common.loading')}
            </div>
          ) : conversations.length === 0 ? (
            <div className="flex flex-1 items-center justify-center p-6">
              <EmptyState
                icon={<MessageCircle size={28} />}
                title={t('chats.emptyTitle')}
                description={t('chats.emptyDescription')}
              />
            </div>
          ) : (
            <ul className="flex-1 overflow-y-auto">
              {conversations.map((c) => (
                <ConversationRow
                  key={c.id}
                  conversation={c}
                  active={c.id === selectedId}
                  onSelect={() => void selectConversation(c.id)}
                />
              ))}
            </ul>
          )}
        </aside>

        <section
          className={cn(
            'flex min-w-0 flex-1 flex-col',
            !selectedId ? 'hidden md:flex' : 'flex',
          )}
        >
          {selected ? (
            <ChatThread conversation={selected} />
          ) : (
            <div className="flex flex-1 flex-col items-center justify-center gap-3 p-8 text-center">
              <div className="flex h-14 w-14 items-center justify-center rounded-2xl bg-brand-500/15 text-brand-600 dark:text-brand-300">
                <MessageCircle size={28} />
              </div>
              <p className="text-sm font-semibold text-muted-light dark:text-muted-dark">
                {t('chats.selectThread')}
              </p>
            </div>
          )}
        </section>
      </div>
    </div>
  );
}

function ConversationRow({
  conversation: c,
  active,
  onSelect,
}: {
  conversation: ChatConversation;
  active: boolean;
  onSelect: () => void;
}) {
  return (
    <li>
      <button
        type="button"
        onClick={onSelect}
        className={cn(
          'flex w-full items-start gap-3 px-4 py-3 text-left transition-colors',
          active
            ? 'bg-brand-500/10'
            : 'hover:bg-black/[0.03] dark:hover:bg-white/[0.04]',
        )}
      >
        <div className="flex h-11 w-11 shrink-0 items-center justify-center rounded-full bg-brand-500/15 text-brand-700 dark:text-brand-200">
          <MessageCircle size={20} />
        </div>
        <div className="min-w-0 flex-1">
          <div className="flex items-baseline justify-between gap-2">
            <span
              className={cn(
                'truncate text-[14px]',
                c.unreadCount > 0 ? 'font-bold' : 'font-semibold',
              )}
            >
              {c.name}
            </span>
            <span
              className={cn(
                'shrink-0 text-[11px]',
                c.unreadCount > 0
                  ? 'font-semibold text-brand-600 dark:text-brand-300'
                  : 'text-muted-light dark:text-muted-dark',
              )}
            >
              {formatChatTime(c.lastMessageTime)}
            </span>
          </div>
          <div className="mt-0.5 flex items-center justify-between gap-2">
            <p
              className={cn(
                'truncate text-[13px]',
                c.unreadCount > 0
                  ? 'font-medium text-text-light dark:text-text-dark'
                  : 'text-muted-light dark:text-muted-dark',
              )}
            >
              {c.lastMessage || ' '}
            </p>
            {c.unreadCount > 0 ? (
              <span className="shrink-0 rounded-full bg-brand-500 px-2 py-0.5 text-[10px] font-bold text-white">
                {c.unreadCount}
              </span>
            ) : null}
          </div>
        </div>
      </button>
    </li>
  );
}

function ChatThread({ conversation }: { conversation: ChatConversation }) {
  const { t } = useTranslation();
  const messages =
    useChatStore((s) => s.messagesByConversationId[conversation.id]) ?? [];
  const sendMessage = useChatStore((s) => s.sendMessage);
  const clearSelection = useChatStore((s) => s.clearSelection);
  const [draft, setDraft] = useState('');
  const [sending, setSending] = useState(false);
  const bottomRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    bottomRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages.length, conversation.id]);

  async function handleSend() {
    const text = draft.trim();
    if (!text || sending) return;
    setSending(true);
    try {
      await sendMessage(conversation.id, text);
      setDraft('');
    } finally {
      setSending(false);
    }
  }

  return (
    <>
      <header className="flex shrink-0 items-center gap-3 border-b border-black/5 px-4 py-3 dark:border-white/10 md:px-5">
        <button
          type="button"
          className="text-sm font-semibold text-brand-600 md:hidden dark:text-brand-300"
          onClick={clearSelection}
        >
          {t('common.back')}
        </button>
        <div className="flex h-10 w-10 items-center justify-center rounded-full bg-brand-500/15 text-brand-700 dark:text-brand-200">
          <MessageCircle size={18} />
        </div>
        <h2 className="min-w-0 flex-1 truncate text-[15px] font-bold">
          {conversation.name}
        </h2>
      </header>

      <div className="flex-1 overflow-y-auto px-4 py-4 md:px-5">
        {messages.length === 0 ? (
          <p className="py-12 text-center text-sm text-muted-light dark:text-muted-dark">
            {t('chats.emptyThread')}
          </p>
        ) : (
          <div className="space-y-2">
            {messages.map((m) => (
              <MessageBubble key={m.id} message={m} />
            ))}
            <div ref={bottomRef} />
          </div>
        )}
      </div>

      <footer className="shrink-0 border-t border-black/5 p-3 dark:border-white/10 md:p-4">
        <form
          className="flex items-end gap-2"
          onSubmit={(e) => {
            e.preventDefault();
            void handleSend();
          }}
        >
          <textarea
            value={draft}
            onChange={(e) => setDraft(e.target.value)}
            onKeyDown={(e) => {
              if (e.key === 'Enter' && !e.shiftKey) {
                e.preventDefault();
                void handleSend();
              }
            }}
            rows={1}
            placeholder={t('chats.messagePlaceholder')}
            className={cn(
              'max-h-32 min-h-[44px] flex-1 resize-none rounded-xl border px-4 py-2.5 text-sm',
              'border-black/10 bg-bg-light dark:border-white/10 dark:bg-bg-dark',
              'focus:outline-none focus:ring-2 focus:ring-brand-500/40',
            )}
          />
          <button
            type="submit"
            disabled={sending || !draft.trim()}
            className={cn(
              'flex h-11 w-11 shrink-0 items-center justify-center rounded-xl',
              'bg-brand-500 text-white transition-opacity hover:bg-brand-600 disabled:opacity-40',
            )}
            aria-label={t('common.send')}
          >
            <Send size={18} />
          </button>
        </form>
      </footer>
    </>
  );
}

function MessageBubble({ message }: { message: ChatMessage }) {
  const isMe = message.isMe;
  return (
    <div className={cn('flex', isMe ? 'justify-end' : 'justify-start')}>
      <div
        className={cn(
          'max-w-[min(85%,28rem)] rounded-2xl px-3.5 py-2.5 text-sm',
          isMe
            ? 'rounded-br-md bg-brand-500 text-white'
            : 'rounded-bl-md bg-black/[0.06] text-text-light dark:bg-white/[0.08] dark:text-text-dark',
        )}
      >
        <p className="whitespace-pre-wrap break-words">{message.text}</p>
        <p
          className={cn(
            'mt-1 text-[10px]',
            isMe ? 'text-white/70' : 'text-muted-light dark:text-muted-dark',
          )}
        >
          {formatMessageClock(message.timestamp)}
        </p>
      </div>
    </div>
  );
}
