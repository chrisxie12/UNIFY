import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:unify/core/widgets/app_error_widget.dart';
import 'package:unify/features/academic/presentation/providers/academic_provider.dart';

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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
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
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey[100],
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
                    Icon(Icons.search, size: 64, color: Colors.grey[300]),
                    const SizedBox(height: 12),
                    Text('Search by course code, name,\nlecturer, or topic',
                        textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[500])),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  const _SectionHeader(title: 'Courses'),
                  coursesAsync.when(
                    loading: () => const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator())),
                    error: (e, _) => Padding(
                      padding: const EdgeInsets.all(16),
                      child: AppErrorWidget(e),
                    ),
                    data: (courses) {
                      if (courses.isEmpty) {
                        return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text('No courses found', style: TextStyle(color: Colors.grey[500])),
                      );
                      }
                      return Column(
                        children: courses.map((c) => ListTile(
                          leading: CircleAvatar(
                            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                            child: Text(c.code.substring(0, 2), style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w600, fontSize: 11)),
                          ),
                          title: Text('${c.code} - ${c.name}', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                          subtitle: Text('${c.credits} credits', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                          onTap: () => context.push('/academic/course/${c.id}'),
                        )).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  const _SectionHeader(title: 'Resources'),
                  resourcesAsync.when(
                    loading: () => const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator())),
                    error: (e, _) => Padding(
                      padding: const EdgeInsets.all(16),
                      child: AppErrorWidget(e),
                    ),
                    data: (resources) {
                      if (resources.isEmpty) {
                        return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text('No resources found', style: TextStyle(color: Colors.grey[500])),
                      );
                      }
                      return Column(
                        children: resources.map((r) => ListTile(
                          leading: Icon(Icons.description, color: theme.colorScheme.primary),
                          title: Text(r.title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                          subtitle: Text('${r.type.replaceAll('_', ' ')} · ${r.downloadCount} downloads', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                          trailing: const Icon(Icons.download_outlined, size: 20),
                          onTap: () {},
                        )).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
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
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.grey[700])),
    );
  }
}
