import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:unify/core/design_system/tokens.dart';
import 'package:unify/core/design_system/typography.dart';
import 'package:unify/core/extensions/theme_extensions.dart';
import '../providers/event_provider.dart';

class CreateEventScreen extends ConsumerStatefulWidget {
  final String? communityId;
  const CreateEventScreen({super.key, this.communityId});
  @override
  ConsumerState<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends ConsumerState<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _venueCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final _capacityCtrl = TextEditingController();

  DateTime _eventDate = DateTime.now().add(const Duration(days: 7));
  TimeOfDay _eventTime = const TimeOfDay(hour: 10, minute: 0);
  String _eventType = 'social';
  String _category = 'community_activities';
  String _scope = 'community';
  bool _isVirtual = false;
  final String _registrationType = 'free';

  bool _saving = false;

  static const _eventTypes = [
    'class', 'study_session', 'workshop', 'hackathon', 'orientation', 'meeting', 'social', 'other',
  ];

  static const _categories = [
    'academic', 'career', 'technology', 'entertainment', 'sports', 'religious',
    'club_activities', 'community_activities', 'workshops', 'seminars', 'conferences',
  ];

  static const _categoryLabels = {
    'academic': 'Academic', 'career': 'Career', 'technology': 'Technology',
    'entertainment': 'Entertainment', 'sports': 'Sports', 'religious': 'Religious',
    'club_activities': 'Club Activities', 'community_activities': 'Community Activities',
    'workshops': 'Workshops', 'seminars': 'Seminar', 'conferences': 'Conference',
  };

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _venueCtrl.dispose();
    _contactCtrl.dispose();
    _capacityCtrl.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final repo = ref.read(eventRepositoryProvider);
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    final data = {
      'community_id': widget.communityId ?? '00000000-0000-0000-0000-000000000000',
      'creator_id': userId,
      'title': _titleCtrl.text.trim(),
      'description': _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      'location': _venueCtrl.text.trim().isEmpty ? null : _venueCtrl.text.trim(),
      'event_date': _eventDate.toIso8601String().split('T')[0],
      'event_time': '${_eventTime.hour.toString().padLeft(2, '0')}:${_eventTime.minute.toString().padLeft(2, '0')}',
      'event_type': _eventType,
      'category': _category,
      'scope': _scope,
      'is_virtual': _isVirtual,
      'registration_type': _registrationType,
      if (_contactCtrl.text.trim().isNotEmpty) 'contact_info': _contactCtrl.text.trim(),
      if (_capacityCtrl.text.trim().isNotEmpty) 'capacity': int.tryParse(_capacityCtrl.text.trim()),
    };

    try {
      await repo.createEvent(data);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event created!')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create event: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Event')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(USpacing.base),
          children: [
            TextFormField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: USpacing.md),
            TextFormField(
              controller: _descCtrl,
              decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
              maxLines: 3,
            ),
            const SizedBox(height: USpacing.md),
            TextFormField(
              controller: _venueCtrl,
              decoration: const InputDecoration(labelText: 'Venue / Location', border: OutlineInputBorder()),
            ),
            const SizedBox(height: USpacing.md),
            Row(
              children: [
                Expanded(
                  child: _DatePickerField(
                    label: 'Date',
                    value: _eventDate,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _eventDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) setState(() => _eventDate = date);
                    },
                  ),
                ),
                const SizedBox(width: USpacing.md),
                Expanded(
                  child: _TimePickerField(
                    label: 'Time',
                    value: _eventTime,
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: _eventTime,
                      );
                      if (time != null) setState(() => _eventTime = time);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: USpacing.base),
            DropdownButtonFormField<String>(
              initialValue: _eventType,
              decoration: const InputDecoration(labelText: 'Event Type', border: OutlineInputBorder()),
              items: _eventTypes.map((t) => DropdownMenuItem(value: t, child: Text(t.replaceAll('_', ' ').split(' ').map((w) => w[0].toUpperCase() + w.substring(1)).join(' ')))).toList(),
              onChanged: (v) => setState(() => _eventType = v!),
            ),
            const SizedBox(height: USpacing.md),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
              items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(_categoryLabels[c] ?? c))).toList(),
              onChanged: (v) => setState(() => _category = v!),
            ),
            const SizedBox(height: USpacing.md),
            DropdownButtonFormField<String>(
              initialValue: _scope,
              decoration: const InputDecoration(labelText: 'Scope', border: OutlineInputBorder()),
              items: ['community', 'faculty', 'university', 'campus'].map((s) => DropdownMenuItem(value: s, child: Text(s[0].toUpperCase() + s.substring(1)))).toList(),
              onChanged: (v) => setState(() => _scope = v!),
            ),
            const SizedBox(height: USpacing.md),
            TextFormField(
              controller: _capacityCtrl,
              decoration: const InputDecoration(labelText: 'Capacity (optional)', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: USpacing.md),
            SwitchListTile(
              title: const Text('Virtual Event'),
              value: _isVirtual,
              onChanged: (v) => setState(() => _isVirtual = v),
            ),
            const SizedBox(height: USpacing.md),
            TextFormField(
              controller: _contactCtrl,
              decoration: const InputDecoration(labelText: 'Contact Info (optional)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: USpacing.xl),
            FilledButton.icon(
              onPressed: _saving ? null : _create,
              icon: _saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.check),
              label: Text(_saving ? 'Creating...' : 'Create Event'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime value;
  final VoidCallback onTap;
  const _DatePickerField({required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        child: Text('${months[value.month - 1]} ${value.day}, ${value.year}'),
      ),
    );
  }
}

class _TimePickerField extends StatelessWidget {
  final String label;
  final TimeOfDay value;
  final VoidCallback onTap;
  const _TimePickerField({required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final period = value.hour >= 12 ? 'PM' : 'AM';
    final hour = value.hour == 0 ? 12 : (value.hour > 12 ? value.hour - 12 : value.hour);
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        child: Text('$hour:${value.minute.toString().padLeft(2, '0')} $period'),
      ),
    );
  }
}
