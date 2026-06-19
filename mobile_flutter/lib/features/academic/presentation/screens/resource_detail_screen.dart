import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/supabase_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../../../../core/extensions/datetime_extensions.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/unify_snackbar.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../data/models/academic_models.dart';
import '../providers/academic_provider.dart';

IconData _resourceIcon(String type) {
  switch (type) {
    case 'lecture_note':
    case 'notes':
      return Icons.article_rounded;
    case 'past_question':
      return Icons.quiz_rounded;
    case 'study_guide':
      return Icons.menu_book_rounded;
    case 'textbook':
      return Icons.book_rounded;
    case 'video':
      return Icons.play_circle_rounded;
    case 'assignment':
      return Icons.assignment_rounded;
    case 'reference':
      return Icons.link_rounded;
    default:
      return Icons.description_rounded;
  }
}

Color _resourceColor(String type) {
  switch (type) {
    case 'lecture_note':
    case 'notes':
      return AppColors.primary;
    case 'past_question':
      return AppColors.warning;
    case 'study_guide':
      return AppColors.success;
    case 'textbook':
      return AppColors.info;
    case 'video':
      return AppColors.error;
    case 'assignment':
      return AppColors.catUrgent;
    case 'reference':
      return AppColors.catEvents;
    default:
      return AppColors.grey2;
  }
}

Color _verificationColor(String status) {
  switch (status) {
    case 'verified_course_rep':
      return AppColors.success;
    case 'verified_faculty_admin':
      return AppColors.info;
    case 'official':
      return AppColors.success;
    default:
      return AppColors.grey3;
  }
}

String _verificationLabel(String status) {
  switch (status) {
    case 'verified_course_rep':
      return 'Verified by Course Rep';
    case 'verified_faculty_admin':
      return 'Verified by Faculty Admin';
    case 'official':
      return 'Official Resource';
    default:
      return 'Student Uploaded';
  }
}

class ResourceDetailScreen extends ConsumerStatefulWidget {
  final String resourceId;
  const ResourceDetailScreen({super.key, required this.resourceId});

  @override
  ConsumerState<ResourceDetailScreen> createState() =>
      _ResourceDetailScreenState();
}

class _ResourceDetailScreenState
    extends ConsumerState<ResourceDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(academicRepositoryProvider)
          .incrementView(widget.resourceId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(resourceDetailProvider(widget.resourceId));
    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.bg,
        surfaceTintColor: Colors.white,
        elevation: 0.6,
        shadowColor: AppColors.border,
        title: const Text('Resource'),
        actions: [
          async.maybeWhen(
            data: (r) => r == null
                ? const SizedBox.shrink()
                : _VerifyMenu(resource: r),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => AppErrorWidget(e),
        data: (r) =>
            r == null ? const Center(child: Text('Not found')) : _content(r),
      ),
      bottomNavigationBar: async.maybeWhen(
        data: (r) => r == null ? null : _bottomBar(r),
        orElse: () => null,
      ),
    );
  }

  Widget _content(AcademicResourceModel r) {
    final ratingsAsync = ref.watch(resourceRatingsProvider(r.id));
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: _resourceColor(r.type).withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(_resourceIcon(r.type),
                  color: _resourceColor(r.type), size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(r.title,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          height: 1.25)),
                  const SizedBox(height: 6),
                  _verificationBadge(r.verificationStatus),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Stats
        Row(
          children: [
            _stat('${r.downloadCount}', 'Downloads', Icons.download_rounded),
            _stat('${r.viewCount}', 'Views', Icons.remove_red_eye_rounded),
            _stat(r.ratingCount == 0 ? '—' : r.averageRating.toStringAsFixed(1),
                'Rating', Icons.star_rounded),
          ],
        ),

        if (r.fileType == 'image' && r.fileUrl.isNotEmpty) ...[
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: CachedNetworkImage(
              imageUrl: r.fileUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                  height: 200, color: context.cardBg),
              errorWidget: (_, __, ___) => Container(
                height: 200,
                color: context.cardBg,
                child: const Icon(Icons.broken_image_outlined,
                    color: context.textDisabled),
              ),
            ),
          ),
        ],

        if (r.description != null && r.description!.isNotEmpty) ...[
          const SizedBox(height: 16),
          _card('Description', child: Text(r.description!,
              style: const TextStyle(
                  fontSize: 14, height: 1.5, color: context.textPrimary))),
        ],

        const SizedBox(height: 12),
        _card('Details', child: Column(
          children: [
            _row('Type', r.type),
            if (r.lecturer != null) _row('Lecturer', r.lecturer!),
            if (r.academicYear != null) _row('Academic year', r.academicYear!),
            if (r.semester != null) _row('Semester', r.semester!),
            if (r.faculty != null) _row('Faculty', r.faculty!),
            if (r.department != null) _row('Department', r.department!),
            _row('Uploaded', r.createdAt.timeAgo),
            if (r.uploaderName != null) _row('By', r.uploaderName!),
          ],
        )),

        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Reviews',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            TextButton.icon(
              onPressed: () => _rate(r),
              icon: const Icon(Icons.rate_review_outlined, size: 18),
              label: const Text('Rate'),
            ),
          ],
        ),
        ratingsAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
          data: (ratings) => ratings.isEmpty
              ? const Text('No reviews yet.',
                  style: TextStyle(color: context.textDisabled))
              : Column(
                  children: ratings
                      .map((rt) => _ratingTile(rt))
                      .toList()),
        ),
      ],
    );
  }

  Widget _bottomBar(AcademicResourceModel r) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        decoration: const BoxDecoration(
          color: context.cardBg,
          border: Border(top: BorderSide(color: context.borderCol)),
        ),
        child: Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () => _open(r),
                style: FilledButton.styleFrom(
                  backgroundColor: context.primary,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.open_in_new_rounded,
                    size: 18, color: Colors.white),
                label: const Text('Open / Download',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _open(AcademicResourceModel r) async {
    final user = ref.read(currentUserProvider);
    await ref.read(academicRepositoryProvider).incrementDownload(r.id, user?.id ?? '');
    ref.invalidate(resourceDetailProvider(r.id));
    if (r.fileUrl.isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: r.fileUrl));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Link copied — paste in your browser to open'),
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  void _rate(AcademicResourceModel r) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _RateSheet(resourceId: r.id),
    );
  }

  Widget _verificationBadge(String status) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: _verificationColor(status).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (status != 'student_uploaded')
              Icon(Icons.verified_rounded, size: 13, color: _verificationColor(status)),
            if (status != 'student_uploaded') const SizedBox(width: 4),
            Text(_verificationLabel(status),
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _verificationColor(status))),
          ],
        ),
      );

  Widget _stat(String value, String label, IconData icon) => Expanded(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: context.cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFF0F1F3)),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(height: 4),
              Text(value,
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w800)),
              Text(label,
                  style: TextStyle(fontSize: 11, color: context.textSecondary)),
            ],
          ),
        ),
      );

  Widget _card(String title, {required Widget child}) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF0F1F3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            child,
          ],
        ),
      );

  Widget _row(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 110,
              child: Text(k,
                  style: const TextStyle(
                      fontSize: 13, color: context.textSecondary)),
            ),
            Expanded(
              child: Text(v,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: context.textPrimary)),
            ),
          ],
        ),
      );

  Widget _ratingTile(ResourceRating rt) => Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF0F1F3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(rt.userId,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600)),
                ),
                Row(
                  children: List.generate(
                    5,
                    (i) => Icon(
                      i < rt.rating
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      size: 14,
                      color: AppColors.warning,
                    ),
                  ),
                ),
              ],
            ),
            if (rt.review != null && rt.review!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(rt.review!,
                  style: const TextStyle(
                      fontSize: 13, color: context.textPrimary)),
            ],
          ],
        ),
      );
}

