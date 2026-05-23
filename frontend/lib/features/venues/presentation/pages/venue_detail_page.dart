import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/open_2gis.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/venue_model.dart';
import '../../data/models/venue_schedule_result_model.dart';
import '../providers/venue_provider.dart';
import 'booking_page.dart';
import '../../../chats/presentation/pages/chat_detail_page.dart';
const _kFacilityGridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
  crossAxisCount: 2,
  mainAxisSpacing: 12,
  crossAxisSpacing: 12,
  childAspectRatio: 0.72,
);

class VenueDetailPage extends ConsumerStatefulWidget {
  final String venueId;

  const VenueDetailPage({super.key, required this.venueId});

  @override
  ConsumerState<VenueDetailPage> createState() => _VenueDetailPageState();
}

class _VenueDetailPageState extends ConsumerState<VenueDetailPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late PageController _galleryController;
  int _currentImageIndex = 0;

  // Local animation controller for the favorite heart.
  late AnimationController _heartAnimController;
  late Animation<double> _heartScaleAnim;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _galleryController = PageController();
    _heartAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _heartScaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.4), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.4, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(
      parent: _heartAnimController,
      curve: Curves.easeInOut,
    ));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _refreshVenueData();
    });
  }

  @override
  void didUpdateWidget(covariant VenueDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.venueId != widget.venueId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _refreshVenueData();
      });
    }
  }

  void _refreshVenueData() {
    ref.invalidate(venueByIdProvider(widget.venueId));
    ref.invalidate(venueScheduleResultProvider(widget.venueId));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _galleryController.dispose();
    _heartAnimController.dispose();
    super.dispose();
  }

  Future<void> _launchContact(VenueContact c) async {
    Uri? uri;
    if (c.hasPhone) {
      final dial = _normalizePhoneForDial(c.phone!);
      if (dial.isEmpty) return;
      uri = Uri.parse('tel:$dial');
    } else if (c.hasEmail) {
      uri = Uri.parse('mailto:${c.email}');
    } else if (c.hasLink) {
      final raw = c.link!.trim();
      final s = raw.startsWith('http://') || raw.startsWith('https://')
          ? raw
          : 'https://$raw';
      uri = Uri.tryParse(s);
    }
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  static String _normalizePhoneForDial(String raw) {
    final t = raw.trim();
    if (t.isEmpty) return t;
    if (t.startsWith('+')) {
      final rest = t.substring(1).replaceAll(RegExp(r'\D'), '');
      return rest.isEmpty ? '' : '+$rest';
    }
    return t.replaceAll(RegExp(r'\D'), '');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final venueAsync = ref.watch(venueByIdProvider(widget.venueId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return venueAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Text('Failed to load venue: $err'),
        ),
      ),
      data: (venue) {
        if (venue == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Venue not found')),
          );
        }

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // App Bar with Images
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                actions: [
                  _FavoriteButton(
                    venueId: widget.venueId,
                    heartAnimController: _heartAnimController,
                    heartScaleAnim: _heartScaleAnim,
                  ),
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () {},
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Image gallery (gradient below uses IgnorePointer so swipes reach PageView)
                      if (venue.images.isNotEmpty)
                        PageView.builder(
                          controller: _galleryController,
                          itemCount: venue.images.length,
                          onPageChanged: (index) {
                            setState(() {
                              _currentImageIndex = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            return Image.network(
                              venue.images[index],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: isDark
                                      ? Colors.grey[800]
                                      : Colors.grey[300],
                                  child: const Icon(Icons.sports, size: 64),
                                );
                              },
                            );
                          },
                        )
                      else
                        Container(
                          color:
                              isDark ? Colors.grey[800] : Colors.grey[300],
                          child: const Icon(Icons.sports, size: 64),
                        ),

                      // Gradient overlay — must not absorb horizontal drags
                      Positioned.fill(
                        child: IgnorePointer(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.7),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      if (venue.images.length > 1)
                        Positioned(
                          bottom: 16,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              venue.images.length,
                              (index) => Container(
                                width: 8,
                                height: 8,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _currentImageIndex == index
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.4),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Content
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title Section
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  venue.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: venue.isOpen
                                      ? AppColors.colorSuccess
                                      : AppColors.colorError,
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Text(
                                  venue.isOpen ? l10n.openNow : l10n.closed,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Location
                          Row(
                            children: [
                              const Icon(Icons.location_on,
                                  color: AppColors.colorMain, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  venue.address,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium,
                                ),
                              ),
                              TextButton(
                                onPressed: () => open2GIS(venue.addressLine1),
                                child: Text(l10n.getDirections),
                              ),
                            ],
                          ),
                          if (venue.ownerId != null &&
                              venue.ownerId!.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  final loggedIn =
                                      ref.read(isLoggedInProvider);
                                  if (!loggedIn) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Login or register to message the owner.',
                                        ),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                    return;
                                  }
                                  final mySub =
                                      ref.read(authProvider).authUser?.sub;
                                  if (mySub != null &&
                                      mySub == venue.ownerId) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text(
                                          'You cannot message yourself.',
                                        ),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                    return;
                                  }
                                  Navigator.push<void>(
                                    context,
                                    MaterialPageRoute<void>(
                                      builder: (_) => ChatDetailPage(
                                        peerUserId: venue.ownerId,
                                        conversationTitle: venue.name,
                                        peerDisplayName: venue.name,
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.chat_bubble_outline),
                                label: Text(l10n.messageOwner),
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),

                    // Resources section (from schedule-result API)
                    _VenueResourcesSection(
                      venueId: widget.venueId,
                      venue: venue,
                      isDark: isDark,
                      l10n: l10n,
                      onBookResource: (groupId, bookable) {
                        if (!bookable) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.facilityUnavailableNoSchedule),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BookingPage(
                              venue: venue,
                              preselectedResourceId: groupId,
                            ),
                          ),
                        );
                      },
                      onBook: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BookingPage(venue: venue),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 8),

                    // Tabs block - rounded container, no odd space
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[900] : Colors.white,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withValues(alpha: isDark ? 0.3 : 0.06),
                            blurRadius: 12,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TabBar(
                            controller: _tabController,
                            labelColor: AppColors.colorMain,
                            unselectedLabelColor: isDark
                                ? Colors.grey[400]
                                : Colors.grey[600],
                            indicatorColor: AppColors.colorMain,
                            indicatorSize: TabBarIndicatorSize.label,
                            labelPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            isScrollable: true,
                            tabs: [
                              Tab(text: l10n.venueDescriptionTab),
                              Tab(text: l10n.venueContactInfoTab),
                              Tab(text: l10n.availability),
                              Tab(text: l10n.reviewsTitle),
                            ],
                          ),
                          SizedBox(
                            height: 380,
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                _buildDescriptionTab(
                                    context, venue, isDark),
                                _buildContactInfoTab(
                                    context, venue, l10n, isDark),
                                _buildAvailabilityTab(
                                    context, venue, l10n, isDark),
                                _buildReviewsTab(context, l10n, isDark),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookingPage(venue: venue),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  l10n.bookNow,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDescriptionTab(
      BuildContext context, VenueModel venue, bool isDark) {
    final text = venue.description.trim();
    final isEmpty = text.isEmpty;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      child: Text(
        isEmpty ? 'No description' : text,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              height: 1.6,
              color: isEmpty
                  ? (isDark ? Colors.grey[500] : Colors.grey[600])
                  : null,
              fontStyle: isEmpty ? FontStyle.italic : FontStyle.normal,
            ),
      ),
    );
  }

  Widget _buildContactInfoTab(
    BuildContext context,
    VenueModel venue,
    AppLocalizations l10n,
    bool isDark,
  ) {
    if (venue.contacts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            l10n.venueNoContacts,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: isDark ? Colors.grey[500] : Colors.grey[600],
                ),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      itemCount: venue.contacts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final c = venue.contacts[index];
        return _ContactRow(
          contact: c,
          l10n: l10n,
          isDark: isDark,
          onOpen: () => _launchContact(c),
        );
      },
    );
  }

  Widget _buildAvailabilityTab(
      BuildContext context, venue, AppLocalizations l10n, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.selectDate,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[850] : Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Text(
                  'Book your preferred time slot',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BookingPage(venue: venue),
                      ),
                    );
                  },
                  icon: const Icon(Icons.calendar_today),
                  label: Text(l10n.bookNow),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsTab(
      BuildContext context, AppLocalizations l10n, bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.colorMain,
                        child: Text(
                          ['J', 'A', 'M', 'S', 'D'][index],
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ['John Doe', 'Anna Smith', 'Mike Johnson', 'Sarah Lee', 'David Kim'][index],
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Row(
                              children: [
                                ...List.generate(5, (i) => Icon(
                                      Icons.star,
                                      size: 16,
                                      color: i < 4 + index % 2 ? Colors.amber : Colors.grey,
                                    )),
                                const SizedBox(width: 8),
                                Text(
                                  '${index + 1} days ago',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                                      ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Great facility with excellent service! Highly recommended for both beginners and professionals.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.5,
                        ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

}

/// Distinct rows for phone / email / URL.
class _ContactRow extends StatelessWidget {
  final VenueContact contact;
  final AppLocalizations l10n;
  final bool isDark;
  final VoidCallback onOpen;

  const _ContactRow({
    required this.contact,
    required this.l10n,
    required this.isDark,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final label = contact.label.isNotEmpty ? contact.label : '—';

    if (contact.hasPhone) {
      return _contactCard(
        context,
        icon: Icons.phone_in_talk_rounded,
        iconBg: const Color(0xFF0D9488),
        title: label,
        value: contact.phone!,
        hint: l10n.call,
      );
    }
    if (contact.hasEmail) {
      return _contactCard(
        context,
        icon: Icons.alternate_email_rounded,
        iconBg: const Color(0xFF2563EB),
        title: label,
        value: contact.email!,
        hint: l10n.email,
      );
    }
    if (contact.hasLink) {
      return _contactCard(
        context,
        icon: Icons.link_rounded,
        iconBg: const Color(0xFFD97706),
        title: label,
        value: contact.link!,
        hint: null,
      );
    }
    return const SizedBox.shrink();
  }

  Widget _contactCard(
    BuildContext context, {
    required IconData icon,
    required Color iconBg,
    required String title,
    required String value,
    String? hint,
  }) {
    return Material(
      color: isDark ? Colors.grey[850] : Colors.grey[100],
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBg.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconBg, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      value,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.colorMain,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    if (hint != null && hint.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        hint,
                        style:
                            Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: isDark
                                      ? Colors.grey[500]
                                      : Colors.grey[600],
                                ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.open_in_new_rounded,
                size: 18,
                color: isDark ? Colors.grey[500] : Colors.grey[600],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _capitalizeFacilityLabel(String? s) {
  if (s == null || s.trim().isEmpty) return '—';
  final t = s.trim();
  if (t.length == 1) return t.toUpperCase();
  return '${t[0].toUpperCase()}${t.substring(1).toLowerCase()}';
}

class _FacilityCard extends StatelessWidget {
  final ScheduleResultGroup group;
  final AppLocalizations l10n;
  final bool isDark;
  final VoidCallback onOpen;

  const _FacilityCard({
    required this.group,
    required this.l10n,
    required this.isDark,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final resource = group.resource;
    final name = resource?.displayName ?? group.resourceId ?? '—';
    final imageUrl =
        (resource?.images.isNotEmpty == true) ? resource!.images.first : null;
    final sport = _capitalizeFacilityLabel(resource?.sport);
    final type = _capitalizeFacilityLabel(resource?.type);
    final meta = l10n.facilityMetaSportType(sport, type);
    final minPrice = group.minPriceInt;
    final bookable = group.isBookable;
    final surface = isDark ? const Color(0xFF1A1D23) : Colors.white;

    return Material(
      color: surface,
      elevation: isDark ? 0 : 2,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (imageUrl != null)
                    Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _facilityImageFallback(isDark),
                    )
                  else
                    _facilityImageFallback(isDark),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.72),
                          ],
                          stops: const [0.35, 1],
                        ),
                      ),
                    ),
                  ),
                  if (!bookable)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.do_not_disturb_on_rounded,
                              size: 14,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              l10n.unavailable,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  Positioned(
                    left: 10,
                    right: 10,
                    bottom: 10,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            height: 1.2,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          meta,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.88),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (minPrice != null)
                    Text(
                      '${l10n.fromPrice(minPrice.toString())} · ${l10n.perHour}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isDark ? Colors.grey[400] : Colors.grey[700],
                            fontWeight: FontWeight.w600,
                          ),
                    )
                  else
                    Text(
                      l10n.facilityUnavailableHint,
                      maxLines: 2,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isDark ? Colors.grey[500] : Colors.grey[600],
                            fontSize: 11,
                          ),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        bookable
                            ? Icons.event_available_rounded
                            : Icons.block_rounded,
                        size: 16,
                        color: bookable
                            ? AppColors.colorMain
                            : (isDark ? Colors.grey[500] : Colors.grey[500]),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          bookable ? l10n.bookNow : l10n.facilityUnavailableNoSchedule,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: bookable
                                ? AppColors.colorMain
                                : (isDark ? Colors.grey[500] : Colors.grey[600]),
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: isDark ? Colors.grey[600] : Colors.grey[400],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _facilityImageFallback(bool isDark) {
    return Container(
      color: isDark ? const Color(0xFF2A2F38) : const Color(0xFFE8ECF0),
      child: Icon(
        Icons.sports_martial_arts_rounded,
        size: 40,
        color: AppColors.colorMain.withValues(alpha: 0.35),
      ),
    );
  }
}

/// Skeleton card: same geometry as [_FacilityCard] / [_kFacilityGridDelegate].
class _FacilitySkeletonCard extends StatelessWidget {
  final Animation<double> shimmer;
  final bool isDark;

  const _FacilitySkeletonCard({
    required this.shimmer,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDark ? const Color(0xFF1A1D23) : Colors.white,
      elevation: isDark ? 0 : 2,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _ShimmerPanel(shimmer: shimmer, isDark: isDark)),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ShimmerLine(
                  shimmer: shimmer,
                  isDark: isDark,
                  height: 12,
                  widthFraction: 0.92,
                ),
                const SizedBox(height: 8),
                _ShimmerLine(
                  shimmer: shimmer,
                  isDark: isDark,
                  height: 10,
                  widthFraction: 0.55,
                ),
                const SizedBox(height: 10),
                _ShimmerLine(
                  shimmer: shimmer,
                  isDark: isDark,
                  height: 13,
                  widthFraction: 0.78,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ShimmerPanel extends StatelessWidget {
  final Animation<double> shimmer;
  final bool isDark;

  const _ShimmerPanel({required this.shimmer, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final base = isDark ? const Color(0xFF2A2F38) : const Color(0xFFE4E7EC);
    final glow = isDark ? const Color(0xFF4A505C) : const Color(0xFFF2F4F7);
    return AnimatedBuilder(
      animation: shimmer,
      builder: (context, child) {
        final t = shimmer.value;
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-1.0 + 2.2 * t, 0),
              end: Alignment(0.2 + 2.2 * t, 0),
              colors: [
                base,
                Color.lerp(base, glow, 0.55)!,
                base,
              ],
              stops: const [0.15, 0.5, 0.85],
            ),
          ),
        );
      },
    );
  }
}

class _ShimmerLine extends StatelessWidget {
  final Animation<double> shimmer;
  final bool isDark;
  final double height;
  final double widthFraction;

  const _ShimmerLine({
    required this.shimmer,
    required this.isDark,
    required this.height,
    required this.widthFraction,
  });

  @override
  Widget build(BuildContext context) {
    final base = isDark ? const Color(0xFF3D4350) : const Color(0xFFD0D5DD);
    final mid = isDark ? const Color(0xFF5C6370) : const Color(0xFFEEF1F5);
    return LayoutBuilder(
      builder: (context, cons) {
        final w = cons.maxWidth * widthFraction.clamp(0.0, 1.0);
        return AnimatedBuilder(
          animation: shimmer,
          builder: (context, child) {
            final t = shimmer.value;
            return Container(
              width: w,
              height: height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: LinearGradient(
                  begin: Alignment(-1.0 + 2.0 * t, 0),
                  end: Alignment(0.2 + 2.0 * t, 0),
                  colors: [
                    base,
                    mid,
                    base,
                  ],
                  stops: const [0.2, 0.5, 0.8],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// Resources and pricing from schedule-result API.
class _VenueResourcesSection extends ConsumerStatefulWidget {
  final String venueId;
  final VenueModel venue;
  final bool isDark;
  final AppLocalizations l10n;
  final void Function(String? resourceId, bool bookable) onBookResource;
  final VoidCallback onBook;

  const _VenueResourcesSection({
    required this.venueId,
    required this.venue,
    required this.isDark,
    required this.l10n,
    required this.onBookResource,
    required this.onBook,
  });

  @override
  ConsumerState<_VenueResourcesSection> createState() =>
      _VenueResourcesSectionState();
}

class _VenueResourcesSectionState extends ConsumerState<_VenueResourcesSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  )..repeat();

  ProviderSubscription<AsyncValue<VenueScheduleResultModel>>? _scheduleSub;

  bool _contentReady = false;
  String? _lastPreloadFingerprint;
  int _preloadGen = 0;

  @override
  void initState() {
    super.initState();
    _scheduleSub = ref.listenManual(
      venueScheduleResultProvider(widget.venueId),
      (prev, next) {
        next.whenData(_onScheduleData);
      },
      fireImmediately: true,
    );
  }

  @override
  void didUpdateWidget(covariant _VenueResourcesSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.venueId != widget.venueId) {
      _scheduleSub?.close();
      setState(() {
        _contentReady = false;
        _lastPreloadFingerprint = null;
        _preloadGen = 0;
      });
      _scheduleSub = ref.listenManual(
        venueScheduleResultProvider(widget.venueId),
        (prev, next) {
          next.whenData(_onScheduleData);
        },
        fireImmediately: true,
      );
    }
  }

  @override
  void dispose() {
    _scheduleSub?.close();
    _shimmerController.dispose();
    super.dispose();
  }

  String _preloadFingerprint(VenueScheduleResultModel sr) {
    final parts = <String>[];
    for (final g in sr.groups) {
      for (final u in g.resource?.images ?? const <String>[]) {
        final t = u.trim();
        if (t.isNotEmpty) parts.add(t);
      }
    }
    parts.sort();
    return '${sr.venueId}|${parts.join('\u0001')}';
  }

  Future<void> _preload(VenueScheduleResultModel sr) async {
    final gen = ++_preloadGen;
    final urls = <String>{};
    for (final g in sr.groups) {
      for (final u in g.resource?.images ?? const <String>[]) {
        final t = u.trim();
        if (t.isNotEmpty) urls.add(t);
      }
    }
    if (urls.isEmpty) {
      if (mounted && gen == _preloadGen) {
        setState(() => _contentReady = true);
      }
      return;
    }
    final ctx = context;
    await Future.wait(
      urls.map((u) async {
        try {
          await precacheImage(NetworkImage(u), ctx);
        } catch (_) {}
      }),
    );
    if (mounted && gen == _preloadGen) {
      setState(() => _contentReady = true);
    }
  }

  void _onScheduleData(VenueScheduleResultModel sr) {
    final fg = _preloadFingerprint(sr);
    if (fg == _lastPreloadFingerprint && _contentReady) return;
    _lastPreloadFingerprint = fg;
    if (sr.groups.isEmpty) {
      setState(() => _contentReady = true);
      return;
    }
    setState(() => _contentReady = false);
    unawaited(_preload(sr));
  }

  Widget _facilitiesHeader(BuildContext context, {required bool shimmer}) {
    if (shimmer) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ShimmerLine(
            shimmer: _shimmerController,
            isDark: widget.isDark,
            height: 20,
            widthFraction: 0.42,
          ),
          const SizedBox(height: 12),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.l10n.facilities,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheduleAsync = ref.watch(venueScheduleResultProvider(widget.venueId));

    return scheduleAsync.when(
      loading: () => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _facilitiesHeader(context, shimmer: true),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: _kFacilityGridDelegate,
              itemCount: 2,
              itemBuilder: (context, index) {
                return _FacilitySkeletonCard(
                  shimmer: _shimmerController,
                  isDark: widget.isDark,
                );
              },
            ),
          ],
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (scheduleResult) {
        final groups = scheduleResult.groups;
        if (groups.isEmpty) return const SizedBox.shrink();
        if (!_contentReady) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _facilitiesHeader(context, shimmer: true),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: _kFacilityGridDelegate,
                  itemCount: groups.length,
                  itemBuilder: (context, index) {
                    return _FacilitySkeletonCard(
                      shimmer: _shimmerController,
                      isDark: widget.isDark,
                    );
                  },
                ),
              ],
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _facilitiesHeader(context, shimmer: false),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: _kFacilityGridDelegate,
                itemCount: groups.length,
                itemBuilder: (context, index) {
                  final g = groups[index];
                  return _FacilityCard(
                    group: g,
                    l10n: widget.l10n,
                    isDark: widget.isDark,
                    onOpen: () {
                      final id = g.resource?.id ?? g.resourceId;
                      widget.onBookResource(id, g.isBookable);
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Animated favorite heart button for the app bar
// ---------------------------------------------------------------------------

class _FavoriteButton extends ConsumerWidget {
  final String venueId;
  final AnimationController heartAnimController;
  final Animation<double> heartScaleAnim;

  const _FavoriteButton({
    required this.venueId,
    required this.heartAnimController,
    required this.heartScaleAnim,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFav = ref.watch(favoriteIdsProvider).contains(venueId);

    return IconButton(
      icon: ScaleTransition(
        scale: heartScaleAnim,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, anim) =>
              ScaleTransition(scale: anim, child: child),
          child: Icon(
            isFav ? Icons.favorite : Icons.favorite_border,
            key: ValueKey(isFav),
            color: isFav ? Colors.redAccent : Colors.white,
          ),
        ),
      ),
      onPressed: () async {
        heartAnimController.forward(from: 0);
        await ref.read(favoriteIdsProvider.notifier).toggle(venueId);
      },
    );
  }
}
