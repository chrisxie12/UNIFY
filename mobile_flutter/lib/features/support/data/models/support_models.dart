import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Status helpers shared by support tickets.
class TicketStatus {
  TicketStatus._();

  static const String open = 'open';
  static const String inProgress = 'in_progress';
  static const String resolved = 'resolved';
  static const String closed = 'closed';

  static const List<String> all = [open, inProgress, resolved, closed];

  static String label(String status) {
    switch (status) {
      case open:
        return 'Open';
      case inProgress:
        return 'In Progress';
      case resolved:
        return 'Resolved';
      case closed:
        return 'Closed';
      default:
        return status;
    }
  }

  static Color color(String status) {
    switch (status) {
      case open:
        return AppColors.warning;
      case inProgress:
        return AppColors.info;
      case resolved:
        return AppColors.success;
      case closed:
        return AppColors.grey2;
      default:
        return AppColors.grey2;
    }
  }
}

/// Status helpers for abuse reports.
class AbuseStatus {
  AbuseStatus._();

  static const String open = 'open';
  static const String reviewing = 'reviewing';
  static const String actioned = 'actioned';
  static const String dismissed = 'dismissed';

  static const List<String> all = [open, reviewing, actioned, dismissed];

  static String label(String status) {
    switch (status) {
      case open:
        return 'Open';
      case reviewing:
        return 'Reviewing';
      case actioned:
        return 'Actioned';
      case dismissed:
        return 'Dismissed';
      default:
        return status;
    }
  }

  static Color color(String status) {
    switch (status) {
      case open:
        return AppColors.warning;
      case reviewing:
        return AppColors.info;
      case actioned:
        return AppColors.success;
      case dismissed:
        return AppColors.grey2;
      default:
        return AppColors.grey2;
    }
  }
}

class FaqItem {
  final String id;
  final String question;
  final String answer;
  final String? category;
  final int orderIndex;
  final bool isPublished;
  final DateTime createdAt;

  const FaqItem({
    required this.id,
    required this.question,
    required this.answer,
    this.category,
    this.orderIndex = 0,
    this.isPublished = true,
    required this.createdAt,
  });

  factory FaqItem.fromJson(Map<String, dynamic> json) => FaqItem(
        id: json['id'] as String,
        question: json['question'] as String? ?? '',
        answer: json['answer'] as String? ?? '',
        category: json['category'] as String?,
        orderIndex: json['order_index'] as int? ?? 0,
        isPublished: json['is_published'] as bool? ?? true,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}

class HelpArticle {
  final String id;
  final String? slug;
  final String? category;
  final String title;
  final String body;
  final bool isPublished;
  final int viewCount;
  final int helpfulCount;
  final int orderIndex;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const HelpArticle({
    required this.id,
    this.slug,
    this.category,
    required this.title,
    required this.body,
    this.isPublished = true,
    this.viewCount = 0,
    this.helpfulCount = 0,
    this.orderIndex = 0,
    this.createdBy,
    required this.createdAt,
    this.updatedAt,
  });

  factory HelpArticle.fromJson(Map<String, dynamic> json) => HelpArticle(
        id: json['id'] as String,
        slug: json['slug'] as String?,
        category: json['category'] as String?,
        title: json['title'] as String? ?? '',
        body: json['body'] as String? ?? '',
        isPublished: json['is_published'] as bool? ?? true,
        viewCount: json['view_count'] as int? ?? 0,
        helpfulCount: json['helpful_count'] as int? ?? 0,
        orderIndex: json['order_index'] as int? ?? 0,
        createdBy: json['created_by'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: json['updated_at'] != null
            ? DateTime.tryParse(json['updated_at'] as String)
            : null,
      );
}

class SupportTicket {
  final String id;
  final String userId;
  final String subject;
  final String message;
  final String? category;
  final String status;
  final String? adminResponse;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Joined reporter identity
  final String? userName;
  final String? userAvatar;

  const SupportTicket({
    required this.id,
    required this.userId,
    required this.subject,
    required this.message,
    this.category,
    this.status = 'open',
    this.adminResponse,
    required this.createdAt,
    this.updatedAt,
    this.userName,
    this.userAvatar,
  });

  factory SupportTicket.fromJson(Map<String, dynamic> json) {
    final p = json['profiles'] as Map<String, dynamic>?;
    return SupportTicket(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      subject: json['subject'] as String? ?? '',
      message: json['message'] as String? ?? '',
      category: json['category'] as String?,
      status: json['status'] as String? ?? 'open',
      adminResponse: json['admin_response'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
      userName: p?['full_name'] as String?,
      userAvatar: p?['avatar_url'] as String?,
    );
  }
}

class AbuseReport {
  final String id;
  final String reporterId;
  final String targetType;
  final String? targetId;
  final String reason;
  final String? details;
  final String status;
  final DateTime createdAt;

  // Joined reporter identity
  final String? reporterName;
  final String? reporterAvatar;

  const AbuseReport({
    required this.id,
    required this.reporterId,
    required this.targetType,
    this.targetId,
    required this.reason,
    this.details,
    this.status = 'open',
    required this.createdAt,
    this.reporterName,
    this.reporterAvatar,
  });

  factory AbuseReport.fromJson(Map<String, dynamic> json) {
    final p = json['profiles'] as Map<String, dynamic>?;
    return AbuseReport(
      id: json['id'] as String,
      reporterId: json['reporter_id'] as String,
      targetType: json['target_type'] as String? ?? '',
      targetId: json['target_id'] as String?,
      reason: json['reason'] as String? ?? '',
      details: json['details'] as String?,
      status: json['status'] as String? ?? 'open',
      createdAt: DateTime.parse(json['created_at'] as String),
      reporterName: p?['full_name'] as String?,
      reporterAvatar: p?['avatar_url'] as String?,
    );
  }
}
