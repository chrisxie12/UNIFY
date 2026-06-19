import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/community_provider.dart';
import '../../../../core/widgets/app_error_widget.dart';
import 'package:unify/core/design_system/tokens.dart';
import 'package:unify/core/design_system/typography.dart';
import 'package:unify/core/extensions/theme_extensions.dart';

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
                color: context.cardBg,
                padding: const EdgeInsets.fromLTRB(USpacing.base, USpacing.sm, USpacing.base, USpacing.sm),
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search by name...',
                    prefixIcon: Icon(Icons.search, color: context.textSecondary),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                            icon: Icon(Icons.close, size: 18, color: context.textSecondary),
                          )
                        : null,
                    filled: true,
                    fillColor: context.cardBg,
                    border: OutlineInputBorder(
                      borderRadius: URadius.mdAll,
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(USpacing.lg, USpacing.md, USpacing.lg, USpacing.xs),
                child: Row(
                  children: [
                    Text(
                      '${filtered.length} members',
                      style: UText.labelS.copyWith(color: context.textSecondary),
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
                            Icon(Icons.people_outline, size: 48, color: context.textSecondary),
                            const SizedBox(height: USpacing.md),
                            Text(
                              searchQuery.isEmpty ? 'No members found' : 'No members matching "$searchQuery"',
                              style: UText.bodyS.copyWith(color: context.textSecondary),
                            ),
                          ],
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.only(bottom: USpacing.base),
                        children: [
                          if (managers.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: USpacing.lg, vertical: USpacing.xs),
                              child: Text(
                                'Community Leaders',
                                style: UText.caption.copyWith(color: context.textSecondary),
                              ),
                            ),
                            const SizedBox(height: USpacing.xs),
                            ...managers.map((m) => _MemberListTile(
                              member: m,
                              isManager: true,
                            )),
                          ],
                          if (regulars.isNotEmpty) ...[
                            if (managers.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: USpacing.lg, vertical: USpacing.xs),
                                child: Divider(color: context.borderCol),
                              ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: USpacing.lg, vertical: USpacing.xs),
                              child: Text(
                                'Members',
                                style: UText.caption.copyWith(color: context.textSecondary),
                              ),
                            ),
                            const SizedBox(height: USpacing.xs),
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
        backgroundColor: context.cardBg,
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
              style: UText.labelL,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (isVerified) ...[
            const SizedBox(width: USpacing.xs),
            Icon(Icons.verified, color: Theme.of(context).colorScheme.primary, size: 18),
          ],
          if (isManager) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: USpacing.sm, vertical: 2),
              decoration: BoxDecoration(
                color: role == 'owner'
                    ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                    : context.cardBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                role == 'owner' ? 'Owner' : 'Manager',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: role == 'owner' ? Theme.of(context).colorScheme.primary : context.textSecondary,
                ),
              ),
            ),
          ],
        ],
      ),
      subtitle: programme != null || level != null
          ? Text(
              [programme, level].nonNulls.join(' · '),
              style: UText.bodyXS.copyWith(color: context.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      onTap: () => context.push('/app/profile'),
    );
  }
}
