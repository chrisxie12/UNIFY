import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/unify_snackbar.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../../../leadership/presentation/providers/leadership_provider.dart';
import '../../domain/entities/profile.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  final String? viewUserId;
  const ProfileScreen({super.key, this.viewUserId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserId = ref.read(supabaseProvider).auth.currentUser?.id;
    final isOwnProfile = viewUserId == null || viewUserId == currentUserId;

    final profileAsync = isOwnProfile
        ? ref.watch(profileProvider)
        : ref.watch(viewProfileProvider(viewUserId!));
    final statsAsync = isOwnProfile
        ? ref.watch(profileStatsProvider)
        : const AsyncValue.data(null);

    if (isOwnProfile) {
      ref.watch(userBadgesProvider);
      ref.watch(userLeadershipProvider);
      ref.watch(isVerifiedLeaderProvider);
    }

    return Scaffold(
      backgroundColor: context.bg,
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => AppErrorWidget(
          e,
          onRetry:
              isOwnProfile ? () => ref.invalidate(profileProvider) : null,
        ),
        data: (profile) {
          if (profile == null) {
            return const AppErrorWidget('Profile not found.');
          }
          return _Body(
            profile: profile,
            postCount: statsAsync.valueOrNull?.postCount ?? 0,
          );
        },
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final Profile profile;
  final int postCount;

  const _Body({
    required this.profile,
    required this.postCount,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: _buildTopBar(context)),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        SliverToBoxAdapter(child: _buildAvatarAndStats(context)),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        SliverToBoxAdapter(child: _buildBioSection(context)),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        SliverToBoxAdapter(child: _buildEditButton(context)),
        const SliverToBoxAdapter(child: SizedBox(height: 4)),
        SliverToBoxAdapter(child: _buildTabRow(context)),
        SliverToBoxAdapter(child: _buildPostGrid(context)),
      ],
    );
  }

  Widget _buildTopBar(BuildContext context) {
    final name =
        profile.displayName ?? profile.email.split('@').first;
    return Padding(
      padding: EdgeInsets.fromLTRB(
          16, MediaQuery.of(context).padding.top + 8, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: context.textPrimary),
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: context.textPrimary),
            onSelected: (v) {
              if (v == 'settings') context.push('/app/profile/settings');
              if (v == 'share') {
                UnifySnackbar.info(context, 'Share link copied');
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                  value: 'share', child: Text('Share Profile')),
              const PopupMenuItem(
                  value: 'settings', child: Text('Settings')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarAndStats(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildAvatar(),
          const SizedBox(width: 24),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _statColumn(context, '$postCount', 'Posts'),
                _statColumn(context, '0', 'Hubs'),
                _statColumn(context, '0', 'Events'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    if (profile.avatarUrl?.isNotEmpty == true) {
      return CircleAvatar(
        radius: 40,
        backgroundImage: CachedNetworkImageProvider(profile.avatarUrl!),
      );
    }
    return Container(
      width: 80,
      height: 80,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF2563EB),
      ),
      child: Center(
        child: Text(
          profile.initials,
          style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.white),
        ),
      ),
    );
  }

  Widget _statColumn(BuildContext context, String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: context.textPrimary),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: context.textSecondary),
        ),
      ],
    );
  }

  Widget _buildBioSection(BuildContext context) {
    final parts = <String>[];
    if (profile.programme?.isNotEmpty == true) parts.add(profile.programme!);
    if (profile.school?.isNotEmpty == true) parts.add(profile.school!);
    if (profile.yearOfStudy != null) parts.add('Year ${profile.yearOfStudy}');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            profile.displayName ?? profile.email.split('@').first,
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: context.textPrimary),
          ),
          if (parts.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              parts.join(' \u00b7 '),
              style:
                  TextStyle(fontSize: 13, color: context.textSecondary),
            ),
          ],
          if (profile.campus?.isNotEmpty == true) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.location_on_outlined,
                    size: 13, color: context.textSecondary),
                const SizedBox(width: 3),
                Text(
                  profile.campus!,
                  style:
                      TextStyle(fontSize: 13, color: context.textSecondary),
                ),
              ],
            ),
          ],
          if (profile.bio?.isNotEmpty == true) ...[
            const SizedBox(height: 6),
            Text(
              profile.bio!,
              style: TextStyle(
                  fontSize: 13,
                  color: context.textSecondary,
                  height: 1.4),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEditButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: OutlinedButton(
        onPressed: () => context.push('/app/profile/edit'),
        style: OutlinedButton.styleFrom(
          foregroundColor: context.textPrimary,
          side: BorderSide(color: context.borderCol),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
          minimumSize: const Size(double.infinity, 42),
        ),
        child: const Text('Edit Profile'),
      ),
    );
  }

  Widget _buildTabRow(BuildContext context) {
    return Column(
      children: [
        Divider(height: 1, color: context.borderCol),
        Row(
          children: [
            _tabItem(context, Icons.grid_on, true),
            _tabItem(context, Icons.bookmark_border, false),
          ],
        ),
        Divider(height: 1, color: context.borderCol),
      ],
    );
  }

  Widget _tabItem(BuildContext context, IconData icon, bool isActive) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? const Color(0xFF2563EB) : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Icon(
          icon,
          color: isActive
              ? const Color(0xFF2563EB)
              : context.textSecondary,
          size: 22,
        ),
      ),
    );
  }

  Widget _buildPostGrid(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(2),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: 9,
      itemBuilder: (_, __) => Container(
        color: Colors.grey.shade200,
        child:
            Icon(Icons.image_outlined, color: Colors.grey.shade400, size: 30),
      ),
    );
  }
}
