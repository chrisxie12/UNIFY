import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/support_models.dart';

class SupportRepositoryImpl {
  final SupabaseClient _client;
  SupportRepositoryImpl(this._client);

  static const _ticketJoin =
      'profiles!support_tickets_user_id_fkey(full_name, avatar_url)';
  static const _abuseJoin =
      'profiles!abuse_reports_reporter_id_fkey(full_name, avatar_url)';

  // ── FAQ ──────────────────────────────────────────────────────

  Future<List<FaqItem>> getFaqs() async {
    final data = await _client
        .from('faq_items')
        .select('*')
        .eq('is_published', true)
        .order('order_index', ascending: true)
        .limit(200);
    return (data as List)
        .map((r) => FaqItem.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  Future<FaqItem> createFaq({
    required String question,
    required String answer,
    required String category,
  }) async {
    final data = await _client
        .from('faq_items')
        .insert({
          'question': question,
          'answer': answer,
          'category': category,
          'is_published': true,
        })
        .select()
        .single();
    return FaqItem.fromJson(data);
  }

  // ── Help articles ────────────────────────────────────────────

  Future<List<HelpArticle>> getArticles() async {
    final data = await _client
        .from('help_articles')
        .select('*')
        .eq('is_published', true)
        .order('order_index', ascending: true)
        .limit(200);
    return (data as List)
        .map((r) => HelpArticle.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  Future<HelpArticle?> getArticle(String id) async {
    final data = await _client
        .from('help_articles')
        .select('*')
        .eq('id', id)
        .maybeSingle();
    if (data == null) return null;
    return HelpArticle.fromJson(data);
  }

  Future<void> incrementArticleView(String id) async {
    final row = await _client
        .from('help_articles')
        .select('view_count')
        .eq('id', id)
        .maybeSingle();
    if (row == null) return;
    final current = row['view_count'] as int? ?? 0;
    await _client
        .from('help_articles')
        .update({'view_count': current + 1}).eq('id', id);
  }

  Future<void> markArticleHelpful(String id) async {
    final row = await _client
        .from('help_articles')
        .select('helpful_count')
        .eq('id', id)
        .maybeSingle();
    if (row == null) return;
    final current = row['helpful_count'] as int? ?? 0;
    await _client
        .from('help_articles')
        .update({'helpful_count': current + 1}).eq('id', id);
  }

  Future<HelpArticle> createArticle({
    required String title,
    required String body,
    required String category,
  }) async {
    final data = await _client
        .from('help_articles')
        .insert({
          'title': title,
          'body': body,
          'category': category,
          'is_published': true,
        })
        .select()
        .single();
    return HelpArticle.fromJson(data);
  }

  // ── Support tickets ──────────────────────────────────────────

  Future<SupportTicket> createTicket({
    required String userId,
    required String subject,
    required String message,
    required String category,
  }) async {
    final data = await _client
        .from('support_tickets')
        .insert({
          'user_id': userId,
          'subject': subject,
          'message': message,
          'category': category,
        })
        .select('*, $_ticketJoin')
        .single();
    return SupportTicket.fromJson(data);
  }

  Future<List<SupportTicket>> getMyTickets(String userId) async {
    final data = await _client
        .from('support_tickets')
        .select('*, $_ticketJoin')
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(100);
    return (data as List)
        .map((r) => SupportTicket.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  Future<List<SupportTicket>> getAllTickets({String? status}) async {
    var q = _client.from('support_tickets').select('*, $_ticketJoin');
    if (status != null) q = q.eq('status', status);
    final data = await q.order('created_at', ascending: false).limit(200);
    return (data as List)
        .map((r) => SupportTicket.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  Future<void> setTicketStatus(
    String id,
    String status, {
    String? adminResponse,
  }) async {
    final patch = <String, dynamic>{
      'status': status,
      'updated_at': DateTime.now().toIso8601String(),
    };
    if (adminResponse != null) patch['admin_response'] = adminResponse;
    await _client.from('support_tickets').update(patch).eq('id', id);
  }

  // ── Abuse reports ────────────────────────────────────────────

  Future<AbuseReport> reportAbuse({
    required String reporterId,
    required String targetType,
    String? targetId,
    required String reason,
    String? details,
  }) async {
    final data = await _client
        .from('abuse_reports')
        .insert({
          'reporter_id': reporterId,
          'target_type': targetType,
          'target_id': targetId,
          'reason': reason,
          'details': details,
        })
        .select('*, $_abuseJoin')
        .single();
    return AbuseReport.fromJson(data);
  }

  Future<List<AbuseReport>> getAbuseReports({String? status}) async {
    var q = _client.from('abuse_reports').select('*, $_abuseJoin');
    if (status != null) q = q.eq('status', status);
    final data = await q.order('created_at', ascending: false).limit(200);
    return (data as List)
        .map((r) => AbuseReport.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  Future<void> setAbuseStatus(String id, String status) async {
    await _client.from('abuse_reports').update({'status': status}).eq('id', id);
  }
}
