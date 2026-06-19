import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/verified_badge.dart';
import '../../data/models/marketplace_models.dart';
import '../providers/marketplace_provider.dart';
import '../widgets/marketplace_constants.dart';

class FreelancersScreen extends ConsumerWidget {
  const FreelancersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(freelancersProvider);
    final category = ref.watch(freelancerCategoryProvider);

    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.appBarBg,
        surfaceTintColor: context.appBarBg,
        elevation: 0.6,
        shadowColor: context.borderCol,
        title: const Text('Student Freelancers',
            style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          TextButton(
            onPressed: () => context.push('/marketplace/freelancer-profile'),
            child: const Text('My profile'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Category filter chips
          SizedBox(
            height: 46,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _chip(context, ref, 'All', category == null, null),
                for (final c in kServiceCategories)
                  _chip(context, ref, c, category == c, c),
              ],
            ),
          ),
          Expanded(
            child: async.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => AppErrorWidget(e),
              data: (items) {
                if (items.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: const BoxDecoration(
                              color: context.cardBg,
                              shape: BoxShape.circle),
                          child: const Icon(Icons.handyman_outlined,
                              size: 32, color: context.textDisabled),
                        ),
                        const SizedBox(height: 14),
                        const Text('No freelancers yet',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text('Offer a service to be the first here.',
                            style: TextStyle(
                                fontSize: 13, color: context.textSecondary)),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: () => context
                              .push('/marketplace/freelancer-profile'),
                          style: FilledButton.styleFrom(
                              backgroundColor: context.primary),
                          child: const Text('Create freelancer profile'),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => _FreelancerCard(profile: items[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(BuildContext context, WidgetRef ref, String label,
      bool selected, String? value) {
    return Padding(
      padding: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
      child: GestureDetector(
        onTap: () =>
            ref.read(freelancerCategoryProvider.notifier).state = value,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: selected ? context.primary : context.cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: selected ? context.primary : context.borderCol),
          ),
          child: Text(label,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : context.textSecondary)),
        ),
      ),
    );
  }
}

class _FreelancerCard extends StatelessWidget {
  final FreelancerProfile profile;
  const _FreelancerCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          context.push('/marketplace/freelancer/${profile.userId}'),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.borderCol),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: const Color(0xFFDDE8FF),
                  backgroundImage: profile.avatar != null &&
                          profile.avatar!.isNotEmpty
                      ? CachedNetworkImageProvider(profile.avatar!)
                      : null,
                  child: profile.avatar == null || profile.avatar!.isEmpty
                      ? Text(profile.initials,
                          style: TextStyle(
                              color: context.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 18))
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(profile.name ?? 'Student',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700)),
                          ),
                          if (profile.verified) ...[
                            const SizedBox(width: 4),
                            const VerifiedBadge(
                                size: 15, tooltip: 'Verified Student'),
                          ],
                        ],
                      ),
                      if (profile.headline != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(profile.headline!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 12.5,
                                  color: context.textSecondary)),
                        ),
                    ],
                  ),
                ),
                if (profile.hourlyRate != null)
                  Text('GHS ${profile.hourlyRate!.toStringAsFixed(0)}/hr',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: context.primary)),
              ],
            ),
            if (profile.skills.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: profile.skills
                    .take(4)
                    .map((s) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: context.cardBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(s,
                              style: TextStyle(
                                  fontSize: 11, color: context.textSecondary)),
                        ))
                    .toList(),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.star_rounded,
                    size: 16, color: AppColors.warning),
                const SizedBox(width: 4),
                Text(
                    profile.reviewCount == 0
                        ? 'New'
                        : '${profile.rating.toStringAsFixed(1)} (${profile.reviewCount})',
                    style: const TextStyle(
                        fontSize: 12.5, fontWeight: FontWeight.w600)),
                const SizedBox(width: 16),
                const Icon(Icons.check_circle_outline_rounded,
                    size: 15, color: context.textDisabled),
                const SizedBox(width: 4),
                Text('${profile.completedJobs} jobs',
                    style: TextStyle(
                        fontSize: 12, color: context.textSecondary)),
                const Spacer(),
                if (profile.isAvailable)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('Available',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.success)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
