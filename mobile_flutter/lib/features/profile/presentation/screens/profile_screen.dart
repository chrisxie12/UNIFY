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
            onPressed: () {}, // TODO: settings screen
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
                        (profile?.displayName?.isNotEmpty == true)
                            ? profile!.displayName![0].toUpperCase()
                            : 'U',
                        style: AppTextStyles.h1.copyWith(color: AppColors.primaryLight),
                      )
                    : null,
              ),
              const SizedBox(height: 16),
              Text(
                profile?.displayName ?? 'Unknown Student',
                style: AppTextStyles.h2,
              ),
              const SizedBox(height: 4),
              Text(profile?.email ?? '', style: AppTextStyles.body),
              const SizedBox(height: 24),

              // Info cards
              _InfoCard(
                children: [
                  _InfoRow(
                    label: 'Programme',
                    value: profile?.programme ?? '—',
                  ),
                  const Divider(height: 1),
                  _InfoRow(
                    label: 'Year of Study',
                    value: profile?.yearOfStudy != null
                        ? 'Year ${profile!.yearOfStudy}'
                        : '—',
                  ),
                  const Divider(height: 1),
                  _InfoRow(
                    label: 'Role',
                    value: profile?.role ?? 'student',
                  ),
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
          Text(value, style: AppTextStyles.bodySemi),
        ],
      ),
    );
  }
}
