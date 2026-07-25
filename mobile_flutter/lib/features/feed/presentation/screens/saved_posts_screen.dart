import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/announcement_social_provider.dart';
import '../../domain/entities/announcement.dart';
import '../../data/models/announcement_model.dart';
import '../../data/repositories/announcement_social_repository.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../../../../core/widgets/app_loading_widget.dart';
import '../../../../core/widgets/app_empty_widget.dart';
import '../../../../core/design_system/tokens.dart';

class SavedPostsScreen extends ConsumerStatefulWidget {
  const SavedPostsScreen({super.key});

  @override
  ConsumerState<SavedPostsScreen> createState() => _SavedPostsScreenState();
}

class _SavedPostsScreenState extends ConsumerState<SavedPostsScreen> {
  List<Announcement>? _items;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final repo = ref.read(announcementSocialRepoProvider);
      final ids = await repo.getSavedAnnouncementIds();
      if (ids.isEmpty) {
        setState(() { _items = []; _loading = false; });
        return;
      }
      final idList = ids.join(',');
      final data = await Supabase.instance.client
          .from('announcements')
          .select('*, profiles!author_id(full_name, avatar_url, is_verified_leader, leadership_role)')
          .filter('id', 'in', '($idList)')
          .order('created_at', ascending: false) as List<dynamic>;
      setState(() {
        _items = data.map((j) => AnnouncementModel.fromJson(j as Map<String, dynamic>)).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.surfaceBg,
      appBar: AppBar(
        title: const Text('Saved Posts'),
        leading: IconButton(
          icon: Icon(Iconsax.arrow_left_copy, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loading
          ? const AppLoadingWidget.list()
          : _items == null || _items!.isEmpty
              ? AppEmptyWidget(
                  icon: Iconsax.bookmark_copy,
                  title: 'No saved posts',
                  subtitle: 'Tap the bookmark icon on any post to save it for later.',
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: EdgeInsets.all(USpacing.base),
                    itemCount: _items!.length,
                    separatorBuilder: (_, __) => SizedBox(height: USpacing.sm),
                    itemBuilder: (context, index) {
                      final post = _items![index];
                      return _SavedPostCard(post: post, repo: ref.read(announcementSocialRepoProvider));
                    },
                  ),
                ),
    );
  }
}

class _SavedPostCard extends StatelessWidget {
  final Announcement post;
  final AnnouncementSocialRepository repo;

  const _SavedPostCard({required this.post, required this.repo});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceCard,
        borderRadius: BorderRadius.circular(URadius.md),
        border: Border.all(color: context.borderSubtle.withValues(alpha: context.isDark ? 0.3 : 0.5)),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.fromLTRB(USpacing.md, USpacing.sm, USpacing.sm, USpacing.sm),
        title: Text(post.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: context.textPrimary)),
        subtitle: Padding(
          padding: EdgeInsets.only(top: 2),
          child: Text(post.body, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: context.textSecondary)),
        ),
        trailing: IconButton(
          icon: Icon(Iconsax.bookmark_copy, size: 20, color: context.primary),
          onPressed: () async {
            await repo.toggleSave(post.id);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Removed from saved'), duration: Duration(seconds: 2)),
              );
            }
          },
        ),
      ),
    );
  }
}
