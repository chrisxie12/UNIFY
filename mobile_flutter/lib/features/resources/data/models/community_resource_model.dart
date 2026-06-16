class CommunityResourceModel {
  final String id;
  final String communityId;
  final String uploaderId;
  final String? uploaderName;
  final String? uploaderAvatar;
  final String title;
  final String? description;
  final String fileType;
  final String fileUrl;
  final int? fileSize;
  final String resourceType;
  final int downloadCount;
  final bool isApproved;
  final DateTime createdAt;

  const CommunityResourceModel({
    required this.id,
    required this.communityId,
    required this.uploaderId,
    this.uploaderName,
    this.uploaderAvatar,
    required this.title,
    this.description,
    required this.fileType,
    required this.fileUrl,
    this.fileSize,
    this.resourceType = 'other',
    this.downloadCount = 0,
    this.isApproved = false,
    required this.createdAt,
  });

  factory CommunityResourceModel.fromJson(Map<String, dynamic> json) {
    return CommunityResourceModel(
      id: json['id'] as String,
      communityId: json['community_id'] as String,
      uploaderId: json['uploader_id'] as String,
      uploaderName: json['uploader_name'] as String? ?? json['display_name'] as String?,
      uploaderAvatar: json['uploader_avatar'] as String? ?? json['avatar_url'] as String?,
      title: json['title'] as String,
      description: json['description'] as String?,
      fileType: json['file_type'] as String,
      fileUrl: json['file_url'] as String,
      fileSize: json['file_size'] as int?,
      resourceType: json['resource_type'] as String? ?? 'other',
      downloadCount: json['download_count'] as int? ?? 0,
      isApproved: json['is_approved'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'community_id': communityId,
      'uploader_id': uploaderId,
      'title': title,
      'description': description,
      'file_type': fileType,
      'file_url': fileUrl,
      'file_size': fileSize,
      'resource_type': resourceType,
    };
  }

  static const Map<String, String> resourceTypeLabels = {
    'lecture_note': 'Lecture Notes',
    'past_question': 'Past Questions',
    'assignment': 'Assignments',
    'project': 'Projects',
    'textbook': 'Textbooks',
    'study_guide': 'Study Guides',
    'other': 'Other',
  };

  static const Map<String, String> fileTypeLabels = {
    'pdf': 'PDF',
    'docx': 'Word',
    'ppt': 'PowerPoint',
    'pptx': 'PowerPoint',
    'image': 'Image',
    'zip': 'Archive',
    'video': 'Video',
    'audio': 'Audio',
    'other': 'File',
  };
}
