import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/theme_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/support_provider.dart';

class HelpArticleScreen extends ConsumerStatefulWidget {
  const HelpArticleScreen({super.key, required this.articleId});
  final String articleId;

  @override
  ConsumerState<HelpArticleScreen> createState() => _HelpArticleScreenState();
}

class _HelpArticleScreenState extends ConsumerState<HelpArticleScreen> {
  bool _markedHelpful = false;

  @override
  void initState() {
    super.initState();
    // Fire-and-forget view count bump, exactly once.
    Future.microtask(() {
      ref
          .read(supportRepositoryProvider)
          .incrementArticleView(widget.articleId);
    });
  }

  Future<void> _markHelpful() async {
    setState(() => _markedHelpful = true);
    try {
      await ref
          .read(supportRepositoryProvider)
          .markArticleHelpful(widget.articleId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thanks for your feedback!')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _markedHelpful = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not record that: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final article = ref.watch(articleProvider(widget.articleId));
    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.appBarBg,
        surfaceTintColor: context.appBarBg,
        elevation: 0.6,
        shadowColor: context.borderCol,
        title: const Text('Help Article',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: article.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Could not load\n$e')),
        data: (a) {
          if (a == null) {
            return const Center(
                child: Text('Article not found',
                    style: TextStyle(color: context.textSecondary)));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (a.category != null && a.category!.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: context.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(a.category!,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: context.primary)),
                ),
              const SizedBox(height: 12),
              Text(a.title,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.cardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: context.borderCol),
                ),
                child: Text(a.body,
                    style: TextStyle(
                        fontSize: 15, height: 1.5, color: context.textSecondary)),
              ),
              const SizedBox(height: 22),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.cardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: context.borderCol),
                ),
                child: Column(
                  children: [
                    const Text('Was this helpful?',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _markedHelpful ? null : _markHelpful,
                        icon: Icon(_markedHelpful
                            ? Icons.check_circle_rounded
                            : Icons.thumb_up_alt_outlined),
                        label: Text(_markedHelpful
                            ? 'Marked as helpful'
                            : 'Yes, this helped'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _markedHelpful
                              ? AppColors.success
                              : context.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }
}
