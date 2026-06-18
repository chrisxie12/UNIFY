import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'crash_reporting_service.dart';
import '../../bootstrap.dart';

final crashReportingServiceProvider = Provider<CrashReportingService>((ref) {
  return crashReportingService;
});
