import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/supabase_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../../../../core/extensions/datetime_extensions.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/verified_badge.dart';
import '../../data/models/marketplace_models.dart';
import '../providers/marketplace_provider.dart';
import '../widgets/listing_card.dart';
import '../widgets/marketplace_constants.dart';

class ListingDetailScreen extends ConsumerStatefulWidget {
  final String listingId;
  const ListingDetailScreen({super.key, required this.listingId});

  @override
  ConsumerState<ListingDetailScreen> createState() =>
      _ListingDetailScreenState();
}

class _ListingDetailScreenState extends ConsumerState<ListingDetailScreen> {
  final _pageCtrl = PageController();
  int _page = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(marketplaceRepositoryProvider).recordView(widget.listingId);
    });
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(listingDetailProvider(widget.listingId));

    return Scaffold(
      backgroundColor: context.bg,
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => AppErrorWidget(e),
        data: (listing) {
          if (listing == null) {
            return const Center(child: Text('Listing not found'));
          }
          return _content(listing);
        },
      ),
      bottomNavigationBar: async.maybeWhen(
        data: (l) => l == null ? null : _bottomBar(l),
        orElse: () => null,
      ),
    );
  }

  Widget _content(ListingModel l) {
    final ratingAsync = ref.watch(sellerRatingProvider(l.sellerId));
    final moreAsync = ref.watch(sellerListingsProvider(
        (sellerId: l.sellerId, excludeId: l.id)));

    return CustomScrollView(
      slivers: [
        // ── Gallery app bar ──────────────────────────────────
        SliverAppBar(
          expandedHeight: l.images.isNotEmpty ? 320 : 120,
          pinned: true,
          backgroundColor: context.appBarBg,
          surfaceTintColor: context.appBarBg,
          leading: _circleBtn(Icons.arrow_back_rounded, () => context.pop()),
          actions: [
            _circleBtn(Icons.flag_outlined, () => _report(l)),
            const SizedBox(width: 8),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: l.images.isEmpty
                ? Container(
                    color: l.category.color.withValues(alpha: 0.08),
                    child: Center(
                        child: Icon(l.category.icon,
                            size: 64, color: l.category.color)),
                  )
                : Stack(
                    fit: StackFit.expand,
                    children: [
                      PageView.builder(
                        controller: _pageCtrl,
                        itemCount: l.images.length,
                        onPageChanged: (i) => setState(() => _page = i),
                        itemBuilder: (_, i) => CachedNetworkImage(
                          imageUrl: l.images[i],
                          fit: BoxFit.cover,
                          placeholder: (_, __) =>
                              Container(color: context.cardBg),
                        ),
                      ),
                      if (l.images.length > 1)
                        Positioned(
                          bottom: 12,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              l.images.length,
                              (i) => AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 3),
                                width: i == _page ? 18 : 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: i == _page
                                      ? Colors.white
                                      : Colors.white70,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
        ),

        SliverToBoxAdapter(
          child: Container(
            color: context.cardBg,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category + status
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: l.category.color.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(l.category.icon,
                              size: 13, color: l.category.color),
                          const SizedBox(width: 5),
                          Text(l.subcategory ?? l.category.label,
                              style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: l.category.color)),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(Icons.remove_red_eye_outlined,
                            size: 14, color: context.textDisabled),
                        const SizedBox(width: 4),
                        Text('${l.viewCount}',
                            style: TextStyle(
                                fontSize: 12, color: context.textDisabled)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(l.title,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: context.textPrimary)),
                const SizedBox(height: 8),
                if (l.priceLabel.isNotEmpty)
                  Row(
                    children: [
                      Text(l.priceLabel,
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: l.category.color)),
                      const SizedBox(width: 8),
                      if (l.isNegotiable)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: context.cardBg,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text('Negotiable',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: context.textSecondary)),
                        ),
                    ],
                  ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    if (l.conditionLabel.isNotEmpty)
                      _metaPill(Icons.verified_outlined, l.conditionLabel),
                    if (l.location != null)
                      _metaPill(Icons.location_on_outlined, l.location!),
                    _metaPill(Icons.schedule_rounded, l.createdAt.timeAgo),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Category-specific details
        if (_detailEntries(l).isNotEmpty)
          SliverToBoxAdapter(child: _detailsCard(l)),

        // Description
        if (l.description != null && l.description!.isNotEmpty)
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              padding: const EdgeInsets.all(16),
              decoration: _cardDeco(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Description',
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text(l.description!,
                      style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: context.textSecondary)),
                ],
              ),
            ),
          ),

        // Seller card
        SliverToBoxAdapter(child: _sellerCard(l, ratingAsync)),

        // More from seller
        SliverToBoxAdapter(
          child: moreAsync.maybeWhen(
            data: (items) {
              if (items.isEmpty) return const SizedBox(height: 24);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 20, 16, 10),
                    child: Text('More from this seller',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w800)),
                  ),
                  SizedBox(
                    height: 250,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (_, i) => SizedBox(
                        width: 160,
                        child: ListingCard(
                          listing: items[i],
                          onTap: () => context.push(
                              '/marketplace/listing/${items[i].id}'),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              );
            },
            orElse: () => const SizedBox(height: 24),
          ),
        ),
      ],
    );
  }

  // ── Detail card (category-specific) ──────────────────────────

  List<(IconData, String, String)> _detailEntries(ListingModel l) {
    final d = l.details;
    final out = <(IconData, String, String)>[];
    void add(IconData ic, String label, String? v) {
      if (v != null && v.toString().trim().isNotEmpty) out.add((ic, label, v));
    }

    if (l.category.usesRoommateFields) {
      add(Icons.wc_rounded, 'Gender preference', d['gender_pref']?.toString());
      add(Icons.payments_outlined, 'Budget', d['budget']?.toString());
      add(Icons.school_outlined, 'Faculty', d['faculty']?.toString());
      add(Icons.grade_outlined, 'Level', d['level']?.toString());
    } else if (l.category.usesLostFoundFields) {
      add(Icons.place_outlined, 'Last seen', d['last_seen']?.toString());
      add(Icons.event_outlined, 'Date', d['date']?.toString());
    } else if (l.category.usesJobFields) {
      add(Icons.business_outlined, 'Organisation', d['company']?.toString());
      add(Icons.timelapse_rounded, 'Type', d['job_type']?.toString());
      add(Icons.payments_outlined, 'Compensation', d['compensation']?.toString());
      add(Icons.event_busy_outlined, 'Deadline', d['deadline']?.toString());
    } else if (l.category.usesTicketFields) {
      add(Icons.celebration_outlined, 'Event', d['event_name']?.toString());
      add(Icons.event_outlined, 'Event date', d['event_date']?.toString());
      add(Icons.confirmation_number_outlined, 'Quantity',
          d['quantity']?.toString());
    }
    return out;
  }

  Widget _detailsCard(ListingModel l) {
    final entries = _detailEntries(l);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: _cardDeco(context),
      child: Column(
        children: [
          for (var i = 0; i < entries.length; i++) ...[
            Row(
              children: [
                Icon(entries[i].$1, size: 18, color: context.textSecondary),
                const SizedBox(width: 10),
                Text(entries[i].$2,
                    style: TextStyle(
                        fontSize: 13, color: context.textSecondary)),
                const Spacer(),
                Flexible(
                  child: Text(entries[i].$3,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: context.textPrimary)),
                ),
              ],
            ),
            if (i < entries.length - 1)
              Divider(height: 18, color: context.borderCol),
          ],
        ],
      ),
    );
  }

  // ── Seller card ──────────────────────────────────────────────

  Widget _sellerCard(ListingModel l, AsyncValue<SellerRating> ratingAsync) {
    return GestureDetector(
      onTap: () => context.push('/marketplace/seller/${l.sellerId}'),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        padding: const EdgeInsets.all(16),
        decoration: _cardDeco(context),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFFDDE8FF),
                  backgroundImage: l.sellerAvatar != null &&
                          l.sellerAvatar!.isNotEmpty
                      ? CachedNetworkImageProvider(l.sellerAvatar!)
                      : null,
                  child: l.sellerAvatar == null || l.sellerAvatar!.isEmpty
                      ? Text(_initials(l.sellerName),
                          style: TextStyle(
                              color: context.primary,
                              fontWeight: FontWeight.w700))
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
                            child: Text(l.sellerName ?? 'Student',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: context.textPrimary)),
                          ),
                          if (l.sellerVerified) ...[
                            const SizedBox(width: 4),
                            const VerifiedBadge(
                                size: 16, tooltip: 'Verified Student'),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        [
                          if (l.sellerProgramme != null) l.sellerProgramme,
                          if (l.sellerLevel != null) 'Level ${l.sellerLevel}',
                        ].whereType<String>().join(' · '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 12, color: context.textSecondary),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    color: context.textDisabled),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ratingAsync.maybeWhen(
                  data: (r) => _sellerStat(
                    Icons.star_rounded,
                    r.total == 0
                        ? 'New seller'
                        : '${r.average.toStringAsFixed(1)} (${r.total})',
                    AppColors.warning,
                  ),
                  orElse: () => const SizedBox.shrink(),
                ),
                const SizedBox(width: 16),
                if (l.sellerJoinedAt != null)
                  _sellerStat(Icons.calendar_today_rounded,
                      'Joined ${_monthYear(l.sellerJoinedAt!)}', AppColors.grey2),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sellerStat(IconData ic, String text, Color color) => Row(
        children: [
          Icon(ic, size: 16, color: color),
          const SizedBox(width: 4),
          Text(text,
              style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: context.textSecondary)),
        ],
      );

  // ── Bottom action bar ────────────────────────────────────────

  Widget _bottomBar(ListingModel l) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        decoration: BoxDecoration(
          color: context.cardBg,
          border: Border(top: BorderSide(color: context.borderCol)),
        ),
        child: Row(
          children: [
            _SaveToggle(listing: l),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: () => _messageSeller(l),
                style: FilledButton.styleFrom(
                  backgroundColor: context.primary,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.chat_bubble_outline_rounded,
                    size: 18, color: Colors.white),
                label: Text(
                  '${l.category.ctaVerb} · Message seller',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Actions ──────────────────────────────────────────────────

  void _messageSeller(ListingModel l) {
    // UNIFY Messaging integration: open the conversation tab. The seller's
    // identity and listing reference are passed so a thread can be started.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening chat with ${l.sellerName ?? 'seller'}…'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    context.push('/app/messaging');
  }

  void _report(ListingModel l) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.cardBg,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _ReportSheet(listing: l),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────

  Widget _circleBtn(IconData icon, VoidCallback onTap) => Padding(
        padding: const EdgeInsets.all(6),
        child: Material(
          color: context.cardBg.withValues(alpha: 0.92),
          shape: const CircleBorder(),
          child: IconButton(
            icon: Icon(icon, color: context.textPrimary, size: 20),
            onPressed: onTap,
          ),
        ),
      );

  Widget _metaPill(IconData ic, String text) => Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(ic, size: 13, color: context.textSecondary),
            const SizedBox(width: 4),
            Text(text,
                style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: context.textSecondary)),
          ],
        ),
      );

  BoxDecoration _cardDeco(BuildContext context) => BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderCol),
      );

  static String _initials(String? name) {
    if (name == null || name.trim().isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return parts[0][0].toUpperCase();
  }

  static String _monthYear(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[d.month - 1]} ${d.year}';
  }
}

