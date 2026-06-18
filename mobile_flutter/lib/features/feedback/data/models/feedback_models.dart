import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Type of a feedback item. The [key] matches the DB CHECK constraint on
/// `feedback_items.type`.
enum FeedbackType {
  bug('bug', 'Bug', Icons.bug_report_rounded),
  feature('feature', 'Feature', Icons.lightbulb_outline_rounded),
  problem('problem', 'Problem', Icons.report_problem_outlined);

  const FeedbackType(this.key, this.label, this.icon);
  final String key;
  final String label;
  final IconData icon;

  static FeedbackType fromKey(String? key) => FeedbackType.values.firstWhere(
        (t) => t.key == key,
        orElse: () => FeedbackType.bug,
      );

  Color get color {
    switch (this) {
      case FeedbackType.bug:
        return AppColors.error;
      case FeedbackType.feature:
        return AppColors.info;
      case FeedbackType.problem:
        return AppColors.warning;
    }
  }
}

/// Status helpers for feedback items. Kept as plain strings + helpers to match
/// the DB CHECK constraint on `feedback_items.status`.
class FeedbackStatus {
  FeedbackStatus._();

  static const String open = 'open';
  static const String inProgress = 'in_progress';
  static const String fixed = 'fixed';
  static const String closed = 'closed';

  static const List<String> all = [open, inProgress, fixed, closed];

  static String label(String status) {
    switch (status) {
      case open:
        return 'Open';
      case inProgress:
        return 'In Progress';
      case fixed:
        return 'Fixed';
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
      case fixed:
        return AppColors.success;
      case closed:
        return AppColors.grey2;
      default:
        return AppColors.grey2;
    }
  }
}

/// A single feedback item submitted by a user.
class FeedbackItem {
  final String id;
  final String userId;
  final FeedbackType type;
  final String title;
  final String description;
  final String? screenshotUrl;
  final String? deviceInfo;
  final String? appVersion;
  final String? platform;
  final String status;
  final String priority;
  final int voteCount;
  final String? adminResponse;
  final String? resolvedBy;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Joined reporter identity
  final String? reporterName;
  final String? reporterAvatar;

  const FeedbackItem({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.description,
    this.screenshotUrl,
    this.deviceInfo,
    this.appVersion,
    this.platform,
    this.status = 'open',
    this.priority = 'normal',
    this.voteCount = 0,
    this.adminResponse,
    this.resolvedBy,
    required this.createdAt,
    this.updatedAt,
    this.reporterName,
    this.reporterAvatar,
  });

  factory FeedbackItem.fromJson(Map<String, dynamic> json) {
    final p = json['profiles'] as Map<String, dynamic>?;
    return FeedbackItem(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: FeedbackType.fromKey(json['type'] as String?),
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      screenshotUrl: json['screenshot_url'] as String?,
      deviceInfo: json['device_info'] as String?,
      appVersion: json['app_version'] as String?,
      platform: json['platform'] as String?,
      status: json['status'] as String? ?? 'open',
      priority: json['priority'] as String? ?? 'normal',
      voteCount: json['vote_count'] as int? ?? 0,
      adminResponse: json['admin_response'] as String?,
      resolvedBy: json['resolved_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
      reporterName: p?['full_name'] as String?,
      reporterAvatar: p?['avatar_url'] as String?,
    );
  }
}
