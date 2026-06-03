import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/venue_model.dart';
import '../../data/repositories/venue_repository.dart';
import '../widgets/venue_card.dart';
import 'venue_detail_page.dart';

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────

class _PromoVenuesState {
  final List<VenueModel> items;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int page;
  final int pageSize;
  final String? error;

  const _PromoVenuesState({
    required this.items,
    required this.isLoading,
    required this.isLoadingMore,
    required this.hasMore,
    required this.page,
    required this.pageSize,
    this.error,
  });

  _PromoVenuesState copyWith({
    List<VenueModel>? items,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? page,
    int? pageSize,
    String? error,
  }) {
    return _PromoVenuesState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      error: error,
    );
  }

  factory _PromoVenuesState.initial() => const _PromoVenuesState(
        items: [],
        isLoading: true,
        isLoadingMore: false,
        hasMore: true,
        page: 0,
        pageSize: 40,
      );
}

class _PromoVenuesNotifier extends StateNotifier<_PromoVenuesState> {
  final VenueRepository _repo;

  _PromoVenuesNotifier(this._repo) : super(_PromoVenuesState.initial()) {
    _load(page: 0);
  }

  Future<void> refresh() => _load(page: 0, replace: true);

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    await _load(page: state.page + 1);
  }

  Future<void> _load({required int page, bool replace = false}) async {
    if (page == 0) {
      state = state.copyWith(
        isLoading: replace || state.items.isEmpty,
        isLoadingMore: false,
        error: null,
      );
    } else {
      state = state.copyWith(isLoadingMore: true, error: null);
    }

    try {
      final resp = await _repo.getVenuesWithPromos(
        page: page,
        pageSize: state.pageSize,
      );
      final merged = page == 0
          ? resp.venues
          : [...state.items, ...resp.venues];
      state = state.copyWith(
        items: merged,
        isLoading: false,
        isLoadingMore: false,
        hasMore: resp.hasMore,
        page: resp.page,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        hasMore: false,
        error: e.toString(),
      );
    }
  }
}

final _promoVenuesProvider =
    StateNotifierProvider.autoDispose<_PromoVenuesNotifier, _PromoVenuesState>(
  (ref) => _PromoVenuesNotifier(ref.watch(venueRepositoryProvider)),
);

// ─────────────────────────────────────────────────────────────────────────────
// Page
// ─────────────────────────────────────────────────────────────────────────────

class PromoVenuesPage extends ConsumerStatefulWidget {
  const PromoVenuesPage({super.key});

  @override
  ConsumerState<PromoVenuesPage> createState() => _PromoVenuesPageState();
}

class _PromoVenuesPageState extends ConsumerState<PromoVenuesPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(_promoVenuesProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(_promoVenuesProvider);
    final bg = isDark ? const Color(0xFF0D1117) : const Color(0xFFF6F8FB);

    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // ── App bar ──
          SliverAppBar(
            backgroundColor: bg,
            pinned: true,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: isDark ? Colors.white : const Color(0xFF0D1117),
                size: 20,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              l10n.promoVenuesTitle,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF0D1117),
              ),
            ),
            centerTitle: true,
          ),

          // ── Header banner ──
          SliverToBoxAdapter(
            child: _PromoBanner(isDark: isDark, l10n: l10n),
          ),

          // ── Content ──
          if (state.isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (state.error != null && state.items.isEmpty)
            SliverFillRemaining(
              child: _ErrorView(
                message: state.error!,
                onRetry: () =>
                    ref.read(_promoVenuesProvider.notifier).refresh(),
                isDark: isDark,
              ),
            )
          else if (state.items.isEmpty)
            SliverFillRemaining(
              child: _EmptyView(isDark: isDark, l10n: l10n),
            )
          else ...[
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) {
                    if (i >= state.items.length) return null;
                    final venue = state.items[i];
                    return VenueCard(
                      venue: venue,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              VenueDetailPage(venueId: venue.id),
                        ),
                      ),
                    );
                  },
                  childCount: state.items.length,
                ),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.78,
                ),
              ),
            ),
            if (state.isLoadingMore)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _PromoBanner extends StatelessWidget {
  final bool isDark;
  final AppLocalizations l10n;

  const _PromoBanner({required this.isDark, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B35), Color(0xFFFF3D71)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B35).withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          const Text('🏷️', style: TextStyle(fontSize: 36)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.promoVenuesBannerTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.promoVenuesBannerSubtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final bool isDark;
  final AppLocalizations l10n;
  const _EmptyView({required this.isDark, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_offer_outlined,
            size: 72,
            color: AppColors.colorMain.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.promoVenuesEmpty,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : const Color(0xFF4A5568),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.promoVenuesEmptySubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? const Color(0xFF8B949E)
                  : const Color(0xFF6E7A8A),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final bool isDark;

  const _ErrorView({
    required this.message,
    required this.onRetry,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi_off_rounded,
              size: 56,
              color: isDark ? Colors.white30 : Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? Colors.white60 : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: onRetry,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.colorMain,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(AppLocalizations.of(context)!.retry),
          ),
        ],
      ),
    );
  }
}
