import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/providers/supabase_provider.dart';
import '../../../../core/extensions/theme_extensions.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/widgets/app_loading_widget.dart';
import '../../../../core/widgets/unify_snackbar.dart';
import '../../data/models/marketplace_models.dart';
import '../providers/marketplace_provider.dart';
import '../widgets/marketplace_constants.dart';

class CreateListingScreen extends ConsumerWidget {
  const CreateListingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canPost = ref.watch(canPostListingProvider);
    return canPost.when(
      loading: () => const Scaffold(
          body: AppLoadingWidget.card()),
      error: (_, __) => const _Gate(),
      data: (allowed) => allowed ? const _CreateForm() : const _Gate(),
    );
  }
}

// ── Verification gate ─────────────────────────────────────────

class _Gate extends StatelessWidget {
  const _Gate();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.appBarBg,
        surfaceTintColor: context.appBarBg,
        elevation: 0,
        title: const Text('Sell on UNIFY'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: context.primary.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.verified_user_rounded,
                    size: 40, color: context.primary),
              ),
              const SizedBox(height: 20),
              const Text('Verify to start selling',
                  style: TextStyle(
                      fontSize: 19, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(
                'Only verified students can post listings. This keeps the '
                'marketplace safe and scam-free for everyone on campus.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: context.textSecondary),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => context.push('/verification-request'),
                style: FilledButton.styleFrom(
                    backgroundColor: context.primary,
                    minimumSize: const Size(220, 50)),
                child: const Text('Get verified'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Create form ───────────────────────────────────────────────

class _CreateForm extends ConsumerStatefulWidget {
  const _CreateForm();

  @override
  ConsumerState<_CreateForm> createState() => _CreateFormState();
}

class _CreateFormState extends ConsumerState<_CreateForm> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  MarketCategory _category = MarketCategory.buySell;
  String? _subcategory;
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  String _priceType = 'fixed';
  bool _negotiable = false;
  String? _condition;
  final List<File> _images = [];

  // Category-specific
  final _detailCtrls = <String, TextEditingController>{};
  bool _busy = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _locationCtrl.dispose();
    for (final c in _detailCtrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _ctrl(String key) =>
      _detailCtrls.putIfAbsent(key, () => TextEditingController());

  @override
  Widget build(BuildContext context) {
    final subs = kSubcategories[_category] ?? const [];
    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.appBarBg,
        surfaceTintColor: context.appBarBg,
        elevation: 0.6,
        shadowColor: context.borderCol,
        title: const Text('Create Listing',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
          children: [
            _label('Category'),
            _categorySelector(),
            const SizedBox(height: 16),

            if (subs.isNotEmpty) ...[
              _label('Type'),
              _dropdown(
                value: _subcategory,
                items: subs,
                hint: 'Select type',
                onChanged: (v) => setState(() => _subcategory = v),
              ),
              const SizedBox(height: 16),
            ],

            _label('Title'),
            _field(_titleCtrl, 'e.g. Used HP EliteBook, 8GB RAM',
                validator: _required),
            const SizedBox(height: 16),

            _label('Description'),
            _field(_descCtrl, 'Describe the item, condition, why you\'re selling…',
                maxLines: 4),
            const SizedBox(height: 16),

            // Photos
            _label('Photos'),
            _photoPicker(),
            const SizedBox(height: 16),

            // Price section (priced categories)
            if (_category.isPriced) ...[
              _label('Price'),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _field(_priceCtrl, '0.00',
                        keyboard: TextInputType.number,
                        prefix: 'GHS ',
                        validator: _priceType == 'fixed' || _priceType == 'hourly'
                            ? _required
                            : null),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: _dropdown(
                      value: _priceType,
                      items: const ['fixed', 'hourly', 'quote', 'free', 'swap'],
                      labels: const {
                        'fixed': 'Fixed',
                        'hourly': 'Per hour',
                        'quote': 'On request',
                        'free': 'Free',
                        'swap': 'Swap',
                      },
                      onChanged: (v) => setState(() => _priceType = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                value: _negotiable,
                onChanged: (v) => setState(() => _negotiable = v),
                title: const Text('Price negotiable',
                    style: TextStyle(fontSize: 14)),
                contentPadding: EdgeInsets.zero,
                activeThumbColor: context.primary,
              ),
              const SizedBox(height: 8),
            ],

            // Condition (goods)
            if (_category.usesCondition) ...[
              _label('Condition'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: kConditions.map((c) {
                  final sel = _condition == c.$1;
                  return ChoiceChip(
                    label: Text(c.$2),
                    selected: sel,
                    onSelected: (_) =>
                        setState(() => _condition = sel ? null : c.$1),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],

            // Location
            _label('Location'),
            _field(_locationCtrl, 'e.g. Main campus, Pent hostel'),
            const SizedBox(height: 16),

            // Category-specific fields
            ..._categoryFields(),

            const SizedBox(height: 8),
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
                  : const Text('Post listing',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  // ── Category-specific fields ─────────────────────────────────

  List<Widget> _categoryFields() {
    if (_category.usesRoommateFields) {
      return [
        _label('Gender preference'),
        _dropdown(
          value: _ctrl('gender_pref').text.isEmpty
              ? null
              : _ctrl('gender_pref').text,
          items: const ['Any', 'Male', 'Female'],
          hint: 'Any',
          onChanged: (v) => setState(() => _ctrl('gender_pref').text = v ?? ''),
        ),
        const SizedBox(height: 16),
        _label('Budget (GHS / month)'),
        _field(_ctrl('budget'), 'e.g. 500', keyboard: TextInputType.number),
        const SizedBox(height: 16),
        _label('Faculty'),
        _field(_ctrl('faculty'), 'e.g. Engineering'),
        const SizedBox(height: 16),
        _label('Level'),
        _field(_ctrl('level'), 'e.g. 200'),
        const SizedBox(height: 16),
      ];
    }
    if (_category.usesLostFoundFields) {
      return [
        _label('Last seen / found location'),
        _field(_ctrl('last_seen'), 'e.g. Library, 2nd floor'),
        const SizedBox(height: 16),
        _label('Date'),
        _field(_ctrl('date'), 'e.g. 12 June 2026'),
        const SizedBox(height: 16),
      ];
    }
    if (_category.usesJobFields) {
      return [
        _label('Organisation / Company'),
        _field(_ctrl('company'), 'e.g. SRC, MTN Ghana'),
        const SizedBox(height: 16),
        _label('Type'),
        _field(_ctrl('job_type'), 'e.g. Part-time, Remote'),
        const SizedBox(height: 16),
        _label('Compensation'),
        _field(_ctrl('compensation'), 'e.g. GHS 800/month, Stipend'),
        const SizedBox(height: 16),
        _label('Application deadline'),
        _field(_ctrl('deadline'), 'e.g. 30 June 2026'),
        const SizedBox(height: 16),
      ];
    }
    if (_category.usesTicketFields) {
      return [
        _label('Event name'),
        _field(_ctrl('event_name'), 'e.g. SRC Week Concert'),
        const SizedBox(height: 16),
        _label('Event date'),
        _field(_ctrl('event_date'), 'e.g. 20 July 2026'),
        const SizedBox(height: 16),
        _label('Quantity available'),
        _field(_ctrl('quantity'), 'e.g. 2',
            keyboard: TextInputType.number),
        const SizedBox(height: 16),
      ];
    }
    return [];
  }

  // ── Submit ───────────────────────────────────────────────────

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() => _busy = true);
    final repo = ref.read(marketplaceRepositoryProvider);
    final universityId = ref.read(marketUniversityIdProvider).valueOrNull;

    try {
      // Upload images
      final urls = <String>[];
      for (final file in _images) {
        final bytes = await file.readAsBytes();
        final ext = file.path.split('.').last;
        urls.add(await repo.uploadImage(user.id, bytes, ext));
      }

      // Build details map from category-specific controllers
      final details = <String, dynamic>{};
      for (final entry in _detailCtrls.entries) {
        if (entry.value.text.trim().isNotEmpty) {
          details[entry.key] = entry.value.text.trim();
        }
      }

      await repo.createListing(
        sellerId: user.id,
        universityId: universityId,
        category: _category,
        subcategory: _subcategory,
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim().isEmpty
            ? null
            : _descCtrl.text.trim(),
        price: _category.isPriced
            ? double.tryParse(_priceCtrl.text.trim())
            : null,
        priceType: _category.isPriced ? _priceType : 'free',
        isNegotiable: _negotiable,
        condition: _condition,
        location: _locationCtrl.text.trim().isEmpty
            ? null
            : _locationCtrl.text.trim(),
        details: details,
      );

      ref.invalidate(listingsProvider);
      ref.invalidate(myListingsProvider);
      ref.invalidate(featuredListingsProvider);

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Listing posted!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        UnifySnackbar.error(context, ErrorMapper.toUserMessage(e));
      }
    }
  }

  // ── UI helpers ───────────────────────────────────────────────

  Widget _categorySelector() {
    return SizedBox(
      height: 84,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: MarketCategory.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final c = MarketCategory.values[i];
          final sel = c == _category;
          return GestureDetector(
            onTap: () => setState(() {
              _category = c;
              _subcategory = null;
              _condition = null;
            }),
            child: Container(
              width: 76,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: sel ? c.color.withValues(alpha: 0.10) : context.cardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: sel ? c.color : context.borderCol,
                    width: sel ? 1.5 : 1),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(c.icon, color: c.color, size: 22),
                  const SizedBox(height: 6),
                  Text(c.label,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 9.5,
                          height: 1.1,
                          fontWeight: FontWeight.w600,
                          color: sel ? c.color : context.textSecondary)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _photoPicker() {
    return SizedBox(
      height: 90,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: context.cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.borderCol),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo_outlined,
                      color: context.primary, size: 24),
                  const SizedBox(height: 4),
                  Text('${_images.length}/5',
                      style: TextStyle(
                          fontSize: 11, color: context.textSecondary)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          ..._images.asMap().entries.map((e) => Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(e.value,
                          width: 90, height: 90, fit: BoxFit.cover),
                    ),
                    Positioned(
                      top: 2,
                      right: 2,
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _images.removeAt(e.key)),
                        child: Container(
                          decoration: BoxDecoration(
                              color: context.textSecondary,
                              shape: BoxShape.circle),
                          child: const Icon(Icons.close,
                              size: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    if (_images.length >= 5) return;
    final picked = await _picker.pickImage(
        source: ImageSource.gallery, imageQuality: 80, maxWidth: 1600);
    if (picked != null) {
      setState(() => _images.add(File(picked.path)));
    }
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: context.textPrimary)),
      );

  Widget _field(
    TextEditingController c,
    String hint, {
    int maxLines = 1,
    TextInputType? keyboard,
    String? prefix,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: c,
      maxLines: maxLines,
      keyboardType: keyboard,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        prefixText: prefix,
        filled: true,
        fillColor: context.cardBg,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: context.borderCol)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: context.borderCol)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: context.primary, width: 1.5)),
      ),
    );
  }

  Widget _dropdown({
    required String? value,
    required List<String> items,
    String? hint,
    Map<String, String>? labels,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      hint: hint != null ? Text(hint) : null,
      decoration: InputDecoration(
        filled: true,
        fillColor: context.cardBg,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: context.borderCol)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: context.borderCol)),
      ),
      items: items
          .map((i) => DropdownMenuItem(
              value: i, child: Text(labels?[i] ?? i)))
          .toList(),
      onChanged: onChanged,
    );
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null;
}