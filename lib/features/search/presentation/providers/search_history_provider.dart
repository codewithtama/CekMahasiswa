import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchHistoryNotifier extends StateNotifier<List<String>> {
  SearchHistoryNotifier() : super([]) {
    _loadHistory();
  }

  static const _keyHistory = 'pddikti_search_history';

  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_keyHistory) ?? [];
      state = list;
    } catch (e, stack) {
      debugPrint('Error loading search history: $e\n$stack');
    }
  }

  Future<void> addQuery(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    try {
      final newList = List<String>.from(state);
      newList.remove(trimmed);
      newList.insert(0, trimmed);
      if (newList.length > 10) {
        newList.removeLast();
      }
      state = newList;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_keyHistory, newList);
    } catch (e, stack) {
      debugPrint('Error adding search query: $e\n$stack');
    }
  }

  Future<void> deleteQuery(String query) async {
    try {
      final newList = List<String>.from(state)..remove(query);
      state = newList;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_keyHistory, newList);
    } catch (e, stack) {
      debugPrint('Error deleting search query: $e\n$stack');
    }
  }

  Future<void> clearHistory() async {
    try {
      state = [];
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyHistory);
    } catch (e, stack) {
      debugPrint('Error clearing search history: $e\n$stack');
    }
  }
}

final searchHistoryProvider = StateNotifierProvider<SearchHistoryNotifier, List<String>>((ref) {
  return SearchHistoryNotifier();
});
