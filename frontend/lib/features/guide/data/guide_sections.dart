import 'package:flutter/material.dart';

enum GuideSectionId {
  gettingStarted,
  booking,
  sessions,
  payments,
  profile,
  owners,
  support,
}

class GuideSection {
  final GuideSectionId id;
  final IconData icon;
  final Color accentColor;

  const GuideSection({
    required this.id,
    required this.icon,
    required this.accentColor,
  });
}

const guideSections = <GuideSection>[
  GuideSection(
    id: GuideSectionId.gettingStarted,
    icon: Icons.explore_rounded,
    accentColor: Color(0xFF00BFA5),
  ),
  GuideSection(
    id: GuideSectionId.booking,
    icon: Icons.event_available_rounded,
    accentColor: Color(0xFF2196F3),
  ),
  GuideSection(
    id: GuideSectionId.sessions,
    icon: Icons.groups_rounded,
    accentColor: Color(0xFFFF9800),
  ),
  GuideSection(
    id: GuideSectionId.payments,
    icon: Icons.payment_rounded,
    accentColor: Color(0xFF9C27B0),
  ),
  GuideSection(
    id: GuideSectionId.profile,
    icon: Icons.person_rounded,
    accentColor: Color(0xFF43A047),
  ),
  GuideSection(
    id: GuideSectionId.owners,
    icon: Icons.store_rounded,
    accentColor: Color(0xFF1B5E4B),
  ),
  GuideSection(
    id: GuideSectionId.support,
    icon: Icons.support_agent_rounded,
    accentColor: Color(0xFFE53935),
  ),
];
