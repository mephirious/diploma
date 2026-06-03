import '../../../l10n/app_localizations.dart';
import '../data/models/session_model_simple.dart';

String sessionPriceLabel(AppLocalizations l10n, SessionModelSimple session) {
  if (session.pricingModel == 'fixed_split') {
    final min = session.priceRangeMinMinor;
    final max = session.priceRangeMaxMinor ?? session.pricePerPlayer.toInt();
    if (min != null && min > 0 && min != max) {
      return l10n.priceRangePerPerson(min, max);
    }
    return l10n.priceQuotePerPerson(max);
  }
  return l10n.stablePricePerPerson(session.pricePerPlayer.toInt());
}
