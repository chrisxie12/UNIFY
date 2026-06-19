import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/widgets/unify_snackbar.dart';

final _repProfileProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, userId) async {
  final client = ref.read(supabaseProvider);
  final profile = await client.from('profiles').select().filter('id', 'eq', userId).single();
  return profile;
});

final _repVerificationRequestsProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, userId) async {
  final client = ref.read(supabaseProvider);
  final data = await client.from('verification_requests').select().filter('user_id', 'eq', userId).order('created_at', ascending: false);
  return (data as List).cast<Map<String, dynamic>>();
});

final _repVerificationLogProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, userId) async {
  final client = ref.read(supabaseProvider);
  final data = await client.from('verification_log').select('*, profiles!verification_log_performed_by_fkey(display_name)').filter('target_user_id', 'eq', userId).order('created_at', ascending: false);
  return (data as List).cast<Map<String, dynamic>>();
});

final _repManagedCommunitiesProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, userId) async {
  final client = ref.read(supabaseProvider);
  final data = await client.from('community_managers').select('*, communities(name, community_type)').filter('user_id', 'eq', userId).filter('is_active', 'eq', true);
  return (data as List).cast<Map<String, dynamic>>();
});

final _repRecentPostsProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, userId) async {
  final client = ref.read(supabaseProvider);
  final data = await client.from('community_posts').select('title, body, post_type, created_at, community_id').filter('author_id', 'eq', userId).order('created_at', ascending: false).limit(5);
  return (data as List).cast<Map<String, dynamic>>();
});

class RepresentativeDetailScreen extends ConsumerStatefulWidget {
  final String userId;
  final String? initialStatus;

  const RepresentativeDetailScreen({
    super.key,
    required this.userId,
    this.initialStatus,
  });

  @override
  ConsumerState<RepresentativeDetailScreen> createState() => _RepresentativeDetailScreenState();
}

