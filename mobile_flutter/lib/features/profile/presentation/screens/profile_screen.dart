import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: AppTextStyles.h3),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (profile) => SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar
              CircleAvatar(
                radius: 48,
                backgroundColor: AppColors.surface,
                backgroundImage: profile?.avatarUrl != null
                    ? NetworkImage(profile!.avatarUrl!)
                    : null,
                child: profile?.avatarUrl == null
                    ? Text(
                        profile?.initials ?? 'U',
                        style: AppTextStyles.h1.copyWith(color: AppColors.primaryLight),
                      )
                    : null,
              ),
              const SizedBox(height: 16),

              // Name
              Text(
                profile?.displayName ?? profile?.email.split('@').first ?? 'No name set',
                style: AppTextStyles.h2,
              ),
              const SizedBox(height: 4),
              Text(profile?.email ?? '', style: AppTextStyles.body),

              // Incomplete profile prompt
              if (profile != null && !profile.isComplete) ...[
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => context.go('/onboarding'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primaryLight.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.edit_outlined, size: 16, color: AppColors.primaryLight),
                        const SizedBox(width: 8),
                        Text(
                          'Complete your profile',
                          style: AppTextStyles.caption.copyWith(color: AppColors.primaryLight),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Info card
              _InfoCard(
                children: [
                  if (profile?.school != null) ...[
                    _InfoRow(label: 'School', value: profile!.school!),
                    const Divider(height: 1),
                  ],
                  _InfoRow(label: 'Programme', value: profile?.programme ?? '—'),
                  const Divider(height: 1),
                  _InfoRow(
                    label: 'Year of Study',
                    value: profile?.yearOfStudy != null ? 'Year ${profile!.yearOfStudy}' : '—',
                  ),
                  const Divider(height: 1),
                  _InfoRow(label: 'Role', value: profile?.role ?? 'student'),
                ],
              ),

              const SizedBox(height: 32),

              AppButton(
                label: 'Sign Out',
                variant: AppButtonVariant.danger,
                onTap: () async {
                  await ref.read(authNotifierProvider.notifier).signOut();
                  if (context.mounted) context.go('/get-started');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(children: children),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.body),
          Flexible(
            child: Text(
              value,
              style: AppTextStyles.bodySemi,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
