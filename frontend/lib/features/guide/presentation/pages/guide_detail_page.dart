import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/guide_sections.dart';

class GuideDetailPage extends StatelessWidget {
  final GuideSectionId sectionId;

  const GuideDetailPage({super.key, required this.sectionId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0D1117) : const Color(0xFFF6F8FB);
    final section = guideSections.firstWhere((s) => s.id == sectionId);

    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(
        slivers: [
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
              _titleForSection(l10n, sectionId),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF0D1117),
              ),
            ),
            centerTitle: true,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: section.accentColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: section.accentColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            section.icon,
                            color: section.accentColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            _subtitleForSection(l10n, sectionId),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? Colors.white70
                                  : const Color(0xFF4A5568),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.06)
                            : Colors.black.withValues(alpha: 0.05),
                      ),
                    ),
                    child: Text(
                      _contentForSection(l10n, sectionId),
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.6,
                        color: isDark ? Colors.white70 : const Color(0xFF374151),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _titleForSection(AppLocalizations l10n, GuideSectionId id) {
    return switch (id) {
      GuideSectionId.gettingStarted => l10n.guideSectionGettingStarted,
      GuideSectionId.booking => l10n.guideSectionBooking,
      GuideSectionId.sessions => l10n.guideSectionSessions,
      GuideSectionId.payments => l10n.guideSectionPayments,
      GuideSectionId.profile => l10n.guideSectionProfile,
      GuideSectionId.owners => l10n.guideSectionOwners,
      GuideSectionId.support => l10n.guideSectionSupport,
    };
  }

  String _subtitleForSection(AppLocalizations l10n, GuideSectionId id) {
    return switch (id) {
      GuideSectionId.gettingStarted => l10n.guideSectionGettingStartedSubtitle,
      GuideSectionId.booking => l10n.guideSectionBookingSubtitle,
      GuideSectionId.sessions => l10n.guideSectionSessionsSubtitle,
      GuideSectionId.payments => l10n.guideSectionPaymentsSubtitle,
      GuideSectionId.profile => l10n.guideSectionProfileSubtitle,
      GuideSectionId.owners => l10n.guideSectionOwnersSubtitle,
      GuideSectionId.support => l10n.guideSectionSupportSubtitle,
    };
  }

  String _contentForSection(AppLocalizations l10n, GuideSectionId id) {
    return switch (id) {
      GuideSectionId.gettingStarted => l10n.guideContentGettingStarted,
      GuideSectionId.booking => l10n.guideContentBooking,
      GuideSectionId.sessions => l10n.guideContentSessions,
      GuideSectionId.payments => l10n.guideContentPayments,
      GuideSectionId.profile => l10n.guideContentProfile,
      GuideSectionId.owners => l10n.guideContentOwners,
      GuideSectionId.support => l10n.guideContentSupport,
    };
  }
}
