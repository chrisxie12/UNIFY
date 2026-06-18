import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/supabase_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../../data/models/academic_models.dart';
import '../providers/academic_provider.dart';
import '../widgets/resource_card.dart';

/// Academic search engine — searches both courses and resources by code,
/// name, lecturer and type.
class AcademicSearchScreen extends ConsumerStatefulWidget {
  const AcademicSearchScreen({super.key});

  @override
  ConsumerState<AcademicSearchScreen> createState() =>
      _AcademicSearchScreenState();
}

class _AcademicSearchScreenState
    extends ConsumerState<AcademicSearchScreen> {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();
  Timer? _debounce;
  bool _searched = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(resourceFilterProvider.notifier).state = const ResourceFilter();
      ref.read(courseSearchProvider.notifier).state = '';
      _focus.requestFocus();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      final f = ref.read(resourceFilterProvider);
      ref.read(resourceFilterProvider.notifier).state =
          f.copyWith(query: value.trim());
      ref.read(courseSearchProvider.notifier).state = value.trim();
      setState(() => _searched = value.trim().isNotEmpty);
      if (value.trim().length > 2) {
        final uid = ref.read(currentUserProvider)?.id;
        ref.read(academicRepositoryProvider).logSearch(uid, value.trim());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final resourcesAsync = ref.watch(resourcesProvider);
    final coursesAsync = ref.watch(coursesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0.6,
        shadowColor: AppColors.border,
        titleSpacing: 0,
        title: Container(
          height: 42,
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.search_rounded,
                  color: AppColors.grey2, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  focusNode: _focus,
                  onChanged: _onChanged,
                  textInputAction: TextInputAction.search,
                  decoration: const InputDecoration(
                    hintText: 'Course code, name, lecturer, notes…',
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
              if (_ctrl.text.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    _ctrl.clear();
                    _onChanged('');
                  },
                  child: const Icon(Icons.close_rounded,
                      size: 18, color: AppColors.grey2),
                ),
            ],
          ),
        ),
      ),
      body: !_searched
          ? _suggestions()
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                // Courses
                coursesAsync.maybeWhen(
                  data: (courses) {
                    if (courses.isEmpty) return const SizedBox.shrink();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Courses',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.grey2)),
                        const SizedBox(height: 8),
                        ...courses.take(5).map((c) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                backgroundColor:
                                    context.primary.withValues(alpha: 0.10),
                                child: Icon(Icons.menu_book_rounded,
                                    color: context.primary, size: 20),
                              ),
                              title: Text('${c.code} · ${c.title}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600)),
                              subtitle: Text(c.subtitle,
                                  style: const TextStyle(fontSize: 12)),
                              onTap: () => context
                                  .push('/academic/course/${c.id}'),
                            )),
                        const SizedBox(height: 12),
                      ],
                    );
                  },
                  orElse: () => const SizedBox.shrink(),
                ),

                // Resources
                resourcesAsync.when(
                  loading: () => const Center(
                      child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  )),
                  error: (e, _) => Text('Error: $e'),
                  data: (items) {
                    if (items.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: Text('No resources found',
                            style: TextStyle(color: AppColors.grey2)),
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Resources',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.grey2)),
                        const SizedBox(height: 8),
                        ...items.map((r) => ResourceCard(
                              resource: r,
                              onTap: () => context
                                  .push('/academic/resource/${r.id}'),
                            )),
                      ],
                    );
                  },
                ),
              ],
            ),
    );
  }

  Widget _suggestions() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Filter by type',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ResourceType.values
              .map((t) => GestureDetector(
                    onTap: () {
                      ref.read(resourceFilterProvider.notifier).state =
                          ResourceFilter(type: t);
                      setState(() => _searched = true);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: t.color.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(t.icon, size: 15, color: t.color),
                          const SizedBox(width: 6),
                          Text(t.label,
                              style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: t.color)),
                        ],
                      ),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }
}
