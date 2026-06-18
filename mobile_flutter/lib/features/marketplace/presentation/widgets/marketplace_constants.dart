import '../../data/models/marketplace_models.dart';

/// Subcategory options offered per top-level category, used by the create
/// form and the filter chips. Empty list = free-text only.
const Map<MarketCategory, List<String>> kSubcategories = {
  MarketCategory.buySell: [
    'Phones', 'Laptops', 'Tablets', 'Headphones',
    'Books', 'Furniture', 'Electronics', 'Fashion', 'Other',
  ],
  MarketCategory.hostel: [
    'Mattresses', 'Fans', 'Kettles', 'Chairs',
    'Desks', 'Wardrobes', 'Cookware', 'Other',
  ],
  MarketCategory.academic: [
    'Printed Notes', 'Past Questions', 'Lab Manuals', 'Study Guides', 'Other',
  ],
  MarketCategory.service: [
    'Graphic Design', 'Web Development', 'App Development', 'Video Editing',
    'Photography', 'CV Writing', 'Tutoring', 'Assignment Help', 'Other',
  ],
  MarketCategory.roommate: [
    'Looking for Roommate', 'Hostel Mate', 'Apartment Mate', 'Shared Accommodation',
  ],
  MarketCategory.lostFound: [
    'Lost Item', 'Found Item',
  ],
  MarketCategory.job: [
    'Teaching Assistant', 'Student Ambassador', 'Event Volunteer',
    'Research Assistant', 'Brand Promoter', 'Campus Rep', 'Other',
  ],
  MarketCategory.internship: [
    'Internship', 'Graduate Program', 'Industrial Attachment', 'Other',
  ],
  MarketCategory.ticket: [
    'Event Pass', 'Department Ticket', 'SRC Ticket', 'Workshop', 'Other',
  ],
};

/// Item-condition options for tangible goods.
const List<(String, String)> kConditions = [
  ('new', 'Brand New'),
  ('like_new', 'Like New'),
  ('good', 'Good'),
  ('fair', 'Fair'),
  ('for_parts', 'For Parts'),
];

/// Service freelancer categories (mirror of service subcategories).
const List<String> kServiceCategories = [
  'Graphic Design', 'Web Development', 'App Development', 'Video Editing',
  'Photography', 'CV Writing', 'Tutoring', 'Assignment Help',
];

/// Report reasons for the moderation flow.
const List<String> kReportReasons = [
  'Scam or fraud',
  'Prohibited item',
  'Misleading listing',
  'Inappropriate content',
  'Duplicate listing',
  'Wrong category',
  'Other',
];

/// Categories whose detail form collects roommate-style fields.
extension MarketCategoryForm on MarketCategory {
  bool get usesCondition => switch (this) {
        MarketCategory.buySell ||
        MarketCategory.hostel ||
        MarketCategory.academic =>
          true,
        _ => false,
      };

  bool get usesRoommateFields => this == MarketCategory.roommate;
  bool get usesLostFoundFields => this == MarketCategory.lostFound;
  bool get usesJobFields =>
      this == MarketCategory.job || this == MarketCategory.internship;
  bool get usesTicketFields => this == MarketCategory.ticket;

  /// What the primary CTA on a listing card / detail should say.
  String get ctaVerb => switch (this) {
        MarketCategory.service => 'Hire',
        MarketCategory.roommate => 'Connect',
        MarketCategory.lostFound => 'Contact',
        MarketCategory.job || MarketCategory.internship => 'Apply',
        _ => 'Buy',
      };
}
