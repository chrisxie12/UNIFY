import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);

    return profileAsync.when(
      loading: () => const Scaffold(
        backgroundColor: AppColors.white,
        body: ProfileShimmer(),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: AppColors.white,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Could not load profile', style: AppTextStyles.headingS),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref.read(profileProvider.notifier).refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      data: (profile) {
        final supaUser = Supabase.instance.client.auth.currentUser;
        final email = supaUser?.email ?? '';
        final name = profile?.fullName ?? '';
        final initial =
            name.isNotEmpty ? name[0].toUpperCase() : email.isNotEmpty ? email[0].toUpperCase() : 'U';
        final isVerified = profile?.isVerified ?? false;
        final isAdmin = profile?.isAdmin ?? false;

        return Scaffold(
          backgroundColor: AppColors.white,
          body: CustomScrollView(
            slivers: [
              // Blue cover bar
              SliverAppBar(
                expandedHeight: 160,
                pinned: true,
                backgroundColor: AppColors.primary,
                leading: const SizedBox.shrink(),
                actions: [
                  if (isAdmin)
                    IconButton(
                      icon: const Icon(Icons.admin_panel_settings_outlined,
                          color: Colors.white),
                      onPressed: () => context.push('/admin'),
                      tooltip: 'Admin',
                    ),
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined,
                        color: Colors.white),
                    onPressed: () => context.push('/notifications'),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: AppColors.brandGradient,
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar overlapping the cover
                      Transform.translate(
                        offset: const Offset(0, -36),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.white,
                                  width: 4,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  initial,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () => context.push('/onboarding'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColors.border),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Edit profile',
                                  style: AppTextStyles.labelM,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Transform.translate(
                        offset: const Offset(0, -20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Name
                            Text(
                              name.isNotEmpty ? name : 'Your Profile',
                              style: AppTextStyles.headingL,
                            ),
                            const SizedBox(height: 4),

                            // Verification badge
                            Row(
                              children: [
                                Icon(
                                  isVerified
                                      ? Icons.verified_rounded
                                      : Icons.schedule_rounded,
                                  size: 14,
                                  color: isVerified
                                      ? AppColors.success
                                      : AppColors.grey3,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isVerified
                                      ? 'Verified student'
                                      : 'Verification pending',
                                  style: AppTextStyles.bodyS.copyWith(
                                    color: isVerified
                                        ? AppColors.success
                                        : AppColors.grey3,
                                  ),
                                ),
                                if (isAdmin) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          AppColors.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      profile?.role.toUpperCase() ?? 'ADMIN',
                                      style: AppTextStyles.labelS.copyWith(
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),

                            // Programme / level
                            if (profile?.programme != null ||
                                profile?.level != null) ...[
                              const SizedBox(height: 6),
                              Text(
                                [
                                  if (profile?.programme != null)
                                    profile!.programme!,
                                  if (profile?.level != null)
                                    'Level ${profile!.level}',
                                ].join(' · '),
                                style: AppTextStyles.bodyS
                                    .copyWith(color: AppColors.grey2),
                              ),
                            ],

                            // Student ID
                            if (profile?.studentId != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                'ID: ${profile!.studentId}',
                                style: AppTextStyles.caption,
                              ),
                            ],

                            // Bio
                            if (profile?.bio != null &&
                                profile!.bio!.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Text(
                                profile.bio!,
                                style: AppTextStyles.bodyM
                                    .copyWith(color: AppColors.grey1),
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),
                      const Divider(color: AppColors.border),
                      const SizedBox(height: 20),

                      // Sign out
                      _SignOutButton(),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SignOutButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text('Log out', style: AppTextStyles.headingS),
            content: const Text('Are you sure you want to log out?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  'Log out',
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            ],
          ),
        );
        if (confirmed == true && context.mounted) {
          await ref.read(authNotifierProvider.notifier).signOut();
          if (context.mounted) context.go('/get-started');
        }
      },
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Text(
            'Log Out',
            style: AppTextStyles.labelL.copyWith(color: AppColors.error),
          ),
        ),
      ),
    );
  }
}
