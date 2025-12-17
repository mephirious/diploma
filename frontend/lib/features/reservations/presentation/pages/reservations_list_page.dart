import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/reservation_provider.dart';

class ReservationsListPage extends ConsumerWidget {
  const ReservationsListPage({super.key});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reservationsAsync = ref.watch(myReservationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
      ),
      body: reservationsAsync.when(
        data: (reservations) {
          if (reservations.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No bookings yet'),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(myReservationsProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: reservations.length,
              itemBuilder: (context, index) {
                final reservation = reservations[index];
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
                              label: Text(reservation.status),
                              backgroundColor: _getStatusColor(reservation.status),
                              labelStyle: const TextStyle(color: Colors.white),
                            ),
                            const Spacer(),
                            if (reservation.reservedAt != null)
                              Text(
                                DateFormat('MMM dd, yyyy').format(
                                  reservation.reservedAt!,
                                ),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Booking ID: ${reservation.id}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        if (reservation.comment != null) ...[
                          const SizedBox(height: 8),
                          Text(reservation.comment!),
                        ],
                        const SizedBox(height: 12),
                        if (reservation.status.toLowerCase() == 'confirmed')
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.group_add),
                              label: const Text('Create Session'),
                              onPressed: () {
                                context.push(
                                  '/sessions/create',
                                  extra: {'reservationId': reservation.id},
                                );
                              },
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
                onPressed: () => ref.invalidate(myReservationsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
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

