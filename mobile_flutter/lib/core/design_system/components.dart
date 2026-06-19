import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../extensions/theme_extensions.dart';
import '../theme/app_colors.dart';
import 'tokens.dart';
import 'typography.dart';

// ─────────────────────────────────────────────────────────────────────────────
// UnifyCard  — the ONE card widget used across the entire app
// ─────────────────────────────────────────────────────────────────────────────
enum UCardVariant { elevated, outlined, flat }

class UCard extends StatelessWidget {
  final Widget child;
  final UCardVariant variant;
  final EdgeInsetsGeometry padding;
  final BorderRadius? radius;
  final VoidCallback? onTap;
  final Color? color;

  const UCard({
    super.key,
    required this.child,
    this.variant = UCardVariant.elevated,
    this.padding = USpacing.cardPad,
    this.radius,
    this.onTap,
    this.color,
  });

  const UCard.outlined({
    super.key,
    required this.child,
    this.padding = USpacing.cardPad,
    this.radius,
    this.onTap,
    this.color,
  }) : variant = UCardVariant.outlined;

  const UCard.flat({
    super.key,
    required this.child,
    this.padding = USpacing.cardPad,
    this.radius,
    this.onTap,
    this.color,
  }) : variant = UCardVariant.flat;

  @override
  Widget build(BuildContext context) {
    final br = radius ?? URadius.baseAll;
    final bg = color ?? context.cardBg;
    final List<BoxShadow> shadow = variant == UCardVariant.elevated
        ? UShadow.card
        : UShadow.none;
    final Border? border = variant != UCardVariant.flat
        ? Border.all(color: context.borderCol, width: 0.5)
        : null;

    final container = Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: br,
        border: border,
        boxShadow: shadow,
      ),
      padding: padding,
      child: child,
    );

    if (onTap == null) return container;
    return Material(
      color: Colors.transparent,
      borderRadius: br,
      child: InkWell(
        onTap: onTap,
        borderRadius: br,
        splashColor: context.primary.withValues(alpha: 0.05),
        highlightColor: context.primary.withValues(alpha: 0.03),
        child: container,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// UnifyButton — standardised button component
// ─────────────────────────────────────────────────────────────────────────────
enum UButtonVariant { primary, secondary, ghost, danger, outline }
enum UButtonSize    { lg, md, sm }

class UButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final UButtonVariant variant;
  final UButtonSize size;
  final bool loading;
  final bool fullWidth;
  final IconData? icon;

  const UButton({
    super.key,
    required this.label,
    this.onTap,
    this.variant = UButtonVariant.primary,
    this.size = UButtonSize.lg,
    this.loading = false,
    this.fullWidth = true,
    this.icon,
  });

  const UButton.secondary({
    super.key,
    required this.label,
    this.onTap,
    this.size = UButtonSize.lg,
    this.loading = false,
    this.fullWidth = true,
    this.icon,
  }) : variant = UButtonVariant.secondary;

  const UButton.ghost({
    super.key,
    required this.label,
    this.onTap,
    this.size = UButtonSize.md,
    this.loading = false,
    this.fullWidth = false,
    this.icon,
  }) : variant = UButtonVariant.ghost;

  const UButton.danger({
    super.key,
    required this.label,
    this.onTap,
    this.size = UButtonSize.lg,
    this.loading = false,
    this.fullWidth = true,
    this.icon,
  }) : variant = UButtonVariant.danger;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null && !loading;

    double height;
    double fontSize;
    double radius;
    EdgeInsets hPad;

    switch (size) {
      case UButtonSize.lg:
        height = UTouch.button; fontSize = 15; radius = 14; hPad = const EdgeInsets.symmetric(horizontal: 24);
      case UButtonSize.md:
        height = 44; fontSize = 14; radius = 12; hPad = const EdgeInsets.symmetric(horizontal: 20);
      case UButtonSize.sm:
        height = 36; fontSize = 13; radius = 10; hPad = const EdgeInsets.symmetric(horizontal: 14);
    }

    Color bg, fg;
    Border? border;

    switch (variant) {
      case UButtonVariant.primary:
        bg = enabled ? context.primary : context.borderCol;
        fg = Colors.white;
      case UButtonVariant.secondary:
        bg = context.primary.withValues(alpha: 0.08);
        fg = context.primary;
      case UButtonVariant.outline:
        bg = Colors.transparent;
        fg = context.primary;
        border = Border.all(color: context.primary, width: 1.5);
      case UButtonVariant.ghost:
        bg = Colors.transparent;
        fg = context.primary;
      case UButtonVariant.danger:
        bg = enabled ? AppColors.error : context.borderCol;
        fg = Colors.white;
    }

    final inner = loading
        ? SizedBox(
            width: 20, height: 20,
            child: CircularProgressIndicator(color: fg, strokeWidth: 2),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, color: fg, size: fontSize + 2),
                const SizedBox(width: USpacing.sm),
              ],
              Text(label, style: TextStyle(
                fontSize: fontSize, fontWeight: FontWeight.w700,
                color: fg, letterSpacing: 0.1,
              )),
            ],
          );

    return Semantics(
      button: true,
      label: label,
      enabled: enabled,
      child: AnimatedOpacity(
        duration: UMotion.fast,
        opacity: enabled ? 1.0 : 0.5,
        child: GestureDetector(
          onTap: enabled ? onTap : null,
          child: AnimatedContainer(
            duration: UMotion.fast,
            height: height,
            width: fullWidth ? double.infinity : null,
            padding: fullWidth ? EdgeInsets.zero : hPad,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(radius),
              border: border,
            ),
            child: Center(child: inner),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// UnifyEmptyState — single consistent empty state
// ─────────────────────────────────────────────────────────────────────────────
class UEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const UEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: context.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: context.primary.withValues(alpha: 0.6)),
            ),
            const SizedBox(height: USpacing.base),
            Text(
              title,
              textAlign: TextAlign.center,
              style: UText.h4.copyWith(color: context.textPrimary),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: USpacing.sm),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: UText.bodyS.copyWith(color: context.textSecondary, height: 1.5),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: USpacing.lg),
              UButton(
                label: actionLabel!,
                onTap: onAction,
                fullWidth: false,
                size: UButtonSize.md,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// UnifyLoadingShimmer — consistent skeleton loading
// ─────────────────────────────────────────────────────────────────────────────
class UShimmerBox extends StatefulWidget {
  final double? width;
  final double height;
  final BorderRadius? radius;

  const UShimmerBox({
    super.key,
    this.width,
    this.height = 16,
    this.radius,
  });

  @override
  State<UShimmerBox> createState() => _UShimmerBoxState();
}

class _UShimmerBoxState extends State<UShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat();
    _anim = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = context.isDark
        ? const Color(0xFF2C313B)
        : const Color(0xFFE9EBF0);
    final highlight = context.isDark
        ? const Color(0xFF3A3F4A)
        : const Color(0xFFF5F7FA);

    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: widget.radius ?? URadius.smAll,
          gradient: LinearGradient(
            begin: Alignment(_anim.value - 1, 0),
            end: Alignment(_anim.value + 1, 0),
            colors: [base, highlight, base],
          ),
        ),
      ),
    );
  }
}