class _VerifyMenu extends ConsumerWidget {
  final AcademicResourceModel resource;
  const _VerifyMenu({required this.resource});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.verified_outlined, color: context.textPrimary),
      tooltip: 'Set verification',
      onSelected: (status) async {
        final updated = AcademicResourceModel(
          id: resource.id,
          courseId: resource.courseId,
          title: resource.title,
          description: resource.description,
          type: resource.type,
          fileUrl: resource.fileUrl,
          fileType: resource.fileType,
          fileSize: resource.fileSize,
          thumbnailUrl: resource.thumbnailUrl,
          university: resource.university,
          faculty: resource.faculty,
          department: resource.department,
          academicYear: resource.academicYear,
          semester: resource.semester,
          lecturer: resource.lecturer,
          uploadedBy: resource.uploadedBy,
          uploaderName: resource.uploaderName,
          verificationStatus: status,
          verifiedBy: resource.verifiedBy,
          verifiedAt: resource.verifiedAt,
          downloadCount: resource.downloadCount,
          viewCount: resource.viewCount,
          createdAt: resource.createdAt,
          averageRating: resource.averageRating,
          ratingCount: resource.ratingCount,
          isOffline: resource.isOffline,
        );
        await ref.read(academicRepositoryProvider).uploadResource(updated);
        ref.invalidate(resourceDetailProvider(resource.id));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Marked as ${_verificationLabel(status)}'),
            behavior: SnackBarBehavior.floating,
          ));
        }
      },
      itemBuilder: (_) => [
        'student_uploaded',
        'verified_course_rep',
        'verified_faculty_admin',
        'official',
      ].map((s) => PopupMenuItem(value: s, child: Text(_verificationLabel(s)))).toList(),
    );
  }
}

class _RateSheet extends ConsumerStatefulWidget {
  final String resourceId;
  const _RateSheet({required this.resourceId});

  @override
  ConsumerState<_RateSheet> createState() => _RateSheetState();
}

class _RateSheetState extends ConsumerState<_RateSheet> {
  int _rating = 5;
  final _reviewCtrl = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _reviewCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24),
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
          const Text('Rate this resource',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                5,
                (i) => GestureDetector(
                  onTap: () => setState(() => _rating = i + 1),
                  child: Icon(
                    i < _rating
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    size: 40,
                    color: AppColors.warning,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _reviewCtrl,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'How useful was this? (optional)',
              filled: true,
              fillColor: context.inputFill,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _busy ? null : _submit,
            style: FilledButton.styleFrom(
                backgroundColor: context.primary,
                minimumSize: const Size.fromHeight(48)),
            child: _busy
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Text('Submit rating'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    setState(() => _busy = true);
    try {
      await ref.read(academicRepositoryProvider).rateResource(
            widget.resourceId,
            user.id,
            _rating,
            review: _reviewCtrl.text.trim().isEmpty ? null : _reviewCtrl.text.trim(),
          );
      ref.invalidate(resourceRatingsProvider(widget.resourceId));
      ref.invalidate(resourceDetailProvider(widget.resourceId));
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Thanks for rating!'),
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        UnifySnackbar.error(context, ErrorMapper.toUserMessage(e));
      }
    }
  }
}
