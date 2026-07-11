import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:unify/core/widgets/app_empty_widget.dart';
import 'package:unify/core/widgets/app_error_widget.dart';
import 'package:unify/core/widgets/app_loading_widget.dart';
import 'package:unify/features/academic/presentation/providers/academic_provider.dart';

import '../../../../core/extensions/theme_extensions.dart';
import '../../../../core/design_system/tokens.dart';
import '../../../../core/design_system/typography.dart';

class AcademicSearchScreen extends ConsumerStatefulWidget {
  const AcademicSearchScreen({super.key});

  @override
  ConsumerState<AcademicSearchScreen> createState() => _AcademicSearchScreenState();
}

class _AcademicSearchScreenState extends ConsumerState<AcademicSearchScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resourcesAsync = ref.watch(searchResourcesProvider(_query));
    final coursesAsync = ref.watch(searchCoursesProvider(_query));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(USpacing.md),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search courses, notes, past questions...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () { _searchController.clear(); setState(() => _query = ''); },
                      )
                    : null,
                border: OutlineInputBorder(borderRadius: URadius.mdAll),
                filled: true,
                fillColor: context.borderCol.withValues(alpha: 0.3),
              ),
              onChanged: (v) => setState(() => _query = v.trim()),
              textInputAction: TextInputAction.search,
            ),
          ),
          if (_query.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.search, size: 64, color: context.borderCol),
                    const SizedBox(height: USpacing.md),
                    Text('Search by course code, name,\nlecturer, or topic',
                        textAlign: TextAlign.center,
                        style: UText.bodyS.copyWith(color: context.textSecondary)),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: USpacing.md),
                children: [
                  const _SectionHeader(title: 'Courses'),
                  coursesAsync.when(
                    loading: () => const AppLoadingWidget.list(itemCount: 2),
                    error: (e, _) => Padding(
                      padding: const EdgeInsets.all(16),
                      child: AppErrorWidget(e),
                    ),
                    data: (courses) {
                      if (courses.isEmpty) {
                        return const Padding(
                        padding: EdgeInsets.all(USpacing.base),
                        child: AppEmptyWidget(
                          icon: Icons.menu_book_rounded,
                          title: 'No courses found',
                        ),
                      );
                      }
                      return Column(
                        children: courses.map((c) => ListTile(
                          leading: CircleAvatar(
                            backgroundColor: context.primary.withValues(alpha: 0.1),
                            child: Text(c.code.substring(0, 2),
                                style: UText.caption.copyWith(
                                    color: context.primary,
                                    fontWeight: FontWeight.w600)),
                          ),
                          title: Text('${c.code} - ${c.name}',
                              style: UText.bodyS.copyWith(fontWeight: FontWeight.w500)),
                          subtitle: Text('${c.credits} credits',
                              style: UText.caption.copyWith(color: context.textSecondary)),
                          onTap: () => context.push('/academic/course/${c.id}'),
                        )).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: USpacing.sm),
                  const _SectionHeader(title: 'Resources'),
                  resourcesAsync.when(
                    loading: () => const AppLoadingWidget.list(itemCount: 2),
                    error: (e, _) => Padding(
                      padding: const EdgeInsets.all(16),
                      child: AppErrorWidget(e),
                    ),
                    data: (resources) {
                      if (resources.isEmpty) {
                        return const Padding(
                        padding: EdgeInsets.all(USpacing.base),
                        child: AppEmptyWidget(
                          icon: Icons.menu_book_rounded,
                          title: 'No resources found',
                        ),
                      );
                      }
                      return Column(
                        children: resources.map((r) => ListTile(
                          leading: Icon(Icons.description, color: context.primary),
                          title: Text(r.title,
                              style: UText.bodyS.copyWith(fontWeight: FontWeight.w500)),
                          subtitle: Text(
                              '${r.type.replaceAll('_', ' ')} · ${r.downloadCount} downloads',
                              style: UText.caption.copyWith(color: context.textSecondary)),
                          trailing: const Icon(Icons.download_outlined, size: 20),
                          onTap: () {},
                        )).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: USpacing.xl),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: USpacing.sm),
      child: Text(title,
          style: UText.labelL.copyWith(color: context.textSecondary)),
    );
  }
}
