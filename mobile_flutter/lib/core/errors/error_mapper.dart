import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Maps technical exceptions to user-friendly messages.
///
/// Every error path should go through [toUserMessage] so end-users
/// never see raw Supabase, PostgREST, Dio, or Dart exception text.
///
/// Technical details are logged via [debugPrint] for developers.
class ErrorMapper {
  ErrorMapper._();

  /// Maps any [exception] to a user-friendly message string.
  /// Optionally logs the raw technical detail for debugging.
  static String toUserMessage(Object exception, {String? fallback}) {
    final message = _map(exception);
    _log(exception);
    return message;
  }

  static String _map(Object e) {
    // ── Auth errors ────────────────────────────────────────────
    if (e is AuthException) {
      return _mapAuthException(e);
    }
    if (e is AuthApiException) {
      return _mapAuthApiException(e);
    }

    // ── Database errors ────────────────────────────────────────
    if (e is PostgrestException) {
      return _mapPostgrestException(e);
    }

    // ── Network errors ─────────────────────────────────────────
    if (e.toString().contains('SocketException') ||
        e.toString().contains('HandshakeException') ||
        e.toString().contains('Connection refused') ||
        e.toString().contains('No address associated') ||
        e.toString().contains('Failed host lookup')) {
      return 'Unable to connect. Please check your internet connection and try again.';
    }
    if (e.toString().contains('TimeoutException') ||
        e.toString().contains('timed out')) {
      return 'The request timed out. Please check your connection and try again.';
    }

    // ── Storage errors ─────────────────────────────────────────
    if (e.toString().contains('StorageException') ||
        e.toString().contains('upload') && e.toString().contains('failed')) {
      return 'We couldn\'t upload this file. Please try again.';
    }

    // ── Format / parsing errors ────────────────────────────────
    if (e is FormatException) {
      return 'Something went wrong while processing data. Please try again.';
    }

    // ── Known failure types ────────────────────────────────────
    final message = e.toString();

    if (message.contains('Not authenticated') ||
        message.contains('Not logged in')) {
      return 'Please sign in to continue.';
    }
    if (message.contains('Permission') && message.contains('denied')) {
      return 'You don\'t have permission to perform this action.';
    }
    if (message.contains('duplicate key') ||
        message.contains('unique constraint')) {
      return 'This already exists. Please use a different value.';
    }
    if (message.contains('foreign key constraint')) {
      return 'The related item was not found. Please refresh and try again.';
    }
    if (message.contains('row-level security') ||
        message.contains('violates row level security')) {
      return 'You don\'t have permission to perform this action.';
    }
    if (message.contains('Profile not found')) {
      return 'Your profile could not be found. Please try signing in again.';
    }
    if (message.contains('does not exist') &&
        (message.contains('relation') || message.contains('table'))) {
      return 'Something went wrong while loading data. Please refresh and try again.';
    }

    // ── Fallback ───────────────────────────────────────────────
    return 'Something went wrong. Please try again.';
  }

  static String _mapAuthException(AuthException e) {
    final msg = e.message.toLowerCase();
    if (msg.contains('invalid login credentials') ||
        msg.contains('invalid credentials') ||
        msg.contains('wrong password') ||
        msg.contains('email or password')) {
      return 'Incorrect email or password. Please try again.';
    }
    if (msg.contains('user already registered') ||
        msg.contains('email already registered')) {
      return 'An account with this email already exists. Try signing in instead.';
    }
    if (msg.contains('password is too short')) {
      return 'Password must be at least 6 characters.';
    }
    if (msg.contains('password') && msg.contains('does not match')) {
      return 'Passwords do not match. Please try again.';
    }
    if (msg.contains('email not confirmed') ||
        msg.contains('email not verified')) {
      return 'Please verify your email address before signing in.';
    }
    if (msg.contains('user not found')) {
      return 'No account found with this email. Please check or create a new account.';
    }
    if (msg.contains('session_expired') ||
        msg.contains('token expired') ||
        msg.contains('jwt expired') ||
        msg.contains('invalid refresh token')) {
      return 'Your session has expired. Please sign in again.';
    }
    if (msg.contains('rate limit') || msg.contains('too many requests')) {
      return 'Too many attempts. Please wait a moment and try again.';
    }
    if (msg.contains('provider') && msg.contains('not supported')) {
      return 'This sign-in method is not supported. Please use email and password.';
    }
    return 'Authentication failed. Please try again.';
  }

  static String _mapAuthApiException(AuthApiException e) {
    final msg = e.message.toLowerCase();
    if (msg.contains('invalid login credentials') ||
        msg.contains('invalid credentials')) {
      return 'Incorrect email or password. Please try again.';
    }
    if (msg.contains('email not confirmed')) {
      return 'Please verify your email address before signing in.';
    }
    if (msg.contains('user already registered')) {
      return 'An account with this email already exists.';
    }
    if (msg.contains('rate limit')) {
      return 'Too many attempts. Please wait a moment.';
    }
    return 'Sign in failed. Please try again.';
  }

  static String _mapPostgrestException(PostgrestException e) {
    final code = e.code;
    final message = e.message.toLowerCase();

    if (code == 'PGRST200' || code == 'PGRST202') {
      return 'Something went wrong while loading data. Please refresh and try again.';
    }
    if (code == '42501' || message.contains('permission denied')) {
      return 'You don\'t have permission to perform this action.';
    }
    if (code == '23505' || message.contains('duplicate key') || message.contains('unique')) {
      return 'This already exists. Please use a different value.';
    }
    if (code == '23503' || message.contains('foreign key')) {
      return 'The related item was not found. Please refresh and try again.';
    }
    if (message.contains('could not find a relationship')) {
      return 'Something went wrong while loading data. Please refresh and try again.';
    }
    if (code == '42P01' || message.contains('does not exist')) {
      return 'Something went wrong while loading data. Please refresh and try again.';
    }
    if (code == '406' || message.contains('preceding')) {
      return 'Something went wrong with the data format. Please refresh.';
    }
    return 'Something went wrong while saving. Please try again.';
  }

  static void _log(Object exception) {
    debugPrint('[ErrorMapper] $exception');
  }

  // ── Specific action error messages ───────────────────────────

  static String get communityCreationFailed =>
      'We couldn\'t create the community right now. Please try again later.';
  static String get postCreationFailed =>
      'We couldn\'t create this post. Please try again.';
  static String get eventCreationFailed =>
      'We couldn\'t create this event. Please try again.';
  static String get messageFailed =>
      'We couldn\'t send your message. Please try again.';
  static String get uploadFailed =>
      'We couldn\'t upload this file. Please try again.';
  static String get profileUpdateFailed =>
      'We couldn\'t save your profile. Please try again.';
  static String get feedbackSubmissionFailed =>
      'We couldn\'t submit your feedback. Please try again.';
  static String get dataLoadFailed =>
      'Something went wrong while loading data. Please refresh and try again.';
}
