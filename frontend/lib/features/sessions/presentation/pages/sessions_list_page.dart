import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/page_title_header.dart';
import '../providers/sessions_provider.dart';
import '../widgets/session_card.dart';

class SessionsPage extends ConsumerWidget {
  const SessionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filteredSessions = ref.watch(filteredSessionsProvider);
    final selectedSport = ref.watch(selectedSportFilterProvider);
    final selectedTime = ref.watch(selectedTimeFilterProvider);
    final selectedSkill = ref.watch(selectedSkillFilterProvider);

    final sportCategories = [
      {'key': 'all', 'label': l10n.allCategories, 'icon': Icons.apps},
      {'key': 'football', 'label': l10n.football, 'icon': Icons.sports_soccer},
      {
        'key': 'basketball',
        'label': l10n.basketball,
        'icon': Icons.sports_basketball,
      },
      {'key': 'tennis', 'label': l10n.tennis, 'icon': Icons.sports_tennis},
      {
        'key': 'volleyball',
        'label': l10n.volleyball,
        'icon': Icons.sports_volleyball
      },
      {'key': 'swimming', 'label': l10n.swimming, 'icon': Icons.pool},
      {'key': 'gym', 'label': l10n.gym, 'icon': Icons.fitness_center},
      {
        'key': 'badminton',
        'label': l10n.badminton,
        'icon': Icons.sports_tennis
      },
    ];

    return Scaffold(
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: PageTitleHeader(title: l10n.sessions),
            ),
            // ── Time filters ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _TimeFilterChip(
                        label: l10n.now,
                      icon: Icons.circle,
                      iconSize: 8,
                      isSelected: selectedTime == 'now',
                      isLive: true,
                        onTap: () => ref
                            .read(selectedTimeFilterProvider.notifier)
                            .state = 'now',
                      ),
                    const SizedBox(width: 8),
                    _TimeFilterChip(
                      label: l10n.today,
                      icon: Icons.today,
                      isSelected: selectedTime == 'today',
                      onTap: () => ref
                          .read(selectedTimeFilterProvider.notifier)
                          .state = 'today',
                    ),
                    const SizedBox(width: 8),
                    _TimeFilterChip(
                      label: l10n.pickDate,
                      icon: Icons.calendar_month,
                      isSelected: selectedTime == 'date',
                      onTap: () => ref
                          .read(selectedTimeFilterProvider.notifier)
                          .state = 'date',
                    ),
                    const SizedBox(width: 12),
                    // Skill level dropdown
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(0.08)
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withOpacity(0.12)
                              : Colors.grey[300]!,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedSkill,
                          isDense: true,
                          icon: Icon(
                            Icons.keyboard_arrow_down,
                            size: 18,
                            color: isDark ? Colors.white70 : Colors.grey[700],
                          ),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                          items: [
                            DropdownMenuItem(
                                value: 'all', child: Text(l10n.allLevels)),
                            DropdownMenuItem(
                                value: 'beginner', child: Text(l10n.beginner)),
                            DropdownMenuItem(
                                value: 'intermediate',
                                child: Text(l10n.intermediate)),
                            DropdownMenuItem(
                                value: 'advanced', child: Text(l10n.advanced)),
                          ],
                          onChanged: (v) {
                            if (v != null) {
                              ref
                                  .read(selectedSkillFilterProvider.notifier)
                                  .state = v;
                            }
                          },
                        ),
                      ),
                    ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Sport category chips ──
            SliverToBoxAdapter(
              child: SizedBox(
                height: 52,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  scrollDirection: Axis.horizontal,
                  itemCount: sportCategories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final cat = sportCategories[index];
                    final key = cat['key'] as String;
                    final isSelected = selectedSport == key;

                    return FilterChip(
                      selected: isSelected,
                      showCheckmark: false,
                      avatar: Icon(
                        cat['icon'] as IconData,
                        size: 16,
                        color: isSelected ? Colors.white : AppColors.colorMain,
                      ),
                      label: Text(cat['label'] as String),
                      labelStyle: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : (isDark ? Colors.white70 : Colors.grey[800]),
                      ),
                      backgroundColor: isDark
                          ? Colors.white.withOpacity(0.08)
                          : Colors.grey[100],
                      selectedColor: AppColors.colorMain,
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      onSelected: (_) {
                        ref.read(selectedSportFilterProvider.notifier).state =
                            key;
                      },
                    );
                  },
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // ── Session cards ──
            if (filteredSessions.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.sports_outlined,
                        size: 64,
                        color: isDark ? Colors.grey[700] : Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.noSessions,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.findSessions,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color:
                                  isDark ? Colors.grey[500] : Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: SessionCard(
                          session: filteredSessions[index],
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => _SessionDetailInline(
                                  sessionId: filteredSessions[index].id,
                                ),
                              ),
                            );
                          },
                          onJoin: () {
                            ref.read(sessionsProvider.notifier).joinSession(
                                  filteredSessions[index].id,
                                );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.joinedSuccessfully),
                                backgroundColor: AppColors.colorSuccess,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                    childCount: filteredSessions.length,
                  ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }
}

