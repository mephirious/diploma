import 'package:flutter/material.dart';

/// Simple bold black title for secondary screens (Bookings, Sessions, Chats).
/// Clean, production-ready marketplace style.
class PageTitleHeader extends StatelessWidget {
  final String title;
  final EdgeInsets? padding;

  const PageTitleHeader({
    super.key,
    required this.title,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F1419);

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: padding ?? const EdgeInsets.fromLTRB(24, 12, 24, 16),
        child: Text(
          title,
          style: TextStyle(
            color: textColor,
            fontSize: 26,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.6,
            height: 1.15,
          ),
        ),
      ),
    );
  }
}

/// Premium marketplace title with green gradient and metallic reflection.
/// Large, bold, production-level hero branding.
class MarketplaceTitleHeader extends StatelessWidget {
  final String title;
  final String? tagline;
  final Widget? trailing;
  final EdgeInsets? padding;

  const MarketplaceTitleHeader({
    super.key,
    required this.title,
    this.tagline,
    this.trailing,
    this.padding,
  });

  static const _premiumGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color.fromARGB(255, 32, 107, 61),  // Shadow / depth
      Color.fromARGB(255, 49, 109, 83),  // Deep forest
      Color.fromARGB(255, 52, 129, 94),  // Rich emerald body
      Color(0xFF52B788),  // Mid-tone
      Color(0xFF74C69D),  // Metallic reflection streak
      Color(0xFF95D5B2),  // Bright highlight
      Color.fromARGB(255, 175, 206, 179),  // Clean metal peak shine
    ],
    stops: [0.0, 0.15, 0.35, 0.5, 0.65, 0.82, 1.0],
  );

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final resolvedPadding = padding ??
        EdgeInsets.fromLTRB(24, topPadding + 20, 24, 24);

    return Container(
      padding: resolvedPadding,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F1923) : Colors.white,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Premium gradient title with metallic effect
                ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (bounds) => _premiumGradient.createShader(bounds),
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.2,
                      height: 1.05,
                      shadows: [
                        Shadow(
                          color: Color(0x20000000),
                          offset: Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
                if (tagline != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    tagline!,
                    style: TextStyle(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.6)
                          : Colors.black.withValues(alpha: 0.5),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 16),
            trailing!,
          ],
        ],
      ),
    );
  }
}
