import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../../data/models/opportunity_models.dart';
import '../providers/opportunities_provider.dart';
import '../widgets/opportunity_card.dart';

class OpportunitiesHomeScreen extends ConsumerWidget {
  const OpportunitiesHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedAsync = ref.watch(opportunitiesProvider);
    final recsAsync = ref.watch(recommendedOpportunitiesProvider);

    return Scaffold(
      backgroundColor: context.bg,
      body: RefreshIndicator(
        color: context.primary,
        onRefresh: () async {
          ref.invalidate(opportunitiesProvider);
          ref.invalidate(recommendedOpportunitiesProvider);
          ref.invalidate(featuredOpportunitiesProvider);
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: context.appBarBg,
              surfaceTintColor: context.appBarBg,
              pinned: true,
              elevation: 0,
              scrolledUnderElevation: 0.6,
              shadowColor: context.borderCol,
              title: Text('Opportunities',
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 19,
                      color: context.textPrimary)),
              actions: [
                IconButton(
                  icon: Icon(Icons.alarm_rounded, color: context.textPrimary),
                  tooltip: 'Deadlines',
                  onPressed: () => context.push('/opportunities/deadlines'),
                ),
                IconButton(
                  icon: Icon(Icons.bookmark_border_rounded,
                      color: context.textPrimary),
                  tooltip: 'Saved',
                  onPressed: () => context.push('/opportunities/saved'),
                ),
                const SizedBox(width: 4),
              ],
            ),

            // Search bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: GestureDetector(
                  onTap: () => context.push('/opportunities/search'),
                  child: Container(
                    height: 46,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: context.cardBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: context.borderCol),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search_rounded,
                            color: context.textSecondary, size: 21),
                        const SizedBox(width: 10),
                        Text('Search scholarships, internships…',
                            style: TextStyle(
                                color: context.textSecondary, fontSize: 14)),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Hero / tracker CTA
            const SliverToBoxAdapter(child: _TrackerBanner()),

            // Type chips
            SliverToBoxAdapter(
              child: SizedBox(
                height: 96,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  itemCount: OpportunityType.values.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (_, i) {
                    final t = OpportunityType.values[i];
                    return _TypeChip(
                      type: t,
                      onTap: () =>
                          context.push('/opportunities/type/${t.key}'),
                    );
                  },
                ),
              ),
            ),

            // Recommendations
            SliverToBoxAdapter(
              child: recsAsync.maybeWhen(
                data: (recs) {
                  if (recs.isEmpty) return const SizedBox.shrink();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
                        child: _SectionHeader(
                          title: 'Recommended for you',
                          subtitle: 'Matched to your field and level',
                        ),
                      ),
                      SizedBox(
                        height: 168,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: recs.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 12),
                          itemBuilder: (_, i) => _RecCard(
                            opportunity: recs[i],
                            onTap: () => context.push(
                                '/opportunities/detail/${recs[i].id}'),
                          ),
                        ),
                      ),
                    ],
                  );
                },
                orElse: () => const SizedBox.shrink(),
              ),
            ),

            // Feed header
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: _SectionHeader(title: 'Latest opportunities'),
              ),
            ),

            // Feed
            feedAsync.when(
              loading: () => const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (e, _) => SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.wifi_off_rounded,
                            size: 40, color: context.textDisabled),
                        const SizedBox(height: 12),
                        const Text('Could not load opportunities',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text('Showing cached items when offline.',
                            style: TextStyle(
                                fontSize: 12, color: context.textSecondary)),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: () =>
                              ref.invalidate(opportunitiesProvider),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              data: (items) {
                if (items.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(
                        child: Text('No opportunities yet. Check back soon.',
                            style: TextStyle(color: context.textSecondary)),
                      ),
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => OpportunityCard(
                        opportunity: items[i],
                        onTap: () => context
                            .push('/opportunities/detail/${items[i].id}'),
                      ),
                      childCount: items.length,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TrackerBanner extends StatelessWidget {
  const _TrackerBanner();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/opportunities/tracker'),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0066FF), Color(0xFF7C3AED)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: context.cardBg.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.track_changes_rounded,
                  color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Track your applications',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14)),
                  SizedBox(height: 2),
                  Text('From discovery to offer — never miss a deadline.',
                      style:
                          TextStyle(color: Colors.white70, fontSize: 11.5)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  const _SectionHeader({required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: context.textPrimary)),
        if (subtitle != null)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(subtitle!,
                style:
                    TextStyle(fontSize: 12, color: context.textSecondary)),
          ),
      ],
    );
  }
}

class _TypeChip extends StatelessWidget {
  final OpportunityType type;
  final VoidCallback onTap;
  const _TypeChip({required this.type, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 72,
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: type.color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(type.icon, color: type.color, size: 26),
            ),
            const SizedBox(height: 6),
            Text(
              type.label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 10.5,
                  height: 1.1,
                  fontWeight: FontWeight.w600,
                  color: context.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecCard extends StatelessWidget {
  final OpportunityModel opportunity;
  final VoidCallback onTap;
  const _RecCard({required this.opportunity, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final o = opportunity;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 240,
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
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: o.type.color.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(o.type.icon, color: o.type.color, size: 20),
                ),
                const Spacer(),
                if (o.isVerified)
                  Icon(Icons.verified_rounded,
                      size: 16, color: o.type.color),
              ],
            ),
            const SizedBox(height: 10),
            Text(o.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    height: 1.25)),
            const SizedBox(height: 4),
            Text(o.organization ?? o.type.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    TextStyle(fontSize: 12, color: context.textSecondary)),
            const Spacer(),
            Row(
              children: [
                Icon(Icons.schedule_rounded,
                    size: 13,
                    color: o.isClosingSoon
                        ? AppColors.error
                        : AppColors.grey3),
                const SizedBox(width: 4),
                Text(o.deadlineLabel,
                    style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: o.isClosingSoon
                            ? AppColors.error
                            : AppColors.grey2)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
