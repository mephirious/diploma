import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/venue_provider.dart';
import '../widgets/venue_card.dart';
import 'venue_detail_page.dart';

class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(favoritesListProvider);

    if (state.isLoadingInitial) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.error != null && state.items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.myFavorites, style: const TextStyle(fontWeight: FontWeight.bold))),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 12),
              Text(state.error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    ref.read(favoritesListProvider.notifier).loadFirstPage(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myFavorites, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: state.items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border,
                      size: 80,
                      color: isDark ? Colors.grey[600] : Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noFavorites,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      l10n.addFavorites,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                    ),
                  ),
                ],
              ),
            )
          : NotificationListener<ScrollNotification>(
              onNotification: (n) {
                if (n is ScrollEndNotification &&
                    n.metrics.extentAfter < 200 &&
                    !state.isLoadingMore &&
                    state.hasMore) {
                  ref.read(favoritesListProvider.notifier).loadNextPage();
                }
                return false;
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == state.items.length) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final venue = state.items[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: VenueCard(
                      venue: venue,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VenueDetailPage(venueId: venue.id),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