// Card-level shimmer for list views
class UShimmerCard extends StatelessWidget {
  const UShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: USpacing.base, vertical: USpacing.sm),
      child: UCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              UShimmerBox(width: 40, height: 40, radius: BorderRadius.circular(20)),
              const SizedBox(width: USpacing.md),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const UShimmerBox(height: 14),
                const SizedBox(height: 6),
                UShimmerBox(width: 100, height: 11),
              ])),
            ]),
            const SizedBox(height: USpacing.md),
            const UShimmerBox(height: 12),
            const SizedBox(height: 6),
            const UShimmerBox(height: 12),
            const SizedBox(height: 6),
            UShimmerBox(width: 160, height: 12),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// UnifySectionHeader — consistent section labels
// ─────────────────────────────────────────────────────────────────────────────
class USectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const USectionHeader({
    super.key,
    required this.title,
    this.action,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          USpacing.base, USpacing.lg, USpacing.base, USpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title.toUpperCase(),
              style: UText.overline.copyWith(
                color: context.textSecondary,
                letterSpacing: 0.8,
              ),
            ),
          ),
          if (action != null)
            GestureDetector(
              onTap: onAction,
              child: Text(
                action!,
                style: UText.labelS.copyWith(color: context.primary),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// UnifyAvatar — standardised avatar with initials fallback
// ─────────────────────────────────────────────────────────────────────────────
class UAvatar extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double size;
  final bool showOnline;
  final bool verified;

  const UAvatar({
    super.key,
    this.imageUrl,
    required this.name,
    this.size = 40,
    this.showOnline = false,
    this.verified = false,
  });

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  Color _seedColor() {
    final hash = name.codeUnits.fold(0, (a, b) => a + b);
    final colors = [
      const Color(0xFF0066FF),
      const Color(0xFF7C3AED),
      const Color(0xFF059669),
      const Color(0xFFEA580C),
      const Color(0xFFBE185D),
      const Color(0xFF0891B2),
    ];
    return colors[hash % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final avatarWidget = Container(
      width: size, height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: _seedColor()),
      clipBehavior: Clip.antiAlias,
      child: imageUrl != null && imageUrl!.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: imageUrl!,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => _Initials(initials: _initials, size: size),
            )
          : _Initials(initials: _initials, size: size),
    );

    if (!showOnline && !verified) return avatarWidget;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        avatarWidget,
        if (showOnline)
          Positioned(
            bottom: 0, right: 0,
            child: Container(
              width: size * 0.28, height: size * 0.28,
              decoration: BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
                border: Border.all(color: context.cardBg, width: 1.5),
              ),
            ),
          ),
        if (verified)
          Positioned(
            bottom: -2, right: -2,
            child: Container(
              width: size * 0.34, height: size * 0.34,
              decoration: BoxDecoration(
                color: context.primary,
                shape: BoxShape.circle,
                border: Border.all(color: context.cardBg, width: 1.5),
              ),
              child: Icon(Icons.check_rounded, color: Colors.white, size: size * 0.2),
            ),
          ),
      ],
    );
  }
}