class _RepresentativeDetailScreenState extends ConsumerState<RepresentativeDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(_repProfileProvider(widget.userId));
      ref.invalidate(_repVerificationRequestsProvider(widget.userId));
      ref.invalidate(_repVerificationLogProvider(widget.userId));
      ref.invalidate(_repManagedCommunitiesProvider(widget.userId));
      ref.invalidate(_repRecentPostsProvider(widget.userId));
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(_repProfileProvider(widget.userId));
    final verifReqsAsync = ref.watch(_repVerificationRequestsProvider(widget.userId));
    final verifLogAsync = ref.watch(_repVerificationLogProvider(widget.userId));
    final managedAsync = ref.watch(_repManagedCommunitiesProvider(widget.userId));
    final postsAsync = ref.watch(_repRecentPostsProvider(widget.userId));

    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        title: const Text('Representative Detail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              ref.invalidate(_repProfileProvider(widget.userId));
              ref.invalidate(_repVerificationRequestsProvider(widget.userId));
              ref.invalidate(_repVerificationLogProvider(widget.userId));
              ref.invalidate(_repManagedCommunitiesProvider(widget.userId));
              ref.invalidate(_repRecentPostsProvider(widget.userId));
            },
          ),
        ],
      ),
      body: profileAsync.when(
        data: (profile) {
          final status = widget.initialStatus ?? profile['verification_status'] as String? ?? 'unverified';
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(_repProfileProvider(widget.userId));
              ref.invalidate(_repVerificationRequestsProvider(widget.userId));
              ref.invalidate(_repVerificationLogProvider(widget.userId));
              ref.invalidate(_repManagedCommunitiesProvider(widget.userId));
              ref.invalidate(_repRecentPostsProvider(widget.userId));
            },
            child: ListView(
              padding: const EdgeInsets.only(bottom: 32),
              children: [
                _ProfileHeader(profile: profile, status: status),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      _VerificationBadge(status: status),
                      const SizedBox(height: 20),
                      _DetailSection(profile: profile),
                      const SizedBox(height: 24),
                      verifReqsAsync.when(
                        data: (reqs) => _VerificationDocumentsSection(requests: reqs),
                        error: (e, _) => _SectionError(message: ErrorMapper.toUserMessage(e)),
                        loading: () => _SectionLoading(),
                      ),
                      const SizedBox(height: 24),
                      verifLogAsync.when(
                        data: (logs) => _VerificationHistorySection(logs: logs),
                        error: (e, _) => _SectionError(message: ErrorMapper.toUserMessage(e)),
                        loading: () => _SectionLoading(),
                      ),
                      const SizedBox(height: 24),
                      managedAsync.when(
                        data: (managers) => _ManagedCommunitiesSection(managers: managers),
                        error: (e, _) => _SectionError(message: ErrorMapper.toUserMessage(e)),
                        loading: () => _SectionLoading(),
                      ),
                      const SizedBox(height: 24),
                      postsAsync.when(
                        data: (posts) => _RecentActivitySection(posts: posts),
                        error: (e, _) => _SectionError(message: ErrorMapper.toUserMessage(e)),
                        loading: () => _SectionLoading(),
                      ),
                      const SizedBox(height: 24),
                      if (status == 'pending') _ActionButtons(profile: profile, userId: widget.userId),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
                const SizedBox(height: 12),
                Text('Error loading profile', style: TextStyle(fontSize: 15, color: context.textSecondary, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(ErrorMapper.toUserMessage(e), style: const TextStyle(fontSize: 13, color: AppColors.grey3));
                const SizedBox(height: 16),
                FilledButton.tonalIcon(
                  onPressed: () => ref.invalidate(_repProfileProvider(widget.userId)),
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final Map<String, dynamic> profile;
  final String status;
  const _ProfileHeader({required this.profile, required this.status});

  @override
  Widget build(BuildContext context) {
    final name = profile['display_name'] as String? ?? profile['full_name'] as String? ?? 'Unknown User';
    final avatarUrl = profile['avatar_url'] as String?;
    final isVerified = profile['is_verified_leader'] == true;
    final initials = name.split(' ').where((w) => w.isNotEmpty).take(2).map((w) => w[0].toUpperCase()).join();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Theme.of(context).colorScheme.primary, const Color(0xFF0047DD)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 16, bottom: 32),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Stack(
            children: [
              CircleAvatar(
                radius: 42,
                backgroundColor: AppColors.white.withValues(alpha: 0.3),
                child: CircleAvatar(
                  radius: 39,
                  backgroundColor: Colors.white,
                  backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                  child: avatarUrl == null
                      ? Text(initials, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: context.primary))
                      : null,
                ),
              ),
              if (isVerified)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: context.cardBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.verified_rounded, size: 18, color: Theme.of(context).colorScheme.primary),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(height: 4),
          if (profile['email'] != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                profile['email'] as String,
                style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.8)),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}

class _VerificationBadge extends StatelessWidget {
  final String status;
  const _VerificationBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final badgeData = switch (status) {
      'verified' => (const Icon(Icons.check_circle_rounded, size: 16, color: AppColors.success), 'Verified', AppColors.success),
      'pending' => (const Icon(Icons.access_time_rounded, size: 16, color: AppColors.warning), 'Pending', AppColors.warning),
      'rejected' => (const Icon(Icons.cancel_rounded, size: 16, color: AppColors.error), 'Rejected', AppColors.error),
      _ => (Icon(Icons.person_outline_rounded, size: 16, color: context.textSecondary), 'Regular Student', AppColors.grey2),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: badgeData.$3.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeData.$3.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          badgeData.$1,
          const SizedBox(width: 8),
          Text(badgeData.$2, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: badgeData.$3)),
        ],
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  final Map<String, dynamic> profile;
  const _DetailSection({required this.profile});

  @override
  Widget build(BuildContext context) {
    final items = <MapEntry<String, String>>[
      if (profile['programme'] != null) MapEntry('Programme', profile['programme'] as String),
      if (profile['department'] != null) MapEntry('Department', profile['department'] as String),
      if (profile['level'] != null) MapEntry('Level', 'Level ${profile['level']}'),
      if (profile['student_id'] != null) MapEntry('Student ID', profile['student_id'] as String),
      if (profile['leadership_role'] != null) MapEntry('Position', profile['leadership_role'] as String),
      if (profile['academic_year'] != null) MapEntry('Academic Year', profile['academic_year'] as String),
    ];

    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderCol),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_outline_rounded, size: 16, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text('Profile Details', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: context.textPrimary)),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 110,
                  child: Text(item.key, style: TextStyle(fontSize: 12, color: context.textSecondary)),
                ),
                Expanded(
                  child: Text(item.value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: context.textPrimary)),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

class _VerificationDocumentsSection extends StatelessWidget {
  final List<Map<String, dynamic>> requests;
  const _VerificationDocumentsSection({required this.requests});

  @override
  Widget build(BuildContext context) {
    final urls = <String>[];
    for (final req in requests) {
      final evidence = req['evidence_url'] as String?;
      if (evidence != null && evidence.isNotEmpty) urls.add(evidence);
      final docs = req['document_urls'] as List?;
      if (docs != null) {
        for (final doc in docs) {
          if (doc is String && doc.isNotEmpty) urls.add(doc);
        }
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderCol),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.description_rounded, size: 16, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text('Verification Documents', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: context.textPrimary)),
              const Spacer(),
              Text('${urls.length}', style: TextStyle(fontSize: 12, color: context.textSecondary)),
            ],
          ),
          const SizedBox(height: 12),
          if (urls.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text('No documents submitted', style: TextStyle(fontSize: 13, color: context.textDisabled)),
              ),
            )
          else
            ...urls.map((url) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () => _viewDocument(context, url),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF4FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.insert_drive_file_rounded, size: 18, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          url.split('/').last.split('?').first,
                          style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('View', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary)),
                      ),
                    ],
                  ),
                ),
              ),
            )),
        ],
      ),
    );
  }

  void _viewDocument(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.visibility_rounded, size: 18, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            const Expanded(child: Text('Document', style: TextStyle(fontSize: 16))),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              url,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.link_rounded, size: 40, color: context.textDisabled),
                  const SizedBox(height: 8),
                  Text('Could not load image', style: TextStyle(color: context.textDisabled)),
                  const SizedBox(height: 12),
                  FilledButton.tonal(
                    onPressed: () => _openUrl(url),
                    child: const Text('Open in Browser'),
                  ),
                ],
              ),
              loadingBuilder: (_, child, progress) {
                if (progress == null) return child;
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))],
      ),
    );
  }

  void _openUrl(String url) {
    // Intent-based URL opening handled by platform-specific code
  }
}

