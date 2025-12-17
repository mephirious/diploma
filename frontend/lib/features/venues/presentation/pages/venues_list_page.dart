import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/venue_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class VenuesListPage extends ConsumerWidget {
  const VenuesListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final venuesAsync = ref.watch(venuesProvider);
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Venues'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: venuesAsync.when(
        data: (venues) {
          if (venues.isEmpty) {
            return const Center(
              child: Text('No venues available'),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(venuesProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: venues.length,
              itemBuilder: (context, index) {
                final venue = venues[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Icon(Icons.sports_tennis),
                    ),
                    title: Text(venue.name),
                    subtitle: Text('${venue.city} • ${venue.address}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/venues/${venue.id}'),
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
                onPressed: () => ref.invalidate(venuesProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
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

