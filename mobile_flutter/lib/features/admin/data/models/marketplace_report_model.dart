class MarketplaceReportModel {
  final String id;
  final String listingId;
  final String reportedBy;
  final String reason;
  final String status;
  final String? actionTaken;
  final String? reviewedBy;
  final DateTime createdAt;
  final String? reporterName;

  const MarketplaceReportModel({
    required this.id,
    required this.listingId,
    required this.reportedBy,
    required this.reason,
    this.status = 'pending',
    this.actionTaken,
    this.reviewedBy,
    required this.createdAt,
    this.reporterName,
  });

  factory MarketplaceReportModel.fromJson(Map<String, dynamic> json) {
    final profileData = json['profiles'] as Map<String, dynamic>?;
    return MarketplaceReportModel(
      id: json['id'] as String,
      listingId: json['listing_id'] as String,
      reportedBy: json['reported_by'] as String,
      reason: json['reason'] as String,
      status: json['status'] as String? ?? 'pending',
      actionTaken: json['action_taken'] as String?,
      reviewedBy: json['reviewed_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      reporterName: profileData?['full_name'] as String?,
    );
  }
}
