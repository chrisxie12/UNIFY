/// Study / interest fields used for filtering and recommendations.
const List<String> kOpportunityFields = [
  'Engineering',
  'Computer Science',
  'Business',
  'Medicine & Health',
  'Law',
  'Arts & Humanities',
  'Social Sciences',
  'Sciences',
  'Agriculture',
  'Education',
  'Finance & Economics',
  'Design & Creative',
];

/// Report reasons for opportunity moderation.
const List<String> kOpportunityReportReasons = [
  'Scam or fraud',
  'Broken application link',
  'Expired / closed',
  'Misleading information',
  'Duplicate',
  'Inappropriate content',
  'Other',
];

/// Reminder offsets before a deadline (label, days-before).
const List<(String, int)> kReminderOffsets = [
  ('1 day before', 1),
  ('3 days before', 3),
  ('1 week before', 7),
];
