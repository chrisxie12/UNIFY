import 'package:flutter/material.dart';
import '../../../core/design/design_tokens.dart';
import '../../../core/widgets/unify_input_field.dart';
import '../onboarding_screen.dart';

class StepShsUniversityInterest extends StatefulWidget {
  final OnboardingData data;
  final AnimationController animCtrl;

  const StepShsUniversityInterest({super.key, required this.data, required this.animCtrl});

  @override
  State<StepShsUniversityInterest> createState() => _StepShsUniversityInterestState();
}

class _StepShsUniversityInterestState extends State<StepShsUniversityInterest> {
  final _uniCtrl = TextEditingController();
  final _progCtrl = TextEditingController();

  final _universities = [
    'University of Ghana (UG)',
    'Kwame Nkrumah University of Science and Technology (KNUST)',
    'University of Cape Coast (UCC)',
    'University of Education, Winneba (UEW)',
    'University for Development Studies (UDS)',
    'University of Professional Studies, Accra (UPSA)',
    'Ghana Communication Technology University (GCTU)',
    'University of Energy and Natural Resources (UENR)',
    'Ho Technical University (HTU)',
    'Takoradi Technical University (TTU)',
    'Accra Technical University (ATU)',
  ];

  @override
  void initState() {
    super.initState();
    _uniCtrl.text = widget.data.shsPreferredUniversity ?? '';
    _progCtrl.text = widget.data.shsIntendedProgram ?? '';
  }

  @override
  void dispose() {
    _uniCtrl.dispose();
    _progCtrl.dispose();
    super.dispose();
  }

  void _save() {
    widget.data.shsPreferredUniversity = _uniCtrl.text.trim();
    widget.data.shsIntendedProgram = _progCtrl.text.trim();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: UnifySpacing.s24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: UnifySpacing.s32),
          Text('University Interest', style: UnifyTextStyle.h2()),
          const SizedBox(height: UnifySpacing.s8),
          Text('Which university are you interested in?', style: UnifyTextStyle.body()),
          const SizedBox(height: UnifySpacing.s24),
          Text('Choose a university', style: UnifyTextStyle.bodySm()),
          const SizedBox(height: UnifySpacing.s8),
          SizedBox(
            height: 200,
            child: ListView.separated(
              itemCount: _universities.length,
              separatorBuilder: (_, __) => const Divider(height: 1, color: UnifyColors.divider),
              itemBuilder: (_, i) {
                final selected = _uniCtrl.text == _universities[i];
                return ListTile(
                  dense: true,
                  selected: selected,
                  selectedTileColor: UnifyColors.primaryBlue.withValues(alpha: 0.06),
                  title: Text(_universities[i], style: const TextStyle(fontFamily: 'SpaceGrotesk', fontSize: 14)),
                  trailing: selected ? const Icon(Icons.check_circle, color: UnifyColors.primaryBlue, size: 20) : null,
                  onTap: () {
                    setState(() { _uniCtrl.text = _universities[i]; });
                    _save();
                  },
                );
              },
            ),
          ),
          const SizedBox(height: UnifySpacing.s16),
          UnifyInputField(
            controller: _progCtrl,
            label: 'Intended Program (optional)',
            hint: 'e.g. Computer Science',
            prefixIcon: const Icon(Icons.menu_book_outlined, size: 20),
            onChanged: (_) => _save(),
          ),
        ],
      ),
    );
  }
}
