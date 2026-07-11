import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:unify/features/messaging/presentation/providers/messaging_provider.dart';
import 'package:unify/core/extensions/theme_extensions.dart';
import 'package:unify/core/widgets/app_loading_widget.dart';

class CreateGroupScreen extends ConsumerStatefulWidget {
  final String? communityId;
  final String? communityName;
  const CreateGroupScreen({super.key, this.communityId, this.communityName});

  @override
  ConsumerState<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends ConsumerState<CreateGroupScreen> {
  final _nameController = TextEditingController();
  final _searchController = TextEditingController();
  final _selectedIds = <String>{};
  final _selectedNames = <String>[];
  String _groupType = 'study_group';
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _nameController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _search(String query) async {
    if (query.length < 2) {
      setState(() => _searchResults = []);
      return;
    }
    setState(() => _isSearching = true);
    try {
      final results = await ref.read(messagingRepositoryProvider).searchUsers(query);
      setState(() => _searchResults = results);
    } catch (_) {}
    setState(() => _isSearching = false);
  }

  void _createGroup() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    ref.read(messagingProvider.notifier).createConversation(
      type: _groupType,
      title: name,
      communityId: widget.communityId,
      participantIds: _selectedIds.toList(),
    );

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Group'),
        actions: [
          TextButton(
            onPressed: _selectedIds.isNotEmpty ? _createGroup : null,
            child: const Text('Create'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Group Name',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),
          Text('Type', style: TextStyle(fontWeight: FontWeight.w600, color: context.textSecondary)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _typeChip('Study Group', 'study_group', theme),
              _typeChip('Class Chat', 'group', theme),
            ],
          ),
          const SizedBox(height: 20),
          Text('Add Members', style: TextStyle(fontWeight: FontWeight.w600, color: context.textSecondary)),
          const SizedBox(height: 8),
          if (_selectedNames.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Wrap(
                spacing: 4,
                children: _selectedNames.map((name) => Chip(
                  label: Text(name, style: const TextStyle(fontSize: 12)),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  onDeleted: () {
                    final idx = _selectedNames.indexOf(name);
                    if (idx >= 0) {
                      setState(() {
                        _selectedNames.removeAt(idx);
                        _selectedIds.remove(_selectedIds.elementAt(idx));
                      });
                    }
                  },
                )).toList(),
              ),
            ),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search users...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onChanged: _search,
          ),
          if (_isSearching)
            const Padding(padding: EdgeInsets.all(16), child: AppLoadingWidget.list(itemCount: 3)),
          ..._searchResults.map((user) {
            final userId = user['id'] as String;
            final name = user['full_name'] as String? ?? 'Unknown';
            final isSelected = _selectedIds.contains(userId);

            return ListTile(
              leading: CircleAvatar(
                backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.15),
                child: Text(name[0].toUpperCase(), style: TextStyle(color: theme.colorScheme.primary)),
              ),
              title: Text(name),
              trailing: isSelected
                  ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
                  : const Icon(Icons.circle_outlined),
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedIds.remove(userId);
                    _selectedNames.remove(name);
                  } else {
                    _selectedIds.add(userId);
                    _selectedNames.add(name);
                  }
                });
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _typeChip(String label, String value, ThemeData theme) {
    final selected = _groupType == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _groupType = value),
      selectedColor: theme.colorScheme.primary.withValues(alpha: 0.15),
    );
  }
}
