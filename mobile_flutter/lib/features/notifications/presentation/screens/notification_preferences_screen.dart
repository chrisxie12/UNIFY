import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/app_loading_widget.dart';
import '../../../../core/widgets/unify_snackbar.dart';
import '../providers/notification_provider.dart';
import '../../data/models/notification_model.dart';
import '../../../../core/extensions/theme_extensions.dart';

class NotificationPreferencesScreen extends ConsumerWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefsAsync = ref.watch(notificationPreferencesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Notification Preferences')),
      body: prefsAsync.when(
        loading: () => const AppLoadingWidget.list(itemCount: 6),
        error: (e, _) => AppErrorWidget(e),
        data: (prefs) {
          if (prefs == null) {
            return const Center(child: Text('Unable to load preferences'));
          }
          return _PreferencesForm(preferences: prefs);
        },
      ),
    );
  }
}

class _PreferencesForm extends ConsumerStatefulWidget {
  final NotificationPreferences preferences;
  const _PreferencesForm({required this.preferences});

  @override
  ConsumerState<_PreferencesForm> createState() => _PreferencesFormState();
}

class _PreferencesFormState extends ConsumerState<_PreferencesForm> {
  late NotificationPreferences _prefs;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _prefs = widget.preferences;
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final repo = ref.read(notificationRepositoryProvider);
    await repo.updatePreferences(_prefs.userId, _prefs);
    ref.invalidate(notificationPreferencesProvider);
    if (!mounted) return;
    setState(() => _saving = false);
    UnifySnackbar.success(context, 'Preferences saved');
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Notification Channels', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: context.textPrimary)),
        const SizedBox(height: 4),
        Text('Control how you receive notifications', style: TextStyle(fontSize: 13, color: context.textSecondary)),
        const SizedBox(height: 16),
        _SwitchTile(
          title: 'Push Notifications',
          subtitle: 'Receive push notifications on this device',
          value: _prefs.pushEnabled,
          onChanged: (v) => setState(() => _prefs = _prefs.copyWith(pushEnabled: v)),
        ),
        _SwitchTile(
          title: 'Email Notifications',
          subtitle: 'Receive email digests for important updates',
          value: _prefs.emailEnabled,
          onChanged: (v) => setState(() => _prefs = _prefs.copyWith(emailEnabled: v)),
        ),
        const SizedBox(height: 24),
        Divider(color: context.surfaceDivider),
        const SizedBox(height: 16),
        Text('Notification Types', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: context.textPrimary)),
        const SizedBox(height: 4),
        Text('Toggle specific notification categories', style: TextStyle(fontSize: 13, color: context.textSecondary)),
        const SizedBox(height: 16),
        _SwitchTile(title: 'Messages', subtitle: 'Direct messages and group chat', value: _prefs.messages, onChanged: (v) => setState(() => _prefs = _prefs.copyWith(messages: v))),
        _SwitchTile(title: 'Communities', subtitle: 'Announcements, requests, and approvals', value: _prefs.communities, onChanged: (v) => setState(() => _prefs = _prefs.copyWith(communities: v))),
        _SwitchTile(title: 'Marketplace', subtitle: 'Inquiries, sales, and listings', value: _prefs.marketplace, onChanged: (v) => setState(() => _prefs = _prefs.copyWith(marketplace: v))),
        _SwitchTile(title: 'Events', subtitle: 'Registrations, reminders, and check-ins', value: _prefs.events, onChanged: (v) => setState(() => _prefs = _prefs.copyWith(events: v))),
        _SwitchTile(title: 'Opportunities', subtitle: 'Deadline reminders and scholarship alerts', value: _prefs.opportunities, onChanged: (v) => setState(() => _prefs = _prefs.copyWith(opportunities: v))),
        _SwitchTile(title: 'Academic Resources', subtitle: 'New resource uploads and course updates', value: _prefs.academicResources, onChanged: (v) => setState(() => _prefs = _prefs.copyWith(academicResources: v))),
        _SwitchTile(title: 'Administrative Notices', subtitle: 'Verification, roles, and broadcasts', value: _prefs.adminNotices, onChanged: (v) => setState(() => _prefs = _prefs.copyWith(adminNotices: v))),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: _saving ? null : _save,
          icon: _saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.save),
          label: Text(_saving ? 'Saving...' : 'Save Preferences'),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({required this.title, required this.subtitle, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: context.textPrimary)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: context.textSecondary)),
      value: value,
      onChanged: onChanged,
      activeTrackColor: context.primary,
    );
  }
}

extension _PrefsCopy on NotificationPreferences {
  NotificationPreferences copyWith({
    bool? messages,
    bool? communities,
    bool? marketplace,
    bool? events,
    bool? opportunities,
    bool? academicResources,
    bool? adminNotices,
    bool? pushEnabled,
    bool? emailEnabled,
  }) =>
      NotificationPreferences(
        id: id,
        userId: userId,
        messages: messages ?? this.messages,
        communities: communities ?? this.communities,
        marketplace: marketplace ?? this.marketplace,
        events: events ?? this.events,
        opportunities: opportunities ?? this.opportunities,
        academicResources: academicResources ?? this.academicResources,
        adminNotices: adminNotices ?? this.adminNotices,
        pushEnabled: pushEnabled ?? this.pushEnabled,
        emailEnabled: emailEnabled ?? this.emailEnabled,
      );
}
