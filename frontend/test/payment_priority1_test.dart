import 'package:flutter_test/flutter_test.dart';
import 'package:sport_booking/features/payments/data/models/payment_intent_model.dart';
import 'package:sport_booking/features/payments/data/payment_card_validator.dart';
import 'package:sport_booking/features/reservations/presentation/hold_countdown.dart';
import 'package:sport_booking/features/sessions/data/models/session_model_simple.dart';
import 'package:sport_booking/features/sessions/presentation/session_price_text.dart';
import 'package:sport_booking/l10n/app_localizations_en.dart';

void main() {
  test('payment method selections map to backend-supported methods', () {
    expect(apiPaymentMethodFromSelection('apple_pay'), 'apple_pay');
    expect(apiPaymentMethodFromSelection('google_pay'), 'card');
    expect(apiPaymentMethodFromSelection('kaspi'), 'card');
    expect(apiPaymentMethodFromSelection('card_123'), 'card');
  });

  test('card validator accepts Luhn-valid future card details', () {
    final result = PaymentCardValidator.validate(
      number: '4242 4242 4242 4242',
      expiry: '12/30',
      cvv: '123',
      now: DateTime(2026, 5, 27),
    );
    expect(result.isValid, isTrue);
  });

  test('card validator rejects invalid card data', () {
    expect(
      PaymentCardValidator.validate(
        number: '1234',
        expiry: '12/30',
        cvv: '123',
        now: DateTime(2026, 5, 27),
      ).field,
      'number',
    );
    expect(
      PaymentCardValidator.validate(
        number: '4242 4242 4242 4242',
        expiry: '01/20',
        cvv: '123',
        now: DateTime(2026, 5, 27),
      ).field,
      'expiry',
    );
  });

  test('hold countdown formats minutes and hours', () {
    expect(
      formatHoldCountdown(const Duration(minutes: 4, seconds: 5)),
      '04:05',
    );
    expect(
      formatHoldCountdown(const Duration(hours: 1, minutes: 2, seconds: 3)),
      '1:02:03',
    );
    expect(formatHoldCountdown(const Duration(seconds: -1)), '00:00');
  });

  test('session price text discloses fixed split and stable per-person pricing',
      () {
    final l10n = AppLocalizationsEn();
    final fixedSplit = SessionModelSimple(
      id: 's1',
      sportType: 'football',
      skillLevel: 'scheduled',
      venueName: 'Arena',
      venueAddress: '',
      venueImage: '',
      hostName: 'Arena',
      hostAvatar: '',
      maxPlayers: 6,
      currentPlayers: 3,
      pricePerPlayer: 5000,
      timeSlots: const ['18:00'],
      date: DateTime(2026, 5, 27),
      distance: 0,
      pricingModel: 'fixed_split',
      priceRangeMinMinor: 3000,
      priceRangeMaxMinor: 5000,
    );
    final perPerson = fixedSplit.copyWith(
      pricingModel: 'per_person',
      pricePerPlayer: 2500,
      priceRangeMinMinor: null,
      priceRangeMaxMinor: null,
    );

    expect(sessionPriceLabel(l10n, fixedSplit), '3000–5000 ₸ / person');
    expect(sessionPriceLabel(l10n, perPerson), '2500 ₸ / person');
  });
}
