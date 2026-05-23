import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../theme/app_colors.dart';

// ─── Liquid Glass icon button used in AppBars ───
class LiquidGlassIconButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback? onPressed;
  final EdgeInsets margin;

  const LiquidGlassIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.margin = const EdgeInsets.only(right: 12),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: GlassmorphicContainer(
        width: 40,
        height: 40,
        borderRadius: 20,
        blur: 10,
        alignment: Alignment.center,
        border: 0.8,
        linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.18),
            Colors.white.withOpacity(0.06),
          ],
        ),
        borderGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.35),
            Colors.white.withOpacity(0.1),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onPressed,
            child: Center(child: icon),
          ),
        ),
      ),
    );
  }
}

// ─── Standard AppBar for flat pages (Bookings, Sessions, Chats) ───
class AppMainAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final bool showBackButton;

  const AppMainAppBar({
    super.key,
    required this.title,
    this.actions,
    this.bottom,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient:
            isDark ? AppColors.appBarDarkGradient : AppColors.appBarGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: AppBar(
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 20,
              letterSpacing: -0.3,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          automaticallyImplyLeading: showBackButton,
          iconTheme: const IconThemeData(color: Colors.white),
          actions: actions,
          bottom: bottom,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0),
      );
}

// ─── Sliver version for scrollable screens ───
class SliverAppMainAppBar extends StatelessWidget {
  final String title;
  final List<Widget>? actions;

  const SliverAppMainAppBar({
    super.key,
    required this.title,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SliverAppBar(
      expandedHeight: 90,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 14),
        centerTitle: false,
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: -0.3,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: isDark
                ? AppColors.appBarDarkGradient
                : AppColors.appBarGradient,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
        ),
      ),
      actions: actions,
    );
  }
}
