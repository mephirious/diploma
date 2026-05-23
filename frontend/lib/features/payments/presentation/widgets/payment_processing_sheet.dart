import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';

/// Non-dismissible bottom sheet shown while payment status is polled (30s max).
class PaymentProcessingSheet extends StatefulWidget {
  const PaymentProcessingSheet({super.key});

  @override
  State<PaymentProcessingSheet> createState() => _PaymentProcessingSheetState();
}

class _PaymentProcessingSheetState extends State<PaymentProcessingSheet>
    with SingleTickerProviderStateMixin {
  static const _timeout = Duration(seconds: 30);

  late final AnimationController _timerController;

  @override
  void initState() {
    super.initState();
    _timerController = AnimationController(
      vsync: this,
      duration: _timeout,
    )..forward();
  }

  @override
  void dispose() {
    _timerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? const Color(0xFF161B22) : Colors.white;
    final sub = isDark ? const Color(0xFF8B949E) : const Color(0xFF6E7A8A);

    return PopScope(
      canPop: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              const SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: AppColors.colorMain,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.processingPayment,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                  color: isDark ? Colors.white : const Color(0xFF0D1117),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.processingPaymentHint,
                style: TextStyle(fontSize: 14, color: sub, height: 1.4),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              AnimatedBuilder(
                animation: _timerController,
                builder: (context, _) {
                  final remaining = 1.0 - _timerController.value;
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: SizedBox(
                      height: 4,
                      width: double.infinity,
                      child: Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          Container(
                            color: AppColors.colorMain.withValues(alpha: 0.15),
                          ),
                          FractionallySizedBox(
                            widthFactor: remaining.clamp(0.0, 1.0),
                            child: Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.colorMain,
                                    AppColors.colorAccent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
