import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/supabase_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../../data/models/opportunity_models.dart';
import '../providers/opportunities_provider.dart';
import '../widgets/opportunity_constants.dart';

/// Admin create / edit form for an opportunity.
class OpportunityFormScreen extends ConsumerStatefulWidget {
  final OpportunityModel? existing;
  const OpportunityFormScreen({super.key, this.existing});

  @override
  ConsumerState<OpportunityFormScreen> createState() =>
      _OpportunityFormScreenState();
}

class _OpportunityFormScreenState
    extends ConsumerState<OpportunityFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late OpportunityType _type;
  late final _titleCtrl = TextEditingController(text: widget.existing?.title);
  late final _orgCtrl =
      TextEditingController(text: widget.existing?.organization);
  late final _summaryCtrl =
      TextEditingController(text: widget.existing?.summary);
  late final _descCtrl =
      TextEditingController(text: widget.existing?.description);
  late final _locationCtrl =
      TextEditingController(text: widget.existing?.location);
  late final _fundingCtrl =
      TextEditingController(text: widget.existing?.funding);
  late final _eligibilityCtrl =
      TextEditingController(text: widget.existing?.eligibility);
  late final _levelsCtrl =
      TextEditingController(text: widget.existing?.levels.join(', '));
  late final _tagsCtrl =
      TextEditingController(text: widget.existing?.tags.join(', '));
  late final _urlCtrl =
      TextEditingController(text: widget.existing?.applicationUrl);

  late bool _remote = widget.existing?.isRemote ?? false;
  late bool _funded = widget.existing?.isFunded ?? false;
  late bool _verified = widget.existing?.isVerified ?? false;
  late bool _featured = widget.existing?.isFeatured ?? false;
  late bool _campusOnly = widget.existing?.universityId != null;
  late DateTime? _deadline = widget.existing?.deadline;
  late final Set<String> _fields = {...?widget.existing?.fields};
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _type = widget.existing?.type ?? OpportunityType.scholarship;
  }

  @override
  void dispose() {
    for (final c in [
      _titleCtrl, _orgCtrl, _summaryCtrl, _descCtrl, _locationCtrl,
      _fundingCtrl, _eligibilityCtrl, _levelsCtrl, _tagsCtrl, _urlCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.existing != null;
    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.bg,
        surfaceTintColor: Colors.white,
        elevation: 0.6,
        shadowColor: AppColors.border,
        title: Text(editing ? 'Edit Opportunity' : 'New Opportunity',
            style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
          children: [
            _label('Type'),
            DropdownButtonFormField<OpportunityType>(
              initialValue: _type,
              decoration: _dec(),
              items: OpportunityType.values
                  .map((t) => DropdownMenuItem(
                        value: t,
                        child: Row(children: [
                          Icon(t.icon, size: 18, color: t.color),
                          const SizedBox(width: 8),
                          Text(t.label),
                        ]),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _type = v!),
            ),
            const SizedBox(height: 16),
            _label('Title'),
            _field(_titleCtrl, 'e.g. Mastercard Foundation Scholarship',
                validator: _required),
            const SizedBox(height: 16),
            _label('Organization'),
            _field(_orgCtrl, 'e.g. Mastercard Foundation'),
            const SizedBox(height: 16),
            _label('Short summary'),
            _field(_summaryCtrl, 'One line shown on cards'),
            const SizedBox(height: 16),
            _label('Description'),
            _field(_descCtrl, 'Full details of the opportunity', maxLines: 5),
            const SizedBox(height: 16),
            _label('Eligibility'),
            _field(_eligibilityCtrl, 'Who can apply', maxLines: 3),
            const SizedBox(height: 16),
            _label('Location'),
            _field(_locationCtrl, 'e.g. Accra, Ghana / Pan-African'),
            const SizedBox(height: 16),
            _label('Funding'),
            _field(_fundingCtrl, 'e.g. Fully funded / GHS 5,000 / Stipend'),
            const SizedBox(height: 16),
            _label('Application link'),
            _field(_urlCtrl, 'https://…'),
            const SizedBox(height: 16),
            _label('Target levels (comma separated)'),
            _field(_levelsCtrl, 'e.g. 100, 200, postgrad'),
            const SizedBox(height: 16),
            _label('Tags (comma separated)'),
            _field(_tagsCtrl, 'e.g. leadership, STEM'),
            const SizedBox(height: 16),
            _label('Fields of study'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: kOpportunityFields.map((f) {
                final sel = _fields.contains(f);
                return FilterChip(
                  label: Text(f),
                  selected: sel,
                  onSelected: (_) => setState(
                      () => sel ? _fields.remove(f) : _fields.add(f)),
                  selectedColor: context.primary.withValues(alpha: 0.12),
                  checkmarkColor: context.primary,
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            _label('Deadline'),
            InkWell(
              onTap: _pickDeadline,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: context.cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.borderCol),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.event_rounded,
                        size: 18, color: context.textSecondary),
                    const SizedBox(width: 10),
                    Text(
                      _deadline == null
                          ? 'No deadline (rolling)'
                          : '${_deadline!.day}/${_deadline!.month}/${_deadline!.year}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const Spacer(),
                    if (_deadline != null)
                      GestureDetector(
                        onTap: () => setState(() => _deadline = null),
                        child: const Icon(Icons.close_rounded,
                            size: 18, color: context.textDisabled),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            _switch('Funded', _funded, (v) => setState(() => _funded = v)),
            _switch('Remote', _remote, (v) => setState(() => _remote = v)),
            _switch('Verified badge', _verified,
                (v) => setState(() => _verified = v)),
            _switch('Featured', _featured,
                (v) => setState(() => _featured = v)),
            _switch('My campus only', _campusOnly,
                (v) => setState(() => _campusOnly = v)),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _busy ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: context.primary,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: _busy
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : Text(editing ? 'Save changes' : 'Publish opportunity',
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? now.add(const Duration(days: 30)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 3)),
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    setState(() => _busy = true);

    List<String> csv(String s) => s
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    String? uniId;
    if (_campusOnly) {
      try {
        final p = await ref
            .read(supabaseProvider)
            .from('profiles')
            .select('university_id')
            .eq('id', user.id)
            .maybeSingle();
        uniId = p?['university_id'] as String?;
      } catch (_) {}
    }

    final payload = <String, dynamic>{
      'type': _type.key,
      'title': _titleCtrl.text.trim(),
      'organization': _orgCtrl.text.trim().isEmpty ? null : _orgCtrl.text.trim(),
      'summary': _summaryCtrl.text.trim().isEmpty ? null : _summaryCtrl.text.trim(),
      'description':
          _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      'eligibility': _eligibilityCtrl.text.trim().isEmpty
          ? null
          : _eligibilityCtrl.text.trim(),
      'location':
          _locationCtrl.text.trim().isEmpty ? null : _locationCtrl.text.trim(),
      'funding':
          _fundingCtrl.text.trim().isEmpty ? null : _fundingCtrl.text.trim(),
      'application_url':
          _urlCtrl.text.trim().isEmpty ? null : _urlCtrl.text.trim(),
      'levels': csv(_levelsCtrl.text),
      'tags': csv(_tagsCtrl.text),
      'fields': _fields.toList(),
      'is_remote': _remote,
      'is_funded': _funded,
      'is_verified': _verified,
      'is_featured': _featured,
      'deadline': _deadline?.toIso8601String(),
      'university_id': _campusOnly ? uniId : null,
      'status': 'published',
      'posted_by': user.id,
    };

    try {
      final repo = ref.read(opportunitiesRepositoryProvider);
      if (widget.existing != null) {
        await repo.updateOpportunity(widget.existing!.id, payload);
      } else {
        await repo.createOpportunity(payload);
      }
      ref.invalidate(opportunitiesProvider);
      ref.invalidate(featuredOpportunitiesProvider);
      ref.invalidate(opportunityStatsProvider);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(widget.existing != null
              ? 'Opportunity updated'
              : 'Opportunity published'),
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Could not save: $e'),
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(t,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w700)),
      );

  Widget _switch(String t, bool v, ValueChanged<bool> on) => SwitchListTile(
        value: v,
        onChanged: on,
        title: Text(t, style: const TextStyle(fontSize: 14)),
        contentPadding: EdgeInsets.zero,
        activeThumbColor: context.primary,
        dense: true,
      );

  Widget _field(TextEditingController c, String hint,
      {int maxLines = 1, String? Function(String?)? validator}) {
    return TextFormField(
      controller: c,
      maxLines: maxLines,
      validator: validator,
      decoration: _dec(hint: hint),
    );
  }

  InputDecoration _dec({String? hint}) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: context.inputFill,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: context.borderCol)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: context.borderCol)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: context.primary, width: 1.5)),
      );

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null;
}