class _VerificationHistorySection extends StatelessWidget {
  final List<Map<String, dynamic>> logs;
  const _VerificationHistorySection({required this.logs});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderCol),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.history_rounded, size: 16, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text('Verification History', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: context.textPrimary)),
              const Spacer(),
              Text('${logs.length}', style: TextStyle(fontSize: 12, color: context.textSecondary)),
            ],
          ),
          const SizedBox(height: 12),
          if (logs.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text('No verification history', style: TextStyle(fontSize: 13, color: context.textDisabled)),
              ),
            )
          else
            ...logs.map((log) => _buildLogEntry(context, log)),
        ],
      ),
    );
  }

  Widget _buildLogEntry(BuildContext context, Map<String, dynamic> log) {
    final action = log['action'] as String? ?? 'unknown';
    final createdAt = log['created_at'] as String?;
    final performedBy = log['profiles'] is Map ? (log['profiles'] as Map)['display_name'] as String? : null;
    final notes = log['notes'] as String?;

    final actionData = switch (action) {
      'approved' => (Icons.check_circle_rounded, AppColors.success, 'Approved'),
      'rejected' => (Icons.cancel_rounded, AppColors.error, 'Rejected'),
      'submitted' => (Icons.send_rounded, AppColors.warning, 'Submitted'),
      _ => (Icons.circle_rounded, AppColors.grey2, action[0].toUpperCase() + action.substring(1)),
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: actionData.$2.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(actionData.$1, size: 16, color: actionData.$2),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(actionData.$3, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: actionData.$2)),
                if (performedBy != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text('by $performedBy', style: TextStyle(fontSize: 11, color: context.textSecondary)),
                  ),
                if (notes != null && notes.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(notes, style: TextStyle(fontSize: 11, color: context.textDisabled, fontStyle: FontStyle.italic)),
                  ),
                if (createdAt != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(_timeAgo(DateTime.parse(createdAt)), style: TextStyle(fontSize: 10, color: context.textDisabled)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

class _ManagedCommunitiesSection extends StatelessWidget {
  final List<Map<String, dynamic>> managers;
  const _ManagedCommunitiesSection({required this.managers});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderCol),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.groups_rounded, size: 16, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text('Communities Managed', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: context.textPrimary)),
              const Spacer(),
              Text('${managers.length}', style: TextStyle(fontSize: 12, color: context.textSecondary)),
            ],
          ),
          const SizedBox(height: 12),
          if (managers.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text('Not managing any communities', style: TextStyle(fontSize: 13, color: context.textDisabled)),
              ),
            )
          else
            ...managers.map((m) {
              final community = m['communities'] as Map?;
              final name = community?['name'] as String? ?? 'Unknown Community';
              final type = community?['community_type'] as String?;
              final typeLabel = _typeLabel(type);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: context.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.group_rounded, size: 18, color: context.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: context.textPrimary)),
                          if (typeLabel != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 1),
                              child: Text(typeLabel, style: TextStyle(fontSize: 11, color: context.textSecondary)),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  String? _typeLabel(String? type) => switch (type) {
    'class' => 'Class Community',
    'level' => 'Level Community',
    'department' => 'Department Community',
    'faculty' => 'Faculty Community',
    'club' => 'Club',
    'university' => 'University Community',
    _ => type,
  };
}

