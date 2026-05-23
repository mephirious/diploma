import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

class ReservationsListPage extends StatelessWidget {
  const ReservationsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.reservations)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            l10n.startBooking,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
