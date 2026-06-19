import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/unify_snackbar.dart';
import '../../domain/entities/profile.dart';
import '../providers/profile_provider.dart';
import '../../../../core/extensions/theme_extensions.dart';

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

const List<String> _kInterests = [
  'Technology',
  'AI / ML',
  'Startups',
  'Football',
  'Basketball',
  'Gaming',
  'Music',
  'Design',
  'Photography',
  'Reading',
  'Coding',
  'Business',
  'Fashion',
  'Travel',
  'Art',
  'Science',
];

const List<String> _kSkills = [
  'Flutter',
  'Python',
  'JavaScript',
  'React',
  'Node.js',
  'Data Analysis',
  'Machine Learning',
  'UI/UX Design',
  'Graphic Design',
  'Video Editing',
  'Photography',
  'Writing',
  'Public Speaking',
  'Leadership',
  'Project Management',
  'Marketing',
  'Research',
  'Teaching',
  'Music Production',
  'Cybersecurity',
  'Networking',
  'Database Design',
  'Cloud Computing',
  'Entrepreneurship',
];

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  // ── Text controllers ──────────────────────────────────────────────────────
  late final TextEditingController _displayNameCtrl;
  late final TextEditingController _usernameCtrl;
  late final TextEditingController _bioCtrl;
  late final TextEditingController _schoolCtrl;
  late final TextEditingController _programmeCtrl;
  late final TextEditingController _facultyCtrl;
  late final TextEditingController _departmentCtrl;
  late final TextEditingController _campusCtrl;
  late final TextEditingController _graduationYearCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _hostelCtrl;
  late final TextEditingController _instagramCtrl;
  late final TextEditingController _tiktokCtrl;
  late final TextEditingController _snapchatCtrl;
  late final TextEditingController _linkedinCtrl;
  late final TextEditingController _twitterCtrl;
  late final TextEditingController _githubCtrl;
  late final TextEditingController _portfolioCtrl;

  // ── Non-text state ────────────────────────────────────────────────────────
  int? _yearOfStudy;
  List<String> _interests = [];
  List<String> _skills = [];
  String _privacyLevel = 'public';

  // ── Original values (for dirty-check) ────────────────────────────────────
  Profile? _original;

  // ── Loading flags ─────────────────────────────────────────────────────────
  bool _isSaving = false;
  bool _isUploadingPhoto = false;
  bool _isUploadingCover = false;

  // ── Pending upload URLs ───────────────────────────────────────────────────
  String? _pendingAvatarUrl;
  String? _pendingCoverUrl;

  @override
  void initState() {
    super.initState();
    _displayNameCtrl = TextEditingController();
    _usernameCtrl = TextEditingController();
    _bioCtrl = TextEditingController();
    _schoolCtrl = TextEditingController();
    _programmeCtrl = TextEditingController();
    _facultyCtrl = TextEditingController();
    _departmentCtrl = TextEditingController();
    _campusCtrl = TextEditingController();
    _graduationYearCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
    _hostelCtrl = TextEditingController();
    _instagramCtrl = TextEditingController();
    _tiktokCtrl = TextEditingController();
    _snapchatCtrl = TextEditingController();
    _linkedinCtrl = TextEditingController();
    _twitterCtrl = TextEditingController();
    _githubCtrl = TextEditingController();
    _portfolioCtrl = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profile = ref.read(profileProvider).valueOrNull;
      if (profile != null) _populateFromProfile(profile);
    });
  }

  @override
  void dispose() {
    _displayNameCtrl.dispose();
    _usernameCtrl.dispose();
    _bioCtrl.dispose();
    _schoolCtrl.dispose();
    _programmeCtrl.dispose();
    _facultyCtrl.dispose();
    _departmentCtrl.dispose();
    _campusCtrl.dispose();
    _graduationYearCtrl.dispose();
    _phoneCtrl.dispose();
    _hostelCtrl.dispose();
    _instagramCtrl.dispose();
    _tiktokCtrl.dispose();
    _snapchatCtrl.dispose();
    _linkedinCtrl.dispose();
    _twitterCtrl.dispose();
    _githubCtrl.dispose();
    _portfolioCtrl.dispose();
    super.dispose();
  }

  void _populateFromProfile(Profile profile) {
    _original = profile;
    _displayNameCtrl.text = profile.displayName ?? '';
    _usernameCtrl.text = profile.username ?? '';
    _bioCtrl.text = profile.bio ?? '';
    _schoolCtrl.text = profile.school ?? '';
    _programmeCtrl.text = profile.programme ?? '';
    _facultyCtrl.text = profile.faculty ?? '';
    _departmentCtrl.text = profile.department ?? '';
    _campusCtrl.text = profile.campus ?? '';
    _graduationYearCtrl.text = profile.expectedGraduationYear?.toString() ?? '';
    _phoneCtrl.text = profile.phone ?? '';
    _hostelCtrl.text = profile.hostel ?? '';
    _instagramCtrl.text = profile.instagramUrl ?? '';
    _tiktokCtrl.text = profile.tiktokUrl ?? '';
    _snapchatCtrl.text = profile.snapchatUrl ?? '';
    _linkedinCtrl.text = profile.linkedinUrl ?? '';
    _twitterCtrl.text = profile.twitterUrl ?? '';
    _githubCtrl.text = profile.githubUrl ?? '';
    _portfolioCtrl.text = profile.portfolioUrl ?? '';
    setState(() {
      _yearOfStudy = profile.yearOfStudy;
      _interests = List<String>.from(profile.interests);
      _skills = List<String>.from(profile.skills);
      _privacyLevel = profile.privacyLevel;
    });
  }

  // ── Dirty check ───────────────────────────────────────────────────────────

  bool get _hasChanges {
    if (_original == null) return false;
    final p = _original!;
    if (_displayNameCtrl.text != (p.displayName ?? '')) return true;
    if (_usernameCtrl.text != (p.username ?? '')) return true;
    if (_bioCtrl.text != (p.bio ?? '')) return true;
    if (_schoolCtrl.text != (p.school ?? '')) return true;
    if (_programmeCtrl.text != (p.programme ?? '')) return true;
    if (_facultyCtrl.text != (p.faculty ?? '')) return true;
    if (_departmentCtrl.text != (p.department ?? '')) return true;
    if (_campusCtrl.text != (p.campus ?? '')) return true;
    final gradYear = int.tryParse(_graduationYearCtrl.text);
    if (gradYear != p.expectedGraduationYear) return true;
    if (_yearOfStudy != p.yearOfStudy) return true;
    if (_phoneCtrl.text != (p.phone ?? '')) return true;
    if (_hostelCtrl.text != (p.hostel ?? '')) return true;
    if (_instagramCtrl.text != (p.instagramUrl ?? '')) return true;
    if (_tiktokCtrl.text != (p.tiktokUrl ?? '')) return true;
    if (_snapchatCtrl.text != (p.snapchatUrl ?? '')) return true;
    if (_linkedinCtrl.text != (p.linkedinUrl ?? '')) return true;
    if (_twitterCtrl.text != (p.twitterUrl ?? '')) return true;
    if (_githubCtrl.text != (p.githubUrl ?? '')) return true;
    if (_portfolioCtrl.text != (p.portfolioUrl ?? '')) return true;
    if (_interests.length != p.interests.length) return true;
    for (final i in _interests) {
      if (!p.interests.contains(i)) return true;
    }
    if (_skills.length != p.skills.length) return true;
    for (final s in _skills) {
      if (!p.skills.contains(s)) return true;
    }
    if (_privacyLevel != p.privacyLevel) return true;
    if (_pendingAvatarUrl != null) return true;
    if (_pendingCoverUrl != null) return true;
    return false;
  }

  // ── Avatar picker ─────────────────────────────────────────────────────────

  Future<void> _pickAvatar(ImageSource source) async {
    Navigator.pop(context);
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (file == null) return;

    final client = ref.read(supabaseProvider);
    final userId = client.auth.currentUser?.id;
    if (userId == null) return;

    setState(() => _isUploadingPhoto = true);
    try {
      final Uint8List bytes = await file.readAsBytes();
      final ext = file.name.split('.').last.toLowerCase();
      final repo = ref.read(profileRepositoryProvider);
      final url = await repo.uploadAvatar(userId, bytes, ext);
      setState(() => _pendingAvatarUrl = url);
    } catch (e) {
      if (mounted) {
        UnifySnackbar.error(context, ErrorMapper.toUserMessage(e));
      }
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }

  void _showAvatarOptions() {
    _showPhotoBottomSheet(
      title: 'Profile Photo',
      onCamera: () => _pickAvatar(ImageSource.camera),
      onGallery: () => _pickAvatar(ImageSource.gallery),
    );
  }

  // ── Cover photo picker ────────────────────────────────────────────────────

  Future<void> _pickCover(ImageSource source) async {
    Navigator.pop(context);
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(
      source: source,
      maxWidth: 1200,
      maxHeight: 600,
      imageQuality: 85,
    );
    if (file == null) return;

    final client = ref.read(supabaseProvider);
    final userId = client.auth.currentUser?.id;
    if (userId == null) return;

    setState(() => _isUploadingCover = true);
    try {
      final Uint8List bytes = await file.readAsBytes();
      final ext = file.name.split('.').last.toLowerCase();
      final repo = ref.read(profileRepositoryProvider);
      final url = await repo.uploadCoverPhoto(userId, bytes, ext);
      setState(() => _pendingCoverUrl = url);
    } catch (e) {
      if (mounted) {
        UnifySnackbar.error(context, ErrorMapper.toUserMessage(e));
      }
    } finally {
      if (mounted) setState(() => _isUploadingCover = false);
    }
  }

  void _showCoverOptions() {
    _showPhotoBottomSheet(
      title: 'Cover Photo',
      onCamera: () => _pickCover(ImageSource.camera),
      onGallery: () => _pickCover(ImageSource.gallery),
    );
  }

  void _showPhotoBottomSheet({
    required String title,
    required VoidCallback onCamera,
    required VoidCallback onGallery,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: AppColors.grey4,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(title, style: AppTextStyles.h3),
                ),
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: context.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.camera_alt_outlined, color: context.primary),
                  ),
                  title: Text('Take Photo', style: AppTextStyles.bodySemi),
                  onTap: onCamera,
                ),
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: context.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.photo_library_outlined, color: context.primary),
                  ),
                  title: Text('Choose from Gallery', style: AppTextStyles.bodySemi),
                  onTap: onGallery,
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Save ──────────────────────────────────────────────────────────────────

  Future<void> _save() async {
    if (_isSaving) return;
    final client = ref.read(supabaseProvider);
    final userId = client.auth.currentUser?.id;
    if (userId == null) return;

    setState(() => _isSaving = true);
    try {
      final updates = <String, dynamic>{
        'display_name': _displayNameCtrl.text.trim(),
        'username': _usernameCtrl.text.trim().isEmpty ? null : _usernameCtrl.text.trim(),
        'bio': _bioCtrl.text.trim().isEmpty ? null : _bioCtrl.text.trim(),
        'school': _schoolCtrl.text.trim().isEmpty ? null : _schoolCtrl.text.trim(),
        'programme': _programmeCtrl.text.trim().isEmpty ? null : _programmeCtrl.text.trim(),
        'faculty': _facultyCtrl.text.trim().isEmpty ? null : _facultyCtrl.text.trim(),
        'department': _departmentCtrl.text.trim().isEmpty ? null : _departmentCtrl.text.trim(),
        'campus': _campusCtrl.text.trim().isEmpty ? null : _campusCtrl.text.trim(),
        'year_of_study': _yearOfStudy,
        'expected_graduation_year': int.tryParse(_graduationYearCtrl.text.trim()),
        'phone': _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
        'hostel': _hostelCtrl.text.trim().isEmpty ? null : _hostelCtrl.text.trim(),
        'instagram_url': _instagramCtrl.text.trim().isEmpty ? null : _instagramCtrl.text.trim(),
        'tiktok_url': _tiktokCtrl.text.trim().isEmpty ? null : _tiktokCtrl.text.trim(),
        'snapchat_url': _snapchatCtrl.text.trim().isEmpty ? null : _snapchatCtrl.text.trim(),
        'linkedin_url': _linkedinCtrl.text.trim().isEmpty ? null : _linkedinCtrl.text.trim(),
        'twitter_url': _twitterCtrl.text.trim().isEmpty ? null : _twitterCtrl.text.trim(),
        'github_url': _githubCtrl.text.trim().isEmpty ? null : _githubCtrl.text.trim(),
        'portfolio_url': _portfolioCtrl.text.trim().isEmpty ? null : _portfolioCtrl.text.trim(),
        'interests': _interests,
        'skills': _skills,
        'privacy_level': _privacyLevel,
        if (_pendingAvatarUrl != null) 'avatar_url': _pendingAvatarUrl,
        if (_pendingCoverUrl != null) 'cover_photo_url': _pendingCoverUrl,
      };

      final repo = ref.read(profileRepositoryProvider);
      await repo.updateProfile(userId, updates);

      if (mounted) {
        UnifySnackbar.success(context, 'Profile updated!');
        ref.invalidate(profileProvider);
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        UnifySnackbar.error(context, ErrorMapper.toUserMessage(e));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ── Unsaved-changes guard ─────────────────────────────────────────────────

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;
    final discard = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Discard changes?', style: AppTextStyles.h3),
        content: Text('You have unsaved changes. Discard them?', style: AppTextStyles.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep Editing'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Discard', style: TextStyle(color: context.error)),
          ),
        ],
      ),
    );
    return discard ?? false;
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider);

    profileAsync.whenData((profile) {
      if (profile != null && _original == null) {
        _populateFromProfile(profile);
      }
    });

    final currentAvatarUrl = _pendingAvatarUrl ?? profileAsync.valueOrNull?.avatarUrl;
    final currentCoverUrl = _pendingCoverUrl ?? profileAsync.valueOrNull?.coverPhotoUrl;
    final initials = profileAsync.valueOrNull?.initials ?? 'U';

    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final ok = await _onWillPop();
        if (ok && context.mounted) context.pop();
      },
      child: Scaffold(
        backgroundColor: context.bg,
        appBar: AppBar(
          backgroundColor: context.appBarBg,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          title: Text('Edit Profile', style: AppTextStyles.h3),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () async {
              final ok = await _onWillPop();
              if (ok && context.mounted) context.pop();
            },
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _isSaving
                  ? const Padding(
                      padding: EdgeInsets.all(14),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : TextButton(
                      onPressed: _hasChanges && !_isSaving ? _save : null,
                      child: Text(
                        'Save',
                        style: AppTextStyles.bodySemi.copyWith(
                          color: _hasChanges ? context.primary : context.textDisabled,
                        ),
                      ),
                    ),
            ),
          ],
        ),
        body: Stack(
          children: [
            profileAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => AppErrorWidget(e),
              data: (_) => _buildForm(currentAvatarUrl, currentCoverUrl, initials),
            ),
            if (_isUploadingPhoto || _isUploadingCover)
              Container(
                color: Colors.black38,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: Colors.white),
                      const SizedBox(height: 16),
                      Text(
                        _isUploadingCover ? 'Uploading cover…' : 'Uploading photo…',
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(String? avatarUrl, String? coverUrl, String initials) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Cover photo ──────────────────────────────────────────────────
          _buildCoverSection(coverUrl),
          const SizedBox(height: 16),

          // ── Avatar ───────────────────────────────────────────────────────
          _buildAvatarSection(avatarUrl, initials),
          const SizedBox(height: 32),

          // ── BASIC INFO ───────────────────────────────────────────────────
          const _SectionLabel(title: 'BASIC INFO'),
          const SizedBox(height: 12),
          _FormCard(
            children: [
              AppTextField(
                label: 'Full Name',
                hint: 'e.g. Kwame Mensah',
                controller: _displayNameCtrl,
                capitalization: TextCapitalization.words,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 20),
              _UsernameField(controller: _usernameCtrl, onChanged: (_) => setState(() {})),
              const SizedBox(height: 20),
              AppTextField(
                label: 'Bio',
                hint: 'Tell people about yourself…',
                controller: _bioCtrl,
                maxLines: 4,
                onChanged: (_) => setState(() {}),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── ACADEMIC ─────────────────────────────────────────────────────
          const _SectionLabel(title: 'ACADEMIC'),
          const SizedBox(height: 12),
          _FormCard(
            children: [
              AppTextField(
                label: 'School / University',
                hint: 'e.g. GCTU',
                controller: _schoolCtrl,
                capitalization: TextCapitalization.words,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 20),
              AppTextField(
                label: 'Programme',
                hint: 'e.g. BSc. Computer Science',
                controller: _programmeCtrl,
                capitalization: TextCapitalization.words,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 20),
              AppTextField(
                label: 'Faculty',
                hint: 'e.g. Faculty of Applied Sciences',
                controller: _facultyCtrl,
                capitalization: TextCapitalization.words,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 20),
              AppTextField(
                label: 'Department',
                hint: 'e.g. Department of Computing',
                controller: _departmentCtrl,
                capitalization: TextCapitalization.words,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 20),
              _YearSelector(
                selected: _yearOfStudy,
                onSelect: (y) => setState(() => _yearOfStudy = y),
              ),
              const SizedBox(height: 20),
              AppTextField(
                label: 'Expected Graduation Year',
                hint: 'e.g. 2027',
                controller: _graduationYearCtrl,
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── CONTACT ──────────────────────────────────────────────────────
          const _SectionLabel(title: 'CONTACT'),
          const SizedBox(height: 12),
          _FormCard(
            children: [
              AppTextField(
                label: 'Campus',
                hint: 'e.g. East Legon Campus',
                controller: _campusCtrl,
                capitalization: TextCapitalization.words,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 20),
              AppTextField(
                label: 'Hostel / Residence (optional)',
                hint: 'e.g. Valco Hall',
                controller: _hostelCtrl,
                capitalization: TextCapitalization.words,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 20),
              AppTextField(
                label: 'Phone Number (optional)',
                hint: 'e.g. +233 20 000 0000',
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                onChanged: (_) => setState(() {}),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── SOCIAL LINKS ─────────────────────────────────────────────────
          const _SectionLabel(title: 'SOCIAL LINKS'),
          const SizedBox(height: 12),
          _FormCard(
            children: [
              _SocialField(
                label: 'Instagram',
                hint: 'https://instagram.com/yourhandle',
                controller: _instagramCtrl,
                icon: Icons.camera_alt_outlined,
                iconColor: const Color(0xFFE1306C),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 20),
              _SocialField(
                label: 'TikTok',
                hint: 'https://tiktok.com/@yourhandle',
                controller: _tiktokCtrl,
                icon: Icons.music_note_rounded,
                iconColor: const Color(0xFFFF0050),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 20),
              _SocialField(
                label: 'Snapchat',
                hint: 'https://snapchat.com/add/yourhandle',
                controller: _snapchatCtrl,
                icon: Icons.chat_bubble_outline_rounded,
                iconColor: const Color(0xFFFFE921),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 20),
              _SocialField(
                label: 'LinkedIn',
                hint: 'https://linkedin.com/in/yourname',
                controller: _linkedinCtrl,
                icon: Icons.work_outline,
                iconColor: const Color(0xFF0077B5),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 20),
              _SocialField(
                label: 'Twitter / X',
                hint: 'https://x.com/yourhandle',
                controller: _twitterCtrl,
                icon: Icons.alternate_email,
                iconColor: const Color(0xFF1DA1F2),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 20),
              _SocialField(
                label: 'GitHub',
                hint: 'https://github.com/yourusername',
                controller: _githubCtrl,
                icon: Icons.code,
                iconColor: context.textPrimary,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 20),
              _SocialField(
                label: 'Portfolio URL',
                hint: 'https://yourportfolio.com',
                controller: _portfolioCtrl,
                icon: Icons.language,
                iconColor: context.primary,
                onChanged: (_) => setState(() {}),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── INTERESTS ────────────────────────────────────────────────────
          const _SectionLabel(title: 'INTERESTS'),
          const SizedBox(height: 12),
          _ToggleChipGrid(
            items: _kInterests,
            selected: _interests,
            onToggle: (item) {
              setState(() {
                if (_interests.contains(item)) {
                  _interests.remove(item);
                } else {
                  _interests.add(item);
                }
              });
            },
          ),
          const SizedBox(height: 24),

          // ── SKILLS ───────────────────────────────────────────────────────
          const _SectionLabel(title: 'SKILLS'),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'Select skills that represent what you can do',
              style: AppTextStyles.caption.copyWith(color: context.textSecondary),
            ),
          ),
          _ToggleChipGrid(
            items: _kSkills,
            selected: _skills,
            activeColor: const Color(0xFF059669),
            onToggle: (item) {
              setState(() {
                if (_skills.contains(item)) {
                  _skills.remove(item);
                } else {
                  _skills.add(item);
                }
              });
            },
          ),
          const SizedBox(height: 24),

          // ── PRIVACY ──────────────────────────────────────────────────────
          const _SectionLabel(title: 'PRIVACY'),
          const SizedBox(height: 12),
          _PrivacySelector(
            selected: _privacyLevel,
            onSelect: (v) => setState(() {
              _privacyLevel = v;
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCoverSection(String? coverUrl) {
    return GestureDetector(
      onTap: _showCoverOptions,
      child: Stack(
        children: [
          Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [Color(0xFF0D2F7A), Color(0xFF4338CA), Color(0xFF6D28D9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: coverUrl != null && coverUrl.isNotEmpty
                ? Image.network(coverUrl, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox())
                : null,
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.black.withValues(alpha: 0.22),
              ),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 0.8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.camera_alt_outlined, color: Colors.white, size: 16),
                      SizedBox(width: 6),
                      Text('Edit Cover Photo', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarSection(String? avatarUrl, String initials) {
    return Center(
      child: GestureDetector(
        onTap: _showAvatarOptions,
        child: Stack(
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: context.primary.withValues(alpha: 0.2), width: 3),
              ),
              child: ClipOval(
                child: avatarUrl != null && avatarUrl.isNotEmpty
                    ? Image.network(
                        avatarUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _AvatarInitials(initials: initials),
                      )
                    : _AvatarInitials(initials: initials),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: context.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 2),
                ),
                child: const Icon(Icons.camera_alt, color: Colors.white, size: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section label
// ---------------------------------------------------------------------------

class _SectionLabel extends StatelessWidget {
  final String title;
  const _SectionLabel({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title, style: AppTextStyles.labelS.copyWith(letterSpacing: 1.2));
  }
}

// ---------------------------------------------------------------------------
// Form card wrapper
// ---------------------------------------------------------------------------

class _FormCard extends StatelessWidget {
  final List<Widget> children;
  const _FormCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: context.cardBg,
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: context.borderCol, width: 0.5),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Username field with @ prefix
// ---------------------------------------------------------------------------

class _UsernameField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  const _UsernameField({required this.controller, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Username', style: AppTextStyles.label),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          onChanged: onChanged,
          keyboardType: TextInputType.text,
          textCapitalization: TextCapitalization.none,
          style: TextStyle(fontSize: 14, color: context.textPrimary),
          decoration: InputDecoration(
            hintText: 'yourhandle',
            prefixText: '@',
            prefixStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: context.primary,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Social link field with coloured icon prefix
// ---------------------------------------------------------------------------

class _SocialField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final IconData icon;
  final Color iconColor;
  final ValueChanged<String>? onChanged;

  const _SocialField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.icon,
    required this.iconColor,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, color: iconColor, size: 13),
            ),
            const SizedBox(width: 8),
            Text(label, style: AppTextStyles.label),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          onChanged: onChanged,
          keyboardType: TextInputType.url,
          style: TextStyle(fontSize: 14, color: context.textPrimary),
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Year of study selector chips
// ---------------------------------------------------------------------------

class _YearSelector extends StatelessWidget {
  final int? selected;
  final ValueChanged<int?> onSelect;
  const _YearSelector({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Year of Study', style: AppTextStyles.label),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: List.generate(4, (i) {
            final year = i + 1;
            final active = selected == year;
            return GestureDetector(
              onTap: () => onSelect(active ? null : year),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: active ? context.primary : context.primary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: active ? context.primary : context.primary.withValues(alpha: 0.25),
                  ),
                ),
                child: Text(
                  'Year $year',
                  style: AppTextStyles.label.copyWith(
                    color: active ? Colors.white : context.primary,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Reusable toggle chip grid (interests + skills)
// ---------------------------------------------------------------------------

class _ToggleChipGrid extends StatelessWidget {
  final List<String> items;
  final List<String> selected;
  final ValueChanged<String> onToggle;
  final Color? activeColor;

  const _ToggleChipGrid({
    required this.items,
    required this.selected,
    required this.onToggle,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = activeColor ?? context.primary;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBg,
        border: Border.all(color: context.borderCol, width: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: items.map((item) {
          final active = selected.contains(item);
          return GestureDetector(
            onTap: () => onToggle(item),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: active ? color : color.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: active ? color : color.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                item,
                style: AppTextStyles.label.copyWith(
                  color: active ? Colors.white : color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Privacy level selector
// ---------------------------------------------------------------------------

class _PrivacySelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;

  const _PrivacySelector({required this.selected, required this.onSelect});

  static const _options = [
    (
      value: 'public',
      emoji: '🌍',
      label: 'Public',
      desc: 'Anyone can discover and view your profile',
    ),
    (
      value: 'university',
      emoji: '🏫',
      label: 'University Only',
      desc: 'Only verified students at your university',
    ),
    (
      value: 'friends',
      emoji: '👥',
      label: 'Friends Only',
      desc: 'Only people you are connected with',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _options.map((opt) {
        final active = selected == opt.value;
        return GestureDetector(
          onTap: () => onSelect(opt.value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: active ? context.primary.withValues(alpha: 0.07) : context.cardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: active ? context.primary : context.borderCol,
                width: active ? 1.5 : 0.5,
              ),
            ),
            child: Row(
              children: [
                Text(opt.emoji, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(opt.label, style: AppTextStyles.bodySemi),
                      const SizedBox(height: 2),
                      Text(opt.desc, style: AppTextStyles.caption.copyWith(color: context.textSecondary)),
                    ],
                  ),
                ),
                if (active)
                  Icon(Icons.check_circle_rounded, color: context.primary, size: 20),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ---------------------------------------------------------------------------
// Avatar initials fallback
// ---------------------------------------------------------------------------

class _AvatarInitials extends StatelessWidget {
  final String initials;
  const _AvatarInitials({required this.initials});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.primaryLight,
      alignment: Alignment.center,
      child: Text(
        initials,
        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white),
      ),
    );
  }
}
