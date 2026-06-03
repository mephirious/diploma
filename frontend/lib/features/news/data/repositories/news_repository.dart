import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/news_model.dart';

class PaginatedNewsResponse {
  final List<NewsListItem> news;
  final int page;
  final int pageSize;
  final int totalCount;

  const PaginatedNewsResponse({
    required this.news,
    required this.page,
    required this.pageSize,
    required this.totalCount,
  });

  bool get hasMore => ((page + 1) * pageSize) < totalCount;
}

class NewsRepository {
  final DioClient _client;

  const NewsRepository(this._client);

  Future<PaginatedNewsResponse> getNewsPage({
    required int page,
    int pageSize = 20,
  }) async {
    final data = await _client.get(
      ApiEndpoints.news,
      queryParameters: {
        'list_params.page': page.toString(),
        'list_params.page_size': pageSize.toString(),
        'list_params.with_total_count': 'true',
      },
    );

    if (data is! Map<String, dynamic>) {
      return PaginatedNewsResponse(
        news: const [],
        page: page,
        pageSize: pageSize,
        totalCount: 0,
      );
    }

    final pagination = data['pagination_info'] as Map<String, dynamic>?;
    final results = data['results'] as List<dynamic>? ?? const [];
    return PaginatedNewsResponse(
      news: results
          .whereType<Map<String, dynamic>>()
          .map(NewsListItem.fromJson)
          .toList(),
      page: int.tryParse(pagination?['page']?.toString() ?? '') ?? page,
      pageSize:
          int.tryParse(pagination?['page_size']?.toString() ?? '') ?? pageSize,
      totalCount:
          int.tryParse(pagination?['total_count']?.toString() ?? '') ?? 0,
    );
  }

  Future<NewsDetail> getNewsDetail(String id) async {
    final data = await _client.get(ApiEndpoints.newsById(id));
    if (data is Map<String, dynamic>) {
      return NewsDetail.fromJson(data);
    }
    throw const FormatException('Invalid news detail response');
  }
}

final newsRepositoryProvider = Provider<NewsRepository>((ref) {
  return NewsRepository(ref.watch(dioClientProvider));
});
