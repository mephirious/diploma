import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../providers/locale_provider.dart';
import '../theme/app_colors.dart';
import '../../l10n/app_localizations.dart';

class AuthRequiredScreen extends ConsumerWidget {
  final String title;
  final String description;

  const AuthRequiredScreen({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.colorMain.withOpacity(0.08),
              isDark ? AppColors.darkSurface : Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top bar with language switch on the right
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () => _showLanguageDialog(context, ref, l10n),
                      icon: const Icon(Icons.language_rounded),
                      tooltip: l10n.language,
                      style: IconButton.styleFrom(
                        foregroundColor: isDark
                            ? Colors.grey[300]
                            : Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              // Centered content card
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Icon at top center with subtle background
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: AppColors.colorMain.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.colorMain.withOpacity(0.15),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.lock_outline_rounded,
                              color: AppColors.colorMain,
                              size: 40,
                            ),
                          ),
                          const SizedBox(height: 28),
                          Text(
                            title,
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            description,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                  height: 1.45,
                                ),
                          ),
                          const SizedBox(height: 32),
                          // Buttons in a column on small width, or row when wide
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final useColumn = constraints.maxWidth < 320;
                              if (useColumn) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    _loginButton(context),
                                    const SizedBox(height: 12),
                                    _registerButton(context, l10n),
                                  ],
                                );
                              }
                              return Row(
                                children: [
                                  Expanded(child: _loginButton(context)),
                                  const SizedBox(width: 14),
                                  Expanded(child: _registerButton(context, l10n)),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                          Text(
                            l10n.authRequiredHint,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: isDark
                                      ? Colors.grey[500]
                                      : Colors.grey[500],
                                  height: 1.35,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _pushLogin(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  void _pushRegister(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const RegisterPage()),
    );
  }

  Widget _loginButton(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return FilledButton.icon(
      onPressed: () => _pushLogin(context),
      icon: const Icon(Icons.login_rounded, size: 20),
      label: Text(l10n.login),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  Widget _registerButton(BuildContext context, AppLocalizations l10n) {
    return OutlinedButton.icon(
      onPressed: () => _pushRegister(context),
      icon: const Icon(Icons.person_add_rounded, size: 20),
      label: Text(l10n.register),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  void _showLanguageDialog(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    final currentLocale = ref.read(localeProvider);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.language),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: Text(l10n.english),
              value: 'en',
              groupValue: currentLocale.languageCode,
              onChanged: (value) {
                if (value != null) {
                  ref.read(localeProvider.notifier).setLocale(Locale(value));
                  Navigator.pop(ctx);
                }
              },
            ),
            RadioListTile<String>(
              title: Text(l10n.russian),
              value: 'ru',
              groupValue: currentLocale.languageCode,
              onChanged: (value) {
                if (value != null) {
                  ref.read(localeProvider.notifier).setLocale(Locale(value));
                  Navigator.pop(ctx);
                }
              },
            ),
            RadioListTile<String>(
              title: Text(l10n.kazakh),
              value: 'kk',
              groupValue: currentLocale.languageCode,
              onChanged: (value) {
                if (value != null) {
                  ref.read(localeProvider.notifier).setLocale(Locale(value));
                  Navigator.pop(ctx);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
