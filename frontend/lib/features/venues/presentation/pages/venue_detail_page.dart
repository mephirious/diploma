import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/venue_provider.dart';

class VenueDetailPage extends ConsumerWidget {
  final String venueId;

  const VenueDetailPage({super.key, required this.venueId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final venueAsync = ref.watch(venueByIdProvider(venueId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Venue Details'),
      ),
      body: venueAsync.when(
        data: (venue) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Icon(
                    Icons.sports_tennis,
                    size: 80,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        venue.name,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 20, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text('${venue.city}, ${venue.address}'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Description',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(venue.description),
                      const SizedBox(height: 24),
                      Text(
                        'Available Resources',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      if (venue.resources.isEmpty)
                        const Text('No resources available')
                      else
                        ...venue.resources.map((resource) {
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: Icon(Icons.sports_baseball),
                              title: Text(resource.name),
                              subtitle: Text(
                                '${resource.sportType}${resource.capacity != null ? " • Capacity: ${resource.capacity}" : ""}',
                              ),
                              trailing: ElevatedButton(
                                onPressed: () {
                                  context.push(
                                    '/booking/create',
                                    extra: {
                                      'venueId': venue.id,
                                      'resourceId': resource.id,
                                    },
                                  );
                                },
                                child: const Text('Book'),
                              ),
                            ),
                          );
                        }).toList(),
                    ],
                  ),
                ),
              ],
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
            ],
          ),
        ),
      ),
    );
  }
}