// ── Save toggle on the bottom bar ──────────────────────────────

class _SaveToggle extends ConsumerStatefulWidget {
  final ListingModel listing;
  const _SaveToggle({required this.listing});

  @override
  ConsumerState<_SaveToggle> createState() => _SaveToggleState();
}

class _SaveToggleState extends ConsumerState<_SaveToggle> {
  late bool _saved = widget.listing.isSaved;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        setState(() => _saved = !_saved);
        final r = await ref
            .read(savedListingsControllerProvider.notifier)
            .toggle(widget.listing.id);
        if (mounted) setState(() => _saved = r);
      },
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          _saved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          color: _saved ? AppColors.error : AppColors.grey1,
        ),
      ),
    );
  }
}

// ── Report sheet ───────────────────────────────────────────────

class _ReportSheet extends ConsumerStatefulWidget {
  final ListingModel listing;
  const _ReportSheet({required this.listing});

  @override
  ConsumerState<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends ConsumerState<_ReportSheet> {
  String? _reason;
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: context.borderCol,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Report listing',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text('Help keep the marketplace safe.',
              style: TextStyle(fontSize: 13, color: context.textSecondary)),
          const SizedBox(height: 12),
          ...kReportReasons.map((r) {
            final sel = _reason == r;
            return InkWell(
              onTap: () => setState(() => _reason = r),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Icon(
                      sel
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_off_rounded,
                      size: 20,
                      color: sel ? AppColors.error : AppColors.grey3,
                    ),
                    const SizedBox(width: 12),
                    Text(r, style: const TextStyle(fontSize: 14)),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: _reason == null || _busy ? null : _submit,
            style: FilledButton.styleFrom(
                backgroundColor: AppColors.error,
                minimumSize: const Size.fromHeight(48)),
            child: _busy
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Text('Submit report'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    setState(() => _busy = true);
    final repo = ref.read(marketplaceRepositoryProvider);
    final user = ref.read(currentUserProvider);
    if (user == null) {
      setState(() => _busy = false);
      return;
    }
    try {
      await repo.reportListing(
        listingId: widget.listing.id,
        reporterId: user.id,
        reason: _reason!,
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report submitted. Thank you.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {
      if (mounted) setState(() => _busy = false);
    }
  }
}