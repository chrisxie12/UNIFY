import 'package:timeago/timeago.dart' as timeago;
import 'package:intl/intl.dart';

extension DateTimeX on DateTime {
  String get timeAgo => timeago.format(this);

  String get shortDate => DateFormat('d MMM yyyy').format(this);

  String get shortDateTime => DateFormat('d MMM, h:mm a').format(this);
}

extension StringDateX on String {
  DateTime get toDateTime => DateTime.parse(this).toLocal();

  String get timeAgo => toDateTime.timeAgo;
}