// ── Time Filter Chip ──
class _TimeFilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final double iconSize;
  final bool isSelected;
  final bool isLive;
  final VoidCallback onTap;

  const _TimeFilterChip({
    required this.label,
    required this.icon,
    this.iconSize = 16,
    required this.isSelected,
    this.isLive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.colorMain
              : (isDark ? Colors.white.withOpacity(0.08) : Colors.grey[100]),
          borderRadius: BorderRadius.circular(24),
          border: isSelected
              ? null
              : Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.12)
                      : Colors.grey[300]!,
                ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLive && isSelected)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(right: 6),
                decoration: const BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
              )
            else
              Icon(
                icon,
                size: iconSize,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white70 : Colors.grey[700]),
              ),
            if (iconSize >= 16) const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white70 : Colors.grey[800]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Inline Session Detail (accessed from list) ──
class _SessionDetailInline extends ConsumerWidget {
  final String sessionId;

  const _SessionDetailInline({required this.sessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sessions = ref.watch(sessionsProvider);
    final session = sessions.firstWhere(
      (s) => s.id == sessionId,
      orElse: () => sessions.first,
    );

    String skillLabel(String level) {
      switch (level) {
        case 'beginner':
          return l10n.beginner;
        case 'intermediate':
          return l10n.intermediate;
        case 'advanced':
          return l10n.advanced;
        default:
          return level;
      }
    }

    Color skillColor(String level) {
      switch (level) {
        case 'beginner':
          return Colors.green;
        case 'intermediate':
          return Colors.orange;
        case 'advanced':
          return Colors.redAccent;
        default:
          return AppColors.colorMain;
      }
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    session.venueImage,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.colorMain.withOpacity(0.3),
                      child: const Icon(Icons.sports,
                          size: 64, color: Colors.white),
                    ),
                  ),
                  Container(
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
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (session.isLive)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  l10n.live,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        Text(
                          session.venueName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sport & Skill
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.colorMain.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          session.sportType.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.colorMain,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color:
                              skillColor(session.skillLevel).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          skillLabel(session.skillLevel),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: skillColor(session.skillLevel),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Location
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: 18,
                          color: isDark ? Colors.grey[400] : Colors.grey[600]),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          session.venueAddress,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                                  ),
                        ),
                      ),
                      Text(
                        l10n.kmAway(session.distance.toStringAsFixed(1)),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.colorMain,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Description
                  Text(
                    session.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.5,
                        ),
                  ),
                  const SizedBox(height: 24),

                  // Details card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.06)
                          : Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withOpacity(0.1)
                            : Colors.grey[200]!,
                      ),
                    ),
                    child: Column(
                      children: [
                        _DetailRow(
                          icon: Icons.person_outline,
                          label: l10n.host,
                          value: session.hostName,
                        ),
                        const Divider(height: 20),
                        _DetailRow(
                          icon: Icons.group_outlined,
                          label: l10n.participants,
                          value: l10n.playersCount(
                              session.currentPlayers, session.maxPlayers),
                        ),
                        const Divider(height: 20),
                        _DetailRow(
                          icon: Icons.attach_money,
                          label: l10n.pricePerPerson,
                          value: '${session.pricePerPlayer.toInt()} ₸',
                        ),
                        const Divider(height: 20),
                        _DetailRow(
                          icon: Icons.access_time,
                          label: l10n.time,
                          value: session.timeSlots.join(' – '),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Time Slots
                  Text(
                    l10n.selectTime,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: session.timeSlots.map((slot) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.colorMain.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: AppColors.colorMain.withOpacity(0.3)),
                        ),
                        child: Text(
                          slot,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.colorMain,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Spots left indicator
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: session.isFull
                          ? Colors.red.withOpacity(0.1)
                          : AppColors.colorSuccess.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          session.isFull
                              ? Icons.block
                              : Icons.check_circle_outline,
                          color: session.isFull
                              ? Colors.red
                              : AppColors.colorSuccess,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.spotsAvailable,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                l10n.spotsLeft(session.spotsLeft),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Player progress
                        SizedBox(
                          width: 60,
                          height: 60,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CircularProgressIndicator(
                                value:
                                    session.currentPlayers / session.maxPlayers,
                                backgroundColor: isDark
                                    ? Colors.grey[800]
                                    : Colors.grey[200],
                                valueColor: AlwaysStoppedAnimation(
                                  session.isFull
                                      ? Colors.red
                                      : AppColors.colorSuccess,
                                ),
                                strokeWidth: 5,
                              ),
                              Text(
                                l10n.playersCount(
                                    session.currentPlayers, session.maxPlayers),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ElevatedButton(
            onPressed: session.isFull
                ? null
                : () {
                    ref.read(sessionsProvider.notifier).joinSession(session.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.joinedSuccessfully),
                        backgroundColor: AppColors.colorSuccess,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.colorMain,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: Text(
              l10n.joinSession,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.colorMain),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
