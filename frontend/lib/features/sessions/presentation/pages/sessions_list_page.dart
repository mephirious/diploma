import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/session_provider.dart';

class SessionsListPage extends ConsumerWidget {
  const SessionsListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(openSessionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Open Sessions'),
      ),
      body: sessionsAsync.when(
        data: (sessions) {
          if (sessions.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No open sessions available'),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(openSessionsProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sessions.length,
              itemBuilder: (context, index) {
                final session = sessions[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Chip(
                              label: Text(session.sportType),
                              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                            ),
                            const Spacer(),
                            Text(
                              '\$${session.pricePerParticipant.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (session.skillLevel != null)
                          Text('Skill Level: ${session.skillLevel}'),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.people, size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              '${session.currentParticipants}/${session.maxParticipants} players',
                            ),
                          ],
                        ),
                        if (session.description != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            session.description!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: session.currentParticipants >= session.maxParticipants
                                ? null
                                : () => context.push('/sessions/${session.id}'),
                            child: Text(
                              session.currentParticipants >= session.maxParticipants
                                  ? 'Full'
                                  : 'Join Session',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: ${error.toString()}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(openSessionsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Venues',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_available),
            label: 'Sessions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_online),
            label: 'My Bookings',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/venues');
              break;
            case 1:
              context.go('/sessions');
              break;
            case 2:
              context.go('/reservations');
              break;
          }
        },
      ),
    );
  }
}