class _RecentActivitySection extends StatelessWidget {
  final List<Map<String, dynamic>> posts;
  const _RecentActivitySection({required this.posts});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderCol),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.article_rounded, size: 16, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text('Recent Activity', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: context.textPrimary)),
            ],
          ),
          const SizedBox(height: 12),
          if (posts.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text('No recent activity', style: TextStyle(fontSize: 13, color: context.textDisabled)),
              ),
            )
          else
            ...posts.map((p) {
              final title = p['title'] as String?;
              final body = p['body'] as String?;
              final createdAt = p['created_at'] as String?;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: context.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.article_rounded, size: 16, color: context.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (title != null && title.isNotEmpty)
                            Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: context.textPrimary)),
                          if (body != null && body.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                body,
                                style: TextStyle(fontSize: 11, color: context.textSecondary),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          if (createdAt != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(_timeAgo(DateTime.parse(createdAt)), style: TextStyle(fontSize: 10, color: context.textDisabled)),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

class _ActionButtons extends ConsumerWidget {
  final Map<String, dynamic> profile;
  final String userId;
  const _ActionButtons({required this.profile, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderCol),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.gavel_rounded, size: 16, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text('Verification Actions', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: context.textPrimary)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _handleAction(context, ref, 'rejected'),
                  icon: const Icon(Icons.close_rounded, size: 16),
                  label: const Text('Reject'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _handleAction(context, ref, 'approved'),
                  icon: const Icon(Icons.check_rounded, size: 16),
                  label: const Text('Approve'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.success,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handleAction(BuildContext context, WidgetRef ref, String status) async {
    final notesCtrl = TextEditingController();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(status == 'approved' ? 'Approve Verification?' : 'Reject Verification?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(status == 'approved'
                ? 'This will mark the user as a verified leader.'
                : 'The user will be notified of the rejection.'),
            const SizedBox(height: 12),
            TextField(
              controller: notesCtrl,
              decoration: InputDecoration(
                hintText: 'Admin notes (optional)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(status == 'approved' ? 'Approve' : 'Reject',
                style: TextStyle(color: status == 'approved' ? AppColors.success : AppColors.error, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      final client = ref.read(supabaseProvider);
      final admin = client.auth.currentUser;
      if (admin == null) return;

      final pendingReqs = await client
          .from('verification_requests')
          .select('id')
          .filter('user_id', 'eq', userId)
          .filter('status', 'eq', 'pending');
      for (final req in pendingReqs) {
        await client.from('verification_requests').update({
          'status': status,
          'admin_notes': notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
          'reviewed_by': admin.id,
          'reviewed_at': DateTime.now().toUtc().toIso8601String(),
        }).eq('id', req['id']);
      }

      if (status == 'approved') {
        await client.from('profiles').update({
          'is_verified_leader': true,
          'verification_status': 'verified',
        }).eq('id', userId);
      } else {
        await client.from('profiles').update({
          'verification_status': 'rejected',
        }).eq('id', userId);
      }

      await client.from('verification_log').insert({
        'target_user_id': userId,
        'action': status == 'approved' ? 'approved' : 'rejected',
        'performed_by': admin.id,
        'notes': notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
      });

      ref.invalidate(_repProfileProvider(userId));
      ref.invalidate(_repVerificationRequestsProvider(userId));
      ref.invalidate(_repVerificationLogProvider(userId));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(status == 'approved' ? 'Leader verified!' : 'Request rejected.'),
            backgroundColor: status == 'approved' ? AppColors.success : AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, 'refresh');
      }
    } catch (e) {
      if (context.mounted) {
        UnifySnackbar.error(context, ErrorMapper.toUserMessage(e));
      }
    }
  }
}

class _SectionLoading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }
}

class _SectionError extends StatelessWidget {
  final String message;
  const _SectionError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderCol),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded, size: 24, color: AppColors.error),
          const SizedBox(height: 8),
          Text(message, style: TextStyle(fontSize: 13, color: context.textSecondary), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