class _Initials extends StatelessWidget {
  final String initials;
  final double size;
  const _Initials({required this.initials, required this.size});

  @override
  Widget build(BuildContext context) => Center(
    child: Text(
      initials,
      style: TextStyle(
        color: Colors.white,
        fontSize: size * 0.38,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// UnifySearchBar — consistent search input
// ─────────────────────────────────────────────────────────────────────────────
class USearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final EdgeInsetsGeometry padding;
  final bool autofocus;

  const USearchBar({
    super.key,
    this.controller,
    this.hint = 'Search…',
    this.onChanged,
    this.onClear,
    this.padding = const EdgeInsets.symmetric(
        horizontal: USpacing.base, vertical: USpacing.sm),
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: context.isDark
              ? context.borderCol.withValues(alpha: 0.5)
              : const Color(0xFFF0F2F5),
          borderRadius: URadius.pillAll,
        ),
        child: Row(
          children: [
            const SizedBox(width: USpacing.md),
            Icon(Icons.search_rounded, size: 18, color: context.textSecondary),
            const SizedBox(width: USpacing.sm),
            Expanded(
              child: TextField(
                controller: controller,
                autofocus: autofocus,
                onChanged: onChanged,
                style: UText.bodyS.copyWith(color: context.textPrimary),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: UText.bodyS.copyWith(color: context.textSecondary),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  filled: false,
                ),
              ),
            ),
            if (controller != null && (controller!.text.isNotEmpty))
              GestureDetector(
                onTap: () {
                  controller!.clear();
                  onClear?.call();
                  onChanged?.call('');
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: USpacing.sm),
                  child: Icon(Icons.close_rounded, size: 16, color: context.textSecondary),
                ),
              )
            else
              const SizedBox(width: USpacing.md),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// UnifyChip — filter / tag chips
// ─────────────────────────────────────────────────────────────────────────────
class UChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final IconData? icon;
  final Color? color;

  const UChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final accent = color ?? context.primary;
    final bg = selected
        ? accent
        : (context.isDark
            ? context.borderCol.withValues(alpha: 0.4)
            : const Color(0xFFF0F2F5));
    final fg = selected ? Colors.white : context.textSecondary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: UMotion.fast,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: URadius.pillAll,
          border: selected ? null : Border.all(color: context.borderCol, width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 13, color: fg),
              const SizedBox(width: 4),
            ],
            Text(label, style: UText.labelS.copyWith(color: fg, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// UnifyStatCard — metric / stat tile
// ─────────────────────────────────────────────────────────────────────────────
class UStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String? delta;

  const UStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.delta,
  });

  @override
  Widget build(BuildContext context) {
    return UCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: URadius.smAll,
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              if (delta != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.10),
                    borderRadius: URadius.pillAll,
                  ),
                  child: Text(
                    delta!,
                    style: UText.tiny.copyWith(
                      color: AppColors.success, fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(value, style: UText.h2.copyWith(color: context.textPrimary)),
          const SizedBox(height: 2),
          Text(label, style: UText.caption.copyWith(color: context.textSecondary)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// UnifyPageHeader — standardised SliverAppBar (standard page)
// ─────────────────────────────────────────────────────────────────────────────
class UPageAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBack;
  final Widget? bottom;

  const UPageAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBack = true,
    this.bottom,
  });

  @override
  Size get preferredSize => Size.fromHeight(
      bottom != null ? UTouch.appBar + 48 : UTouch.appBar);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: context.appBarBg,
      surfaceTintColor: context.appBarBg,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      shadowColor: context.borderCol,
      automaticallyImplyLeading: showBack,
      leading: showBack
          ? IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded,
                  size: 18, color: context.textPrimary),
              onPressed: () => Navigator.of(context).pop(),
            )
          : null,
      title: Text(
        title,
        style: UText.h3.copyWith(color: context.textPrimary),
      ),
      actions: actions,
      bottom: bottom != null
          ? PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: bottom!,
            )
          : null,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// UnifyBadge — notification / count badge
// ─────────────────────────────────────────────────────────────────────────────
class UBadge extends StatelessWidget {
  final int count;
  final Color? color;

  const UBadge({super.key, required this.count, this.color});

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();
    final label = count > 99 ? '99+' : '$count';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color ?? context.primary,
        borderRadius: URadius.pillAll,
      ),
      child: Text(
        label,
        style: UText.tiny.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// UnifyInfoRow — label/value metadata row (used in detail screens)
// ─────────────────────────────────────────────────────────────────────────────
class UInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;

  const UInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: iconColor ?? context.textSecondary),
          const SizedBox(width: USpacing.sm),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$label  ',
                    style: UText.caption.copyWith(color: context.textSecondary),
                  ),
                  TextSpan(
                    text: value,
                    style: UText.labelS.copyWith(color: context.textPrimary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// UnifyDivider — consistent divider
// ─────────────────────────────────────────────────────────────────────────────
class UDivider extends StatelessWidget {
  final double indent;
  const UDivider({super.key, this.indent = 0});

  @override
  Widget build(BuildContext context) =>
      Divider(height: 1, thickness: 0.5, color: context.borderCol, indent: indent);
}

// ─────────────────────────────────────────────────────────────────────────────
// UnifyBottomSheetHandle — drag handle for bottom sheets
// ─────────────────────────────────────────────────────────────────────────────
class UBottomSheetHandle extends StatelessWidget {
  const UBottomSheetHandle({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      width: 36, height: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: context.borderCol,
        borderRadius: URadius.pillAll,
      ),
    ),
  );
}
