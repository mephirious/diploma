class NewsListItem {
  final String id;
  final String title;
  final String slug;
  final String summary;
  final String imagePath;
  final String city;
  final String country;
  final String author;
  final DateTime publishedAt;
  final List<String> tags;

  const NewsListItem({
    required this.id,
    required this.title,
    required this.slug,
    required this.summary,
    required this.imagePath,
    required this.city,
    required this.country,
    required this.author,
    required this.publishedAt,
    required this.tags,
  });

  factory NewsListItem.fromJson(Map<String, dynamic> json) {
    return NewsListItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      summary: json['summary']?.toString() ?? '',
      imagePath: json['image_path']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      author: json['author']?.toString() ?? '',
      publishedAt: DateTime.tryParse(json['published_at']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      tags: (json['tags'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .where((e) => e.isNotEmpty)
          .toList(),
    );
  }
}

class NewsDetail {
  final String id;
  final String title;
  final String slug;
  final String summary;
  final String contentMd;
  final List<String> imagePaths;
  final String city;
  final String country;
  final String author;
  final DateTime publishedAt;
  final List<String> tags;

  const NewsDetail({
    required this.id,
    required this.title,
    required this.slug,
    required this.summary,
    required this.contentMd,
    required this.imagePaths,
    required this.city,
    required this.country,
    required this.author,
    required this.publishedAt,
    required this.tags,
  });

  factory NewsDetail.fromJson(Map<String, dynamic> json) {
    return NewsDetail(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      summary: json['summary']?.toString() ?? '',
      contentMd: json['content_md']?.toString() ?? '',
      imagePaths: (json['image_paths'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .where((e) => e.isNotEmpty)
          .toList(),
      city: json['city']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      author: json['author']?.toString() ?? '',
      publishedAt: DateTime.tryParse(json['published_at']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      tags: (json['tags'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .where((e) => e.isNotEmpty)
          .toList(),
    );
  }
}
