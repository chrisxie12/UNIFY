import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/colors.dart';

const _categoryIcon = {
  'academic': '📚',
  'events':   '🎉',
  'admin':    '🏛️',
  'general':  '📢',
  'urgent':   '🚨',
};

const _categoryColor = {
  'urgent':   Color(0xFFEF4444),
  'academic': kBlue1,
  'events':   Color(0xFF8B5CF6),
  'admin':    Color(0xFFF59E0B),
  'general':  kGrey2,
};

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _announcements = [];
  Map<String, dynamic>? _profile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final sb   = Supabase.instance.client;
    final user = sb.auth.currentUser;
    if (user == null) return;

    final now = DateTime.now().toIso8601String();

    final results = await Future.wait([
      sb.from('profiles').select('id, full_name, is_verified, role').eq('id', user.id).maybeSingle(),
      sb.from('announcements')
          .select('id, title, body, category, published_at, expires_at')
          .eq('is_published', true)
          .or('expires_at.is.null,expires_at.gt.$now')
          .order('published_at', ascending: false)
          .limit(30),
    ]);

    if (mounted) {
      setState(() {
        _profile       = results[0] as Map<String, dynamic>?;
        _announcements = (results[1] as List).cast<Map<String, dynamic>>();
        _loading       = false;
      });
    }
  }

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _timeAgo(String iso) {
    final diff = DateTime.now().difference(DateTime.parse(iso));
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24)   return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final name = (_profile?['full_name'] as String? ?? '').split(' ').first;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: RefreshIndicator(
        onRefresh: _load,
        color: kBlue1,
        child: CustomScrollView(
          slivers: [
            // App bar
            SliverAppBar(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              pinned: true,
              elevation: 0,
              expandedHeight: 100,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                title: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$_greeting${name.isNotEmpty ? ', $name' : ''} 👋',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: kDark),
                    ),
                    const Text(
                      'GCTU Campus Feed',
                      style: TextStyle(fontSize: 11, color: kGrey2, fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),
              actions: [
                GestureDetector(
                  onTap: () => context.push('/profile'),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: kBlue1.withOpacity(0.12),
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : 'U',
                        style: const TextStyle(color: kBlue1, fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            if (_loading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator(color: kBlue1)),
              )
            else if (_announcements.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('📭', style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 12),
                      const Text('Nothing yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: kDark)),
                      const SizedBox(height: 4),
                      Text('Check back later for campus announcements.', style: TextStyle(fontSize: 13, color: kGrey2)),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => _AnnouncementCard(
                      item: _announcements[i],
                      timeAgo: _timeAgo(_announcements[i]['published_at'] as String),
                    ),
                    childCount: _announcements.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final String timeAgo;
  const _AnnouncementCard({required this.item, required this.timeAgo});

  @override
  Widget build(BuildContext context) {
    final cat   = item['category'] as String? ?? 'general';
    final icon  = _categoryIcon[cat] ?? '📢';
    final color = _categoryColor[cat] ?? kGrey2;
    final label = cat[0].toUpperCase() + cat.substring(1);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: (color as Color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: Text(icon, style: const TextStyle(fontSize: 22))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: (color as Color).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
                      ),
                      const SizedBox(width: 8),
                      Text(timeAgo, style: const TextStyle(fontSize: 10, color: kGrey3)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item['title'] as String? ?? '',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: kDark, height: 1.3),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['body'] as String? ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: kGrey2, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
