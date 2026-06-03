import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../providers/news_provider.dart';
import 'news_list_page.dart';

class NewsDetailPage extends ConsumerWidget {
  final String newsId;

  const NewsDetailPage({
    super.key,
    required this.newsId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(newsDetailProvider(newsId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1923) : Colors.white,
      body: detail.when(
        loading: () => const SafeArea(
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (error, _) => SafeArea(
          child: _DetailError(message: error.toString()),
        ),
        data: (item) {
          final imageUrl = item.imagePaths.isEmpty
              ? ''
              : resolveNewsImageUrl(item.imagePaths.first);
          final date =
              DateFormat('d MMMM yyyy').format(item.publishedAt.toLocal());

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: imageUrl.isEmpty ? 120 : 280,
                foregroundColor: Colors.white,
                backgroundColor:
                    isDark ? const Color(0xFF0F1923) : Colors.black87,
                flexibleSpace: FlexibleSpaceBar(
                  background: imageUrl.isEmpty
                      ? Container(color: AppColors.colorMain)
                      : Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  Container(color: AppColors.colorMain),
                            ),
                            const DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black38,
                                    Colors.transparent,
                                    Colors.black54,
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${item.city}, ${item.country} - $date',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.colorMain,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        item.title,
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  height: 1.08,
                                ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        item.summary,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.72)
                                  : Colors.grey.shade700,
                              height: 1.42,
                            ),
                      ),
                      const SizedBox(height: 18),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final tag in item.tags) _DetailTag(label: tag),
                        ],
                      ),
                      const SizedBox(height: 24),
                      MarkdownBody(
                        data: item.contentMd,
                        selectable: true,
                        styleSheet:
                            MarkdownStyleSheet.fromTheme(Theme.of(context))
                                .copyWith(
                          h1: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w900),
                          h2: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.w900),
                          p: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                height: 1.55,
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.82)
                                    : Colors.grey.shade800,
                              ),
                          listBullet:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: AppColors.colorMain,
                                    fontWeight: FontWeight.w900,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DetailTag extends StatelessWidget {
  final String label;

  const _DetailTag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.colorMain.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.colorMain,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _DetailError extends StatelessWidget {
  final String message;

  const _DetailError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 42, color: Colors.redAccent),
          const SizedBox(height: 12),
          const Text(
            'Could not open article',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
          ),
          const SizedBox(height: 6),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => Navigator.of(context).maybePop(),
            child: const Text('Back'),
          ),
        ],
      ),
    );
  }
}
