import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/news_model.dart';
import '../../data/repositories/news_repository.dart';

class NewsFeedState {
  final List<NewsListItem> items;
  final bool isLoadingInitial;
  final bool isLoadingMore;
  final bool hasMore;
  final int page;
  final int pageSize;
  final String? error;

  const NewsFeedState({
    required this.items,
    required this.isLoadingInitial,
    required this.isLoadingMore,
    required this.hasMore,
    required this.page,
    required this.pageSize,
    this.error,
  });

  factory NewsFeedState.initial() {
    return const NewsFeedState(
      items: [],
      isLoadingInitial: true,
      isLoadingMore: false,
      hasMore: true,
      page: 0,
      pageSize: 20,
    );
  }

  NewsFeedState copyWith({
    List<NewsListItem>? items,
    bool? isLoadingInitial,
    bool? isLoadingMore,
    bool? hasMore,
    int? page,
    int? pageSize,
    String? error,
  }) {
    return NewsFeedState(
      items: items ?? this.items,
      isLoadingInitial: isLoadingInitial ?? this.isLoadingInitial,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      error: error,
    );
  }
}

class NewsFeedNotifier extends StateNotifier<NewsFeedState> {
  final NewsRepository _repository;

  NewsFeedNotifier(this._repository) : super(NewsFeedState.initial()) {
    refresh();
  }

  Future<void> refresh() async {
    try {
      state = NewsFeedState.initial().copyWith(pageSize: state.pageSize);
      final resp = await _repository.getNewsPage(
        page: 0,
        pageSize: state.pageSize,
      );
      state = state.copyWith(
        items: resp.news,
        isLoadingInitial: false,
        hasMore: resp.hasMore,
        page: resp.page,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingInitial: false,
        hasMore: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadNextPage() async {
    if (state.isLoadingMore || !state.hasMore) return;

    try {
      state = state.copyWith(isLoadingMore: true);
      final resp = await _repository.getNewsPage(
        page: state.page + 1,
        pageSize: state.pageSize,
      );
      state = state.copyWith(
        items: [...state.items, ...resp.news],
        isLoadingMore: false,
        hasMore: resp.hasMore,
        page: resp.page,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        hasMore: false,
        error: e.toString(),
      );
    }
  }
}

final newsFeedProvider =
    StateNotifierProvider<NewsFeedNotifier, NewsFeedState>((ref) {
  return NewsFeedNotifier(ref.watch(newsRepositoryProvider));
});

final newsDetailProvider =
    FutureProvider.autoDispose.family<NewsDetail, String>((ref, id) async {
  return ref.watch(newsRepositoryProvider).getNewsDetail(id);
});
