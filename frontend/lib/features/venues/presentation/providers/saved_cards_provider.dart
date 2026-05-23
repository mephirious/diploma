import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/saved_card_model.dart';

const _savedCardsKey = 'saved_payment_cards';

final savedCardsProvider =
    StateNotifierProvider<SavedCardsNotifier, List<SavedCardModel>>((ref) {
  return SavedCardsNotifier();
});

class SavedCardsNotifier extends StateNotifier<List<SavedCardModel>> {
  SavedCardsNotifier() : super([]) {
    _loadCards();
  }

  Future<void> _loadCards() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_savedCardsKey);
    if (json != null) {
      try {
        final list = jsonDecode(json) as List;
        state = list
            .map((e) => SavedCardModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {
        state = [];
      }
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(state.map((c) => c.toJson()).toList());
    await prefs.setString(_savedCardsKey, json);
  }

  Future<void> addCard(SavedCardModel card) async {
    state = [...state, card];
    await _persist();
  }

  Future<void> removeCard(String id) async {
    state = state.where((c) => c.id != id).toList();
    await _persist();
  }
}
