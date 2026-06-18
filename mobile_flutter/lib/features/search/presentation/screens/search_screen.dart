import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/search_provider.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.invalidate(globalSearchProvider(value));
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final query = _searchController.text.trim();

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search students, communities, events...',
            hintStyle: TextStyle(color: theme.colorScheme.onSurface.withAlpha(128), fontSize: 15),
            border: InputBorder.none,
            filled: false,
          ),
          style: const TextStyle(fontSize: 16),
          textInputAction: TextInputAction.search,
          onChanged: _onSearchChanged,
        ),
        actions: [
          if (query.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                ref.invalidate(globalSearchProvider(''));
              },
            ),
        ],
      ),
      body: query.length < 2
          ? _buildEmptyState(theme)
          : _buildSearchResults(theme),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 64, color: theme.colorScheme.onSurface.withAlpha(51)),
          const SizedBox(height: 12),
          Text('Search UNIFY', style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurface.withAlpha(128),
          )),
          const SizedBox(height: 4),
          Text(
            'Find students, communities, events, and more',
            style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(102)),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(ThemeData theme) {
    final query = _searchController.text.trim();
    final resultsAsync = ref.watch(globalSearchProvider(query));

    return resultsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 8),
            Text('Something went wrong', style: TextStyle(color: theme.colorScheme.error)),
            const SizedBox(height: 4),
            TextButton(
              onPressed: () => ref.invalidate(globalSearchProvider(query)),
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
      data: (results) {
        if (results.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 48, color: theme.colorScheme.onSurface.withAlpha(77)),
                const SizedBox(height: 8),
                Text('No results for "$query"',
                    style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(128))),
              ],
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                '${results.totalCount} results for "$query"',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha(153),
                ),
              ),
            ),
            if (results.students.isNotEmpty) ...[
              _SectionHeader(title: 'Students', count: results.students.length),
              ...results.students.map((s) => _StudentTile(s, theme)),
              const SizedBox(height: 12),
            ],
            if (results.communities.isNotEmpty) ...[
              _SectionHeader(title: 'Communities', count: results.communities.length),
              ...results.communities.map((c) => _CommunityTile(c, theme)),
              const SizedBox(height: 12),
            ],
            if (results.events.isNotEmpty) ...[
              _SectionHeader(title: 'Events', count: results.events.length),
              ...results.events.map((e) => _EventTile(e, theme)),
              const SizedBox(height: 12),
            ],
            if (results.resources.isNotEmpty) ...[
              _SectionHeader(title: 'Academic Resources', count: results.resources.length),
              ...results.resources.map((r) => _ResourceTile(r, theme)),
              const SizedBox(height: 12),
            ],
            if (results.opportunities.isNotEmpty) ...[
              _SectionHeader(title: 'Opportunities', count: results.opportunities.length),
              ...results.opportunities.map((o) => _OpportunityTile(o, theme)),
              const SizedBox(height: 12),
            ],
          ],
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  const _SectionHeader({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          )),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withAlpha(25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentTile extends StatelessWidget {
  final Map<String, dynamic> data;
  final ThemeData theme;
  const _StudentTile(this.data, this.theme);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        leading: CircleAvatar(
          radius: 18,
          backgroundImage: data['avatar_url'] != null
              ? NetworkImage(data['avatar_url'])
              : null,
          child: data['avatar_url'] == null
              ? Icon(Icons.person, color: theme.colorScheme.onSurface.withAlpha(128))
              : null,
        ),
        title: Text(data['full_name'] ?? 'Unknown', style: const TextStyle(fontSize: 14)),
        subtitle: Text(
          [data['programme'], data['department']].whereType<String>().join(' · '),
          style: const TextStyle(fontSize: 12),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        dense: true,
        onTap: () => context.push('/profile'),
      ),
    );
  }
}

class _CommunityTile extends StatelessWidget {
  final Map<String, dynamic> data;
  final ThemeData theme;
  const _CommunityTile(this.data, this.theme);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        leading: CircleAvatar(
          radius: 18,
          backgroundImage: data['avatar_url'] != null
              ? NetworkImage(data['avatar_url'])
              : null,
          child: data['avatar_url'] == null
              ? Icon(Icons.group, color: theme.colorScheme.onSurface.withAlpha(128))
              : null,
        ),
        title: Text(data['name'] ?? '', style: const TextStyle(fontSize: 14)),
        subtitle: Text(
          '${data['member_count'] ?? 0} members',
          style: const TextStyle(fontSize: 12),
        ),
        dense: true,
        onTap: () {
          final id = data['id'] as String;
          context.push('/community/$id');
        },
      ),
    );
  }
}

class _EventTile extends StatelessWidget {
  final Map<String, dynamic> data;
  final ThemeData theme;
  const _EventTile(this.data, this.theme);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withAlpha(25),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.event, size: 18, color: theme.colorScheme.primary),
        ),
        title: Text(data['title'] ?? '', style: const TextStyle(fontSize: 14)),
        subtitle: Text(
          data['event_date'] ?? '',
          style: const TextStyle(fontSize: 12),
        ),
        dense: true,
        onTap: () {
          final id = data['id'] as String;
          context.push('/event/$id');
        },
      ),
    );
  }
}

class _ResourceTile extends StatelessWidget {
  final Map<String, dynamic> data;
  final ThemeData theme;
  const _ResourceTile(this.data, this.theme);

  @override
  Widget build(BuildContext context) {
    final fileType = data['file_type'] as String? ?? 'file';
    final IconData icon = switch (fileType) {
      'pdf' => Icons.picture_as_pdf,
      'video' => Icons.videocam,
      'image' => Icons.image,
      _ => Icons.description,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: theme.colorScheme.secondary.withAlpha(25),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: theme.colorScheme.secondary),
        ),
        title: Text(data['title'] ?? '', style: const TextStyle(fontSize: 14)),
        subtitle: Text(
          fileType.toUpperCase(),
          style: const TextStyle(fontSize: 12),
        ),
        dense: true,
        onTap: () {
          context.push('/academic/resources', extra: {'type': fileType});
        },
      ),
    );
  }
}

class _OpportunityTile extends StatelessWidget {
  final Map<String, dynamic> data;
  final ThemeData theme;
  const _OpportunityTile(this.data, this.theme);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.green.withAlpha(25),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.work_outline, size: 18, color: Colors.green),
        ),
        title: Text(data['title'] ?? '', style: const TextStyle(fontSize: 14)),
        subtitle: Text(
          [data['organization'], data['type']].whereType<String>().join(' · '),
          style: const TextStyle(fontSize: 12),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        dense: true,
      ),
    );
  }
}
