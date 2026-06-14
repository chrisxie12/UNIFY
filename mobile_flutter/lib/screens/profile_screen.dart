import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _profile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    final data = await Supabase.instance.client
        .from('profiles')
        .select('*')
        .eq('id', user.id)
        .maybeSingle();
    if (mounted) setState(() { _profile = data; _loading = false; });
  }

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Log out', style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Log out', style: TextStyle(color: kRed)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await Supabase.instance.client.auth.signOut();
      if (mounted) context.go('/get-started');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator(color: kBlue1)),
      );
    }

    final name    = _profile?['full_name'] as String? ?? '';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';
    final prog    = _profile?['programme'] as String?;
    final level   = _profile?['level'] as String?;
    final bio     = _profile?['bio'] as String?;
    final verified = _profile?['is_verified'] as bool? ?? false;
    final studentId = _profile?['student_id'] as String?;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // Blue cover
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: kBlue1,
            leading: GestureDetector(
              onTap: () => context.pop(),
              child: const Icon(Icons.arrow_back, color: Colors.white),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined, color: Colors.white),
                onPressed: () {},
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: kGradient),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar overlaps cover
                  Transform.translate(
                    offset: const Offset(0, -32),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 80, height: 80,
                          decoration: BoxDecoration(
                            color: kBlue1,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                          ),
                          child: Center(
                            child: Text(
                              initial,
                              style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => context.push('/onboarding'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              border: Border.all(color: kBorder),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text('Edit profile', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kDark)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Name & verification
                  Transform.translate(
                    offset: const Offset(0, -20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name.isNotEmpty ? name : 'Your Profile',
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: kDark)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              verified ? Icons.verified_rounded : Icons.schedule_rounded,
                              size: 14,
                              color: verified ? kGreen : kGrey3,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              verified ? 'Verified student' : 'Verification pending',
                              style: TextStyle(fontSize: 12, color: verified ? kGreen : kGrey3),
                            ),
                          ],
                        ),
                        if (prog != null || level != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            [if (prog != null) prog, if (level != null) 'Level $level'].join(' · '),
                            style: const TextStyle(fontSize: 13, color: kGrey2),
                          ),
                        ],
                        if (studentId != null) ...[
                          const SizedBox(height: 2),
                          Text('ID: $studentId', style: const TextStyle(fontSize: 12, color: kGrey3)),
                        ],
                        if (bio != null && bio.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Text(bio, style: const TextStyle(fontSize: 13, color: kGrey1, height: 1.5)),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),
                  const Divider(color: kBorder),
                  const SizedBox(height: 20),

                  // Log out
                  GestureDetector(
                    onTap: _signOut,
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        border: Border.all(color: kBorder),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Center(
                        child: Text(
                          'Log Out',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: kRed),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
