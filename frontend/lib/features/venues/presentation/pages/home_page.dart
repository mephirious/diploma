import 'dart:async' show unawaited;
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/main_scaffold.dart';
import '../../../../core/widgets/page_title_header.dart';
import '../providers/venue_provider.dart' as async_providers;
import '../widgets/venue_card.dart';
import 'venue_detail_page.dart';

// Local UI state for category & search, now independent from mock data.
final selectedCategoryProvider = StateProvider<String>((ref) => 'all');
final searchQueryProvider = StateProvider<String>((ref) => '');

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  ProviderSubscription<int>? _tabIndexSub;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _contentAboveSearchKey = GlobalKey();
  late final TextEditingController _searchController;
  /// Scroll offset (px) so the hero block is scrolled away and the search bar is pinned.
  double? _pinnedSearchScrollOffset;
  double? _lastTopPaddingForPinOffset;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final top = MediaQuery.paddingOf(context).top;
    if (_lastTopPaddingForPinOffset != top) {
      _lastTopPaddingForPinOffset = top;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _cachePinnedSearchScrollOffset();
      });
    }
  }

  /// Measures the hero + quick-access block once layout exists (stable for pinned search target).
  void _cachePinnedSearchScrollOffset() {
    final ctx = _contentAboveSearchKey.currentContext;
    if (ctx == null) return;
    final ro = ctx.findRenderObject();
    if (ro is! RenderBox) return;
    final h = ro.size.height;
    if (h <= 0) return;
    _pinnedSearchScrollOffset = h;
  }

  Future<void> _reloadVenuesAndScroll() async {
    _scrollToSearchBarPinned();
    final cat = ref.read(selectedCategoryProvider);
    await ref.read(async_providers.paginatedVenuesProvider.notifier).loadFirstPage(
          sport: cat == 'all' ? null : cat,
          search: ref.read(searchQueryProvider),
        );
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _cachePinnedSearchScrollOffset();
    });
  }

  void _scrollToSearchBarPinned() {
    void animateToTarget(double target) {
      if (!_scrollController.hasClients) return;
      final max = _scrollController.position.maxScrollExtent;
      final clamped = target.clamp(0.0, max);
      final current = _scrollController.offset;
      final delta = (clamped - current).abs();
      if (delta < 2.0) return;
      // Ease-out: faster when far (longer duration), gentle finish; short when already close.
      final ms =
          (260 + math.sqrt(delta) * 14).round().clamp(260, 1100);
      _scrollController.animateTo(
        clamped,
        duration: Duration(milliseconds: ms),
        curve: Curves.easeOutCubic,
      );
    }

    double? target = _pinnedSearchScrollOffset;
    if (target == null) {
      _cachePinnedSearchScrollOffset();
      target = _pinnedSearchScrollOffset;
    }
    if (target != null) {
      animateToTarget(target);
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _cachePinnedSearchScrollOffset();
      final t = _pinnedSearchScrollOffset;
      if (t != null) animateToTarget(t);
    });
  }

  @override
  void initState() {
    super.initState();
    _searchController =
        TextEditingController(text: ref.read(searchQueryProvider));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _cachePinnedSearchScrollOffset();
    });
    _tabIndexSub = ref.listenManual<int>(
      selectedIndexProvider,
      (previous, next) {
        if (previous == next || next != 0) return;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          unawaited(_reloadVenuesAndScroll());
        });
      },
    );
  }

  @override
  void dispose() {
    _tabIndexSub?.close();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final paginatedState = ref.watch(async_providers.paginatedVenuesProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    final categories = [
      {'key': 'all', 'label': l10n.allCategories, 'icon': Icons.apps},
      {'key': 'football', 'label': l10n.football, 'icon': Icons.sports_soccer},
      {
        'key': 'basketball',
        'label': l10n.basketball,
        'icon': Icons.sports_basketball
      },
      {'key': 'tennis', 'label': l10n.tennis, 'icon': Icons.sports_tennis},
      {'key': 'swimming', 'label': l10n.swimming, 'icon': Icons.pool},
      {'key': 'gym', 'label': l10n.gym, 'icon': Icons.fitness_center},
      {
        'key': 'volleyball',
        'label': l10n.volleyball,
        'icon': Icons.sports_volleyball
      },
      {
        'key': 'badminton',
        'label': l10n.badminton,
        'icon': Icons.sports_tennis
      },
      {
        'key': 'tabletennis',
        'label': l10n.tabletennis,
        'icon': Icons.sports_cricket
      },
    ];

    return Scaffold(
      body: SafeArea(
        top: false,
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification.metrics.pixels >=
                notification.metrics.maxScrollExtent - 400) {
              final state = ref.read(async_providers.paginatedVenuesProvider);
              if (state.hasMore && !state.isLoadingMore) {
                ref
                    .read(async_providers.paginatedVenuesProvider.notifier)
                    .loadNextPage();
              }
            }
            return false;
          },
          child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // ── Above search: title + quick access (used to scroll offset for pinned bar) ──
            SliverToBoxAdapter(
              child: Column(
                key: _contentAboveSearchKey,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const MarketplaceTitleHeader(title: 'ZhamSpace'),
                  _QuickAccessSection(
                    isDark: isDark,
                    l10n: l10n,
                    onTabSelected: (index) =>
                        ref.read(selectedIndexProvider.notifier).state = index,
                  ),
                ],
              ),
            ),

            // ── Sticky Search Bar (scrolls with content, then pins at top) ──
            SliverPersistentHeader(
              pinned: true,
              delegate: _StickySearchBarDelegate(
                topPadding: MediaQuery.of(context).padding.top,
                isDark: isDark,
                l10n: l10n,
                searchController: _searchController,
                onSearchSubmitted: (value) {
                  FocusManager.instance.primaryFocus?.unfocus();
                  ref.read(searchQueryProvider.notifier).state = value.trim();
                  unawaited(_reloadVenuesAndScroll());
                },
                onClearSearch: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  _searchController.clear();
                  ref.read(searchQueryProvider.notifier).state = '';
                  unawaited(_reloadVenuesAndScroll());
                },
              ),
            ),

            // ── Category Chips ──
            SliverToBoxAdapter(
              child: SizedBox(
                height: 52,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final cat = categories[i];
                    final key = cat['key'] as String;
                    final sel = selectedCategory == key;
                    return FilterChip(
                      selected: sel,
                      showCheckmark: false,
                      avatar: Icon(cat['icon'] as IconData,
                          size: 16,
                          color: sel ? Colors.white : AppColors.colorMain),
                      label: Text(cat['label'] as String),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: sel
                            ? Colors.white
                            : (isDark ? Colors.white70 : Colors.grey[800]),
                      ),
                      backgroundColor: isDark
                          ? Colors.white.withOpacity(0.08)
                          : Colors.grey[100],
                      selectedColor: AppColors.colorMain,
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      onSelected: (selected) {
                        if (!selected) return;
                        ref.read(selectedCategoryProvider.notifier).state = key;
                        unawaited(_reloadVenuesAndScroll());
                      },
                    );
                  },
                ),
              ),
            ),

            // ── Refresh in progress (keeps list slivers mounted so scroll does not jump) ──
            if (paginatedState.isRefreshing)
              SliverToBoxAdapter(
                child: LinearProgressIndicator(
                  minHeight: 3,
                  backgroundColor: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.grey.shade200,
                  color: AppColors.colorMain,
                ),
              ),

            // ── Dynamic content from API (`/venues`) with pagination ──
            if (paginatedState.isLoadingInitial &&
                paginatedState.items.isEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(top: 80),
                  child: Center(child: CircularProgressIndicator()),
                ),
              )
            else if (paginatedState.error != null &&
                paginatedState.items.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 40, color: Colors.redAccent),
                      const SizedBox(height: 12),
                      Text(
                        'Failed to load venues',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        paginatedState.error!,
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                              color: isDark
                                  ? Colors.grey[500]
                                  : Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Builder(
                builder: (context) {
                  final venues = paginatedState.items;
                  // Keeps scroll extent ≥ ~1 viewport so scroll-to-pinned search works with few results.
                  final bottomScrollSpace = MediaQuery.sizeOf(context).height;

                  return SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      // ── Popular Section (carousel) — disabled for now ──
                      // final popularVenues = [...venues]..sort(
                      //   (a, b) => b.rating.compareTo(a.rating),
                      // );
                      // final topPopular = popularVenues.take(4).toList();
                      // ... Padding popularVenues header + horizontal ListView ...

                      // ── Near you (main list) ──
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(20, 20, 20, 0),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text(l10n.nearYou,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                        fontWeight:
                                            FontWeight.w800)),
                            TextButton(
                              onPressed: () {},
                              child: Text(
                                l10n.seeAll,
                                style: const TextStyle(
                                  color: AppColors.colorMain,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ── All Venues List ──
                      if (venues.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(40),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 48,
                                  color: isDark
                                      ? Colors.grey[700]
                                      : Colors.grey[300],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  l10n.noFavorites,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        color: isDark
                                            ? Colors.grey[500]
                                            : Colors.grey[500],
                                      ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                              20, 8, 20, 100),
                          child: Column(
                            children: [
                              for (final venue in venues)
                                Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 14),
                                  child: VenueCard(
                                    venue: venue,
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            VenueDetailPage(
                                          venueId: venue.id,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              if (paginatedState.isLoadingMore)
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 16),
                                  child: Center(
                                    child:
                                        CircularProgressIndicator(),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      SizedBox(height: bottomScrollSpace),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    ),);
  }
}

// ── Quick Access Section: 2x2 large cards + 4 small icon items ──
class _QuickAccessSection extends StatelessWidget {
  final bool isDark;
  final AppLocalizations l10n;
  final void Function(int) onTabSelected;

  const _QuickAccessSection({
    required this.isDark,
    required this.l10n,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    const horizontalPadding = 20.0;
    const spacing = 8.0;
    const rowHeight = 70.0; // Compact rectangular cards
    const totalHeight = rowHeight * 2 + spacing;
    final screenBg = isDark ? const Color(0xFF0F1923) : Colors.white;

    return Container(
      color: screenBg,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(horizontalPadding, 0, horizontalPadding, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
          // Custom layout: left 65% (2 rows) | right 35% (full height)
          SizedBox(
            height: totalHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left column: 65%, two stacked cards
                Expanded(
                  flex: 60,
                  child: Column(
                    children: [
                      Expanded(
                        child: _QuickCard(
                          label: l10n.reserveOrBook,
                          icon: Icons.event_available_rounded,
                          onTap: () {},
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(height: spacing),
                      Expanded(
                        child: _QuickCard(
                          label: l10n.newFacilities,
                          icon: Icons.add_business_rounded,
                          onTap: () {},
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: spacing),
                // Right column: 35%, single full-height card
                Expanded(
                  flex: 40,
                  child: _QuickCard(
                    label: l10n.sessions,
                    icon: Icons.groups_rounded,
                    onTap: () => onTabSelected(2),
                    isDark: isDark,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // 4 small icon items in a row
          Row(
            children: [
              Expanded(
                child: _QuickIconItem(
                  label: l10n.news,
                  icon: Icons.campaign_rounded,
                  onTap: () => _showPlaceholder(context, l10n.news),
                  isDark: isDark,
                ),
              ),
              Expanded(
                child: _QuickIconItem(
                  label: l10n.promo,
                  icon: Icons.local_offer_rounded,
                  onTap: () => _showPlaceholder(context, l10n.promo),
                  isDark: isDark,
                ),
              ),
              Expanded(
                child: _QuickIconItem(
                  label: l10n.placeYourFacility,
                  icon: Icons.store_rounded,
                  onTap: () => _showPlaceholder(context, l10n.placeYourFacility),
                  isDark: isDark,
                ),
              ),
              Expanded(
                child: _QuickIconItem(
                  label: l10n.guide,
                  icon: Icons.help_outline_rounded,
                  onTap: () => _showPlaceholder(context, l10n.guide),
                  isDark: isDark,
                ),
              ),
            ],
          ),
          ],
        ),
      ),
    );
  }

  void _showPlaceholder(BuildContext context, String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(label),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _QuickCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool? isDark;

  const _QuickCard({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final dark = isDark ?? Theme.of(context).brightness == Brightness.dark;
    final bgColor = dark
        ? AppColors.darkSurface
        : const Color(0xFFF5F7FA);
    final textColor = dark ? Colors.white : Colors.grey.shade800;
    const iconColor = AppColors.colorMain;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Container(
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                if (!dark)
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
              ],
            ),
            child: Stack(
              children: [
                // ── Background icon: large, clipped, bottom-right ──
                Positioned(
                  right: -14,
                  bottom: -14,
                  child: Icon(
                    icon,
                    size: 80,
                    color: iconColor.withValues(alpha: dark ? 0.3 : 0.5),
                  ),
                ),
                // ── Foreground content ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickIconItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool? isDark;

  const _QuickIconItem({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final dark = isDark ?? Theme.of(context).brightness == Brightness.dark;
    final bgColor = dark
        ? AppColors.darkSurface
        : const Color(0xFFF5F7FA);
    final textColor = dark ? Colors.white70 : Colors.grey.shade700;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: AppColors.colorMain,
                  size: 24,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Sticky search bar delegate: scrolls smoothly with content, pins at top ──
class _StickySearchBarDelegate extends SliverPersistentHeaderDelegate {
  final double topPadding;
  final bool isDark;
  final AppLocalizations l10n;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchSubmitted;
  final VoidCallback onClearSearch;

  static const double _searchBarHeight = 56;
  static const double _verticalPadding = 12;
  static const double _horizontalPadding = 20;

  _StickySearchBarDelegate({
    required this.topPadding,
    required this.isDark,
    required this.l10n,
    required this.searchController,
    required this.onSearchSubmitted,
    required this.onClearSearch,
  });

  @override
  double get minExtent => topPadding + _searchBarHeight + _verticalPadding;

  @override
  double get maxExtent => minExtent;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final progress = (shrinkOffset / minExtent).clamp(0.0, 1.0);
    final shadowOpacity = Curves.easeOutCubic.transform(progress) * 0.06;
    final extent = minExtent;

    return SizedBox(
      height: extent,
      child: Material(
        color: isDark ? const Color(0xFF0F1923) : Colors.white,
        elevation: 0,
        child: Container(
          padding: EdgeInsets.only(
            top: topPadding,
            left: _horizontalPadding,
            right: _horizontalPadding,
            bottom: _verticalPadding,
          ),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F1923) : Colors.white,
          boxShadow: [
            if (overlapsContent)
              BoxShadow(
                color: Colors.black.withOpacity(shadowOpacity),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.08)
                : Colors.grey[100],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(Icons.search,
                  color: isDark ? Colors.grey[400] : Colors.grey[500],
                  size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: searchController,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: l10n.searchFacilities,
                    hintStyle: TextStyle(
                        color: isDark ? Colors.grey[500] : Colors.grey[400],
                        fontSize: 14),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    fillColor: Colors.transparent,
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onSubmitted: onSearchSubmitted,
                ),
              ),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: searchController,
                builder: (context, value, _) {
                  if (value.text.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return IconButton(
                    onPressed: onClearSearch,
                    tooltip: 'Clear',
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 36, minHeight: 36),
                    icon: Icon(
                      Icons.close,
                      size: 20,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _StickySearchBarDelegate oldDelegate) {
    return topPadding != oldDelegate.topPadding ||
        isDark != oldDelegate.isDark ||
        l10n != oldDelegate.l10n ||
        searchController != oldDelegate.searchController ||
        onClearSearch != oldDelegate.onClearSearch;
  }
}
