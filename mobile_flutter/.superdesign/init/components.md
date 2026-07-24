# Shared UI Components (Flutter Widgets)

All core UI primitives live in `lib/core/widgets/` and use `UnifyColors` + `UnifyTextStyle` from design_tokens.dart.

---

## UnifyLogo
- **File**: `lib/core/widgets/unify_logo.dart`
- **Description**: Two white stick-figure people holding hands inside a blue circle — forms a "U" shape
- **Props**: size (double, required), backgroundColor (Color, default UnifyColors.primaryBlue), figureColor (Color, default white)

```dart
class UnifyLogo extends StatelessWidget {
  final double size;
  final Color backgroundColor;
  final Color figureColor;

  const UnifyLogo({
    super.key,
    required this.size,
    this.backgroundColor = UnifyColors.primaryBlue,
    this.figureColor = UnifyColors.textInverse,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.translate(
            offset: Offset(-size * 0.06, 0),
            child: Icon(Icons.person, size: size * 0.5, color: figureColor),
          ),
          Transform.translate(
            offset: Offset(size * 0.06, 0),
            child: Icon(Icons.person, size: size * 0.5, color: figureColor),
          ),
        ],
      ),
    );
  }
}
```

---

## UnifyPrimaryButton
- **File**: `lib/core/widgets/unify_primary_button.dart`
- **Description**: Full-width solid button with press-scale animation (0.97), loading spinner
- **Props**: label (String), onPressed (VoidCallback?), backgroundColor (Color?), height (double, default 52), prefixIcon (Widget?), loading (bool, default false)

```dart
class UnifyPrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final double height;
  final Widget? prefixIcon;
  final bool loading;
  // ...
}

// Build: GestureDetector → AnimatedScale(0.97 on press) → AnimatedContainer
// Disabled: color divider, text textTertiary
// Loading: CircularProgressIndicator replaces label
```

---

## UnifySecondaryButton
- **File**: `lib/core/widgets/unify_secondary_button.dart`
- **Description**: Full-width outlined button with press-scale animation
- **Props**: label (String), onPressed (VoidCallback?), height (double, default 52), borderColor (Color?), textColor (Color?)

```dart
class UnifySecondaryButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final double height;
  final Color? borderColor;
  final Color? textColor;
  // ...
}

// Build: GestureDetector → AnimatedScale → AnimatedContainer with transparent bg + border
```

---

## UnifyInputField
- **File**: `lib/core/widgets/unify_input_field.dart`
- **Description**: TextFormField with filled surfaceElevated background, SpaceGrotesk font
- **Props**: controller (TextEditingController), label (String), hint (String?), prefixIcon (Widget?), suffixIcon (Widget?), keyboardType, obscureText, validator, enabled, autocorrect, onChanged

```dart
class UnifyInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final bool enabled;
  final bool autocorrect;
  final ValueChanged<String>? onChanged;
  // ...

  // Build: TextFormField with InputDecoration(filled: true, fillColor: surfaceElevated)
  // Focused border: 2px primaryBlue
  // Error border: 2px error (EF4444)
}
```

---

## UnifySelectionCard
- **File**: `lib/core/widgets/unify_selection_card.dart`
- **Description**: Selectable card with icon, title, subtitle, animated checkmark on selection
- **Props**: title (String), subtitle (String?), icon (IconData), accentColor (Color), isSelected (bool), onTap (VoidCallback), height (double, default 120)

```dart
class UnifySelectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color accentColor;
  final bool isSelected;
  final VoidCallback onTap;
  final double height;
  // ...

  // Selected state: accentColor bg at 8% opacity, 2px border, md shadow
  // Unselected: white bg, 1px divider border
  // Checkmark: scale 0→1 spring animation
}
```

---

## UnifySegmentedControl
- **File**: `lib/core/widgets/unify_segmented_control.dart`
- **Description**: Pill-style segmented toggle with animated active segment
- **Props**: options (List<String>), selected (String), onChanged (ValueChanged<String>)

```dart
class UnifySegmentedControl extends StatelessWidget {
  final List<String> options;
  final String selected;
  final ValueChanged<String> onChanged;
  // ...

  // Container: surfaceElevated bg, full border-radius
  // Active segment: primaryBlue fill
  // Inactive: transparent
}
```

---

## AppErrorWidget
- **File**: `lib/core/widgets/app_error_widget.dart`
- **Description**: Error state with icon, message, optional retry button. Used in Riverpod `.when(error:)`
- **Purpose**: Replaces bare `Text('Error: $e')` patterns

## AppEmptyWidget
- **File**: `lib/core/widgets/app_empty_widget.dart`
- **Description**: Contextual empty state with icon, title, subtitle, optional action button

## UnifySnackbar
- **File**: `lib/core/widgets/unify_snackbar.dart`
- **Description**: Branded snackbar with success/error/warning/info variants, floating rounded card, optional retry
