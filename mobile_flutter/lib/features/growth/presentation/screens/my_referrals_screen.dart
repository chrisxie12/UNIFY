import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/theme_extensions.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/growth_models.dart';
import '../providers/growth_provider.dart';

class MyReferralsScreen extends ConsumerStatefulWidget {
  const MyReferralsScreen({super.key});

  @override
  ConsumerState<MyReferralsScreen> createState() => _MyReferralsScreenState();
}

class _MyReferralsScreenState extends ConsumerState<MyReferralsScreen> {
  final _emailController = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  String _shareText(String code) =>
      'Join me on UNIFY! Use code $code';

  Future<void> _sendInvite(InviteCode code) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    final email = _emailController.text.trim();

    setState(() => _sending = true);
    try {
      await ref.read(growthRepositoryProvider).createReferral(
            referrerId: user.id,
            email: email.isEmpty ? null : email,
            inviteCode: code.code,
            channel: 'email',
          );
      await Clipboard.setData(ClipboardData(text: _shareText(code.code)));
      _emailController.clear();
      ref.invalidate(myReferralsProvider);
      ref.invalidate(referralStatsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invite sent. Message copied!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not send invite: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final codeAsync = ref.watch(myReferralCodeProvider);
    final statsAsync = ref.watch(referralStatsProvider);
    final referralsAsync = ref.watch(myReferralsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0.6,
        shadowColor: AppColors.border,
        title: const Text('Invite Friends',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: codeAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Could not load: $e')),
        data: (code) {
          if (code == null) {
            return const Center(child: Text('Please sign in to invite friends'));
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(myReferralCodeProvider);
              ref.invalidate(referralStatsProvider);
              ref.invalidate(myReferralsProvider);
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _CodeCard(code: code, shareText: _shareText(code.code)),
                const SizedBox(height: 16),
                _StatsRow(statsAsync: statsAsync),
                const SizedBox(height: 16),
                _InviteForm(
                  emailController: _emailController,
                  sending: _sending,
                  onSend: () => _sendInvite(code),
                ),
                const SizedBox(height: 24),
                const Text('Your Invites',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.dark)),
                const SizedBox(height: 12),
                referralsAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (e, _) => Text('Could not load: $e'),
                  data: (referrals) {
                    if (referrals.isEmpty) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Text(
                          'No invites yet. Share your code to get started!',
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(fontSize: 13, color: AppColors.grey3),
                        ),
                      );
                    }
                    return Column(
                      children: referrals
                          .map((r) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _ReferralRow(referral: r),
                              ))
                          .toList(),
                    );
                  },
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CodeCard extends StatelessWidget {
  final InviteCode code;
  final String shareText;
  const _CodeCard({required this.code, required this.shareText});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [context.primary, context.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('YOUR REFERRAL CODE',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: Colors.white.withValues(alpha: 0.85))),
          const SizedBox(height: 8),
          Text(code.code,
              style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                  color: Colors.white)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: Icons.copy_rounded,
                  label: 'Copy code',
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: code.code));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Code copied!')),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionButton(
                  icon: Icons.share_rounded,
                  label: 'Copy message',
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: shareText));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Invite message copied!')),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionButton(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.18),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: Colors.white),
              const SizedBox(width: 6),
              Text(label,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final AsyncValue<Map<String, int>> statsAsync;
  const _StatsRow({required this.statsAsync});

  @override
  Widget build(BuildContext context) {
    final stats = statsAsync.valueOrNull ??
        const {'sent': 0, 'accepted': 0, 'active': 0};
    return Row(
      children: [
        _StatTile(
          icon: Icons.send_rounded,
          value: '${stats['sent'] ?? 0}',
          label: 'Sent',
          color: AppColors.warning,
        ),
        _StatTile(
          icon: Icons.how_to_reg_rounded,
          value: '${stats['accepted'] ?? 0}',
          label: 'Accepted',
          color: AppColors.info,
        ),
        _StatTile(
          icon: Icons.verified_rounded,
          value: '${stats['active'] ?? 0}',
          label: 'Active',
          color: AppColors.success,
        ),
      ],
    );
  }
}

class _InviteForm extends StatelessWidget {
  final TextEditingController emailController;
  final bool sending;
  final VoidCallback onSend;
  const _InviteForm({
    required this.emailController,
    required this.sending,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Invite a friend by email",
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.dark)),
          const SizedBox(height: 12),
          TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: "friend@example.com",
              prefixIcon: const Icon(Icons.email_rounded, size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: context.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: sending ? null : onSend,
              icon: sending
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.send_rounded, size: 18),
              label: Text(sending ? 'Sending...' : 'Send invite'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReferralRow extends StatelessWidget {
  final Referral referral;
  const _ReferralRow({required this.referral});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(referral.status);
    final date = referral.createdAt;
    final dateLabel = '${date.day}/${date.month}/${date.year}';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  referral.referredEmail?.isNotEmpty == true
                      ? referral.referredEmail!
                      : 'Friend invite',
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.dark),
                ),
                const SizedBox(height: 2),
                Text(dateLabel,
                    style:
                        const TextStyle(fontSize: 11, color: AppColors.grey3)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(referral.status.toUpperCase(),
                style: TextStyle(
                    fontSize: 9, fontWeight: FontWeight.w700, color: color)),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w800, color: color)),
            const SizedBox(height: 2),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11, color: AppColors.grey2)),
          ],
        ),
      ),
    );
  }
}

Color _statusColor(String status) {
  switch (status) {
    case 'sent':
      return AppColors.warning;
    case 'accepted':
      return AppColors.info;
    case 'active':
      return AppColors.success;
    default:
      return AppColors.grey2;
  }
}
