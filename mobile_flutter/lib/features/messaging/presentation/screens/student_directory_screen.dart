import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:unify/core/widgets/app_error_widget.dart';
import 'package:unify/features/messaging/presentation/providers/messaging_provider.dart';
import 'package:unify/core/extensions/theme_extensions.dart';

class StudentDirectoryScreen extends ConsumerStatefulWidget {
  const StudentDirectoryScreen({super.key});

  @override
  ConsumerState<StudentDirectoryScreen> createState() => _StudentDirectoryScreenState();
}

class _StudentDirectoryScreenState extends ConsumerState<StudentDirectoryScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resultsAsync = ref.watch(searchUsersProvider(_query));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search People'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search by name, programme, or department...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
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
          Expanded(
            child: resultsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => AppErrorWidget(e, onRetry: () => ref.invalidate(searchUsersProvider(_query))),
              data: (users) {
                if (_query.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.people_outline, size: 64, color: context.textSecondary),
                        const SizedBox(height: 16),
                        Text('Search for students by name,\nprogramme, or department',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: context.textSecondary)),
                      ],
                    ),
                  );
                }
                if (users.isEmpty) {
                  return Center(child: Text('No results for "$_query"', style: TextStyle(color: context.textSecondary)));
                }
                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (_, i) {
                    final user = users[i];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.15),
                        child: Text(
                          ((user['full_name'] as String?)?[0] ?? '?').toUpperCase(),
                          style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w600),
                        ),
                      ),
                      title: Text(user['full_name'] as String? ?? 'Unknown'),
                      subtitle: Text(
                        [
                          user['programme'],
                          user['level'],
                          user['department'],
                        ].whereType<String>().join(' · '),
                        style: TextStyle(fontSize: 13, color: context.textSecondary),
                      ),
                      onTap: () async {
                        final userId = user['id'] as String;
                        try {
                          final convId = await ref
                              .read(messagingRepositoryProvider)
                              .getOrCreateDirectConversation(userId);
                          if (context.mounted) {
                            context.push('/messaging/chat/$convId');
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Could not open chat: $e')),
                            );
                          }
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
