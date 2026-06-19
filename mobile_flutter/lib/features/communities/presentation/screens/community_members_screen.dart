import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/community_provider.dart';
import '../../../../core/widgets/app_error_widget.dart';

class CommunityMembersScreen extends ConsumerStatefulWidget {
  final String communityId;

  const CommunityMembersScreen({super.key, required this.communityId});

  @override
  ConsumerState<CommunityMembersScreen> createState() => _CommunityMembersScreenState();
}

class _CommunityMembersScreenState extends ConsumerState<CommunityMembersScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(communityMembersProvider(widget.communityId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Members'),
      ),
      body: membersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => AppErrorWidget(e),
        data: (members) {
          final searchQuery = _searchController.text;
          final filtered = searchQuery.isEmpty
              ? members
              : members.where((m) {
                  final profile = m['profiles'] as Map<String, dynamic>?;
                  final name = profile?['display_name'] as String? ?? '';
                  return name.toLowerCase().contains(searchQuery.toLowerCase());
                }).toList();

          final managers = filtered
              .where((m) => m['role'] == 'owner' || m['role'] == 'manager')
              .toList();
          final regulars = filtered
              .where((m) => m['role'] != 'owner' && m['role'] != 'manager')
              .toList();

          return Column(
            children: [
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search by name...',
                    prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                            icon: Icon(Icons.close, size: 18, color: Colors.grey[400]),
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                child: Row(
                  children: [
                    Text(
                      '${filtered.length} members',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.people_outline, size: 48, color: Colors.grey[300]),
                            const SizedBox(height: 12),
                            Text(
                              searchQuery.isEmpty ? 'No members found' : 'No members matching "$searchQuery"',
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.only(bottom: 16),
                        children: [
                          if (managers.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                              child: Text(
                                'Community Leaders',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            ...managers.map((m) => _MemberListTile(
                              member: m,
                              isManager: true,
                            )),
                          ],
                          if (regulars.isNotEmpty) ...[
                            if (managers.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                                child: Divider(color: Colors.grey[200]),
                              ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                              child: Text(
                                'Members',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            ...regulars.map((m) => _MemberListTile(
                              member: m,
                              isManager: false,
                            )),
                          ],
                        ],
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MemberListTile extends StatelessWidget {
  final Map<String, dynamic> member;
  final bool isManager;

  const _MemberListTile({
    required this.member,
    required this.isManager,
  });

  @override
  Widget build(BuildContext context) {
    final profile = member['profiles'] as Map<String, dynamic>?;
    final name = profile?['display_name'] as String? ?? 'User';
    final avatarUrl = profile?['avatar_url'] as String?;
    final isVerified = profile?['is_verified_leader'] as bool? ?? false;
    final programme = profile?['programme'] as String?;
    final level = profile?['level'] as String?;
    final role = member['role'] as String? ?? 'member';

    return ListTile(
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: Colors.grey[200],
        backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
        child: avatarUrl == null
            ? Text(
                name[0].toUpperCase(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              )
            : null,
      ),
      title: Row(
        children: [
          Flexible(
            child: Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (isVerified) ...[
            const SizedBox(width: 4),
            Icon(Icons.verified, color: Theme.of(context).colorScheme.primary, size: 18),
          ],
          if (isManager) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: role == 'owner'
                    ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                role == 'owner' ? 'Owner' : 'Manager',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: role == 'owner' ? Theme.of(context).colorScheme.primary : Colors.grey[600],
                ),
              ),
            ),
          ],
        ],
      ),
      subtitle: programme != null || level != null
          ? Text(
              [programme, level].nonNulls.join(' · '),
              style: TextStyle(fontSize: 13, color: Colors.grey[500]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      onTap: () => context.push('/app/profile'),
    );
  }
}
