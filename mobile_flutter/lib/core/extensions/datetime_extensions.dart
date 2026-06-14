import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

extension DateTimeExtensions on DateTime {
  String get timeAgo => timeago.format(this, allowFromNow: false);

  String get timeAgoShort => timeago.format(this, locale: 'en_short');

  String get formatDate => DateFormat('MMM d, yyyy').format(this);

  String get formatDateTime => DateFormat('MMM d, yyyy · h:mm a').format(this);

  String get formatTime => DateFormat('h:mm a').format(this);

  String get formatShortDate => DateFormat('d MMM').format(this);

  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  String get relativeLabel {
    if (isToday) return formatTime;
    if (isYesterday) return 'Yesterday';
    return formatShortDate;
  }
}

extension StringDateExtensions on String {
  DateTime get toDateTime => DateTime.parse(this).toLocal();
  String get timeAgoFromIso => DateTime.parse(this).toLocal().timeAgo;
}
