import 'dart:math';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/growth_models.dart';

class GrowthRepositoryImpl {
  final SupabaseClient _client;

  GrowthRepositoryImpl(this._client);

  // ── Waitlist ───────────────────────────────────────────────

  Future<List<WaitlistEntry>> getWaitlist({String? status}) async {
    final data = await _client
        .from('waitlist')
        .select('*')
        .limit(100)
        .order('created_at', ascending: false);

    final entries = (data as List)
        .map((row) => WaitlistEntry.fromJson(row as Map<String, dynamic>))
        .toList();

    if (status != null && status.isNotEmpty) {
      return entries.where((e) => e.status == status).toList();
    }
    return entries;
  }

  Future<void> updateWaitlistStatus(String id, String status) async {
    final updates = <String, dynamic>{'status': status};
    if (status == 'invited') {
      updates['invited_at'] = DateTime.now().toUtc().toIso8601String();
    }
    await _client.from('waitlist').update(updates).eq('id', id);
  }

  // ── Invite Codes ───────────────────────────────────────────

  Future<List<InviteCode>> getInviteCodes() async {
    final data = await _client
        .from('invite_codes')
        .select('*')
        .limit(100)
        .order('created_at', ascending: false);

    return (data as List)
        .map((row) => InviteCode.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  Future<InviteCode> createInviteCode({
    required String code,
    required String type,
    int maxUses = 0,
    DateTime? expiresAt,
    String? note,
    required String createdBy,
  }) async {
    final result = await _client
        .from('invite_codes')
        .insert({
          'code': code,
          'type': type,
          'max_uses': maxUses,
          'expires_at': expiresAt?.toUtc().toIso8601String(),
          'note': note,
          'created_by': createdBy,
          'is_active': true,
        })
        .select()
        .single();
    return InviteCode.fromJson(result);
  }

  Future<void> toggleInviteCode(String id, bool isActive) async {
    await _client
        .from('invite_codes')
        .update({'is_active': isActive})
        .eq('id', id);
  }

  // ── Beta Testers ───────────────────────────────────────────

  Future<List<BetaTester>> getBetaTesters() async {
    final data = await _client
        .from('beta_testers')
        .select('*, profiles!beta_testers_user_id_fkey(full_name, avatar_url)')
        .limit(100)
        .order('joined_at', ascending: false);

    return (data as List)
        .map((row) => BetaTester.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  Future<void> setBetaStatus(String userId, String status) async {
    await _client
        .from('beta_testers')
        .update({'status': status})
        .eq('user_id', userId);
  }

  // ── Referrals ──────────────────────────────────────────────

  /// Returns the user's existing active referral invite code, creating one if
  /// none exists. Code format: 'REF' + 6 random uppercase alphanumerics.
  Future<InviteCode> getMyReferralCode(String userId) async {
    final existing = await _client
        .from('invite_codes')
        .select('*')
        .eq('created_by', userId)
        .eq('type', 'referral')
        .eq('is_active', true)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (existing != null) {
      return InviteCode.fromJson(existing);
    }

    final code = 'REF${_randomCode(6)}';
    final result = await _client
        .from('invite_codes')
        .insert({
          'code': code,
          'type': 'referral',
          'max_uses': 0,
          'created_by': userId,
          'is_active': true,
        })
        .select()
        .single();
    return InviteCode.fromJson(result);
  }

  Future<Referral> createReferral({
    required String referrerId,
    String? email,
    required String inviteCode,
    String? channel,
  }) async {
    final result = await _client
        .from('referrals')
        .insert({
          'referrer_id': referrerId,
          'referred_email': email,
          'invite_code': inviteCode,
          'channel': channel,
          'status': 'sent',
        })
        .select()
        .single();
    return Referral.fromJson(result);
  }

  Future<List<Referral>> getMyReferrals(String userId) async {
    final data = await _client
        .from('referrals')
        .select('*')
        .eq('referrer_id', userId)
        .order('created_at', ascending: false)
        .limit(200);

    return (data as List)
        .map((row) => Referral.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, int>> referralStats(String userId) async {
    final data = await _client
        .from('referrals')
        .select('status')
        .eq('referrer_id', userId)
        .limit(500);

    final rows = (data as List).cast<Map<String, dynamic>>();
    var sent = 0;
    var accepted = 0;
    var active = 0;
    for (final r in rows) {
      switch (r['status'] as String? ?? 'sent') {
        case 'accepted':
          accepted++;
          break;
        case 'active':
          active++;
          break;
        default:
          sent++;
      }
    }
    return {'sent': sent, 'accepted': accepted, 'active': active};
  }

  Future<List<Referral>> getAllReferrals() async {
    final data = await _client
        .from('referrals')
        .select('*, profiles!referrals_referrer_id_fkey(full_name)')
        .limit(100)
        .order('created_at', ascending: false);

    return (data as List)
        .map((row) => Referral.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  // ── Helpers ────────────────────────────────────────────────

  String _randomCode(int length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rnd = Random();
    return List.generate(length, (_) => chars[rnd.nextInt(chars.length)]).join();
  }
}
