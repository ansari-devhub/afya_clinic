import 'package:flutter/material.dart';

/// Inset / pressed-in neomorphic text field widget.
///
/// Features:
/// - Inset (pressed-in) neomorphic styling derived from theme surface
/// - Focus outline with theme [ColorScheme.primary]
/// - Error outline and message with theme [ColorScheme.error]
/// - Label, prefix widget or icon, suffix widget
/// - High contrast ensuring WCAG AA readability
class NeoTextField extends StatefulWidget {
  final String label;
  final String? hintText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final Widget? prefixIcon;
  final Widget? prefix;
  final Widget? suffixIcon;
  final String? errorText;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final bool enabled;
  final bool autofocus;

  const NeoTextField({
    super.key,
    required this.label,
    this.hintText,
    this.controller,
    this.focusNode,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.prefixIcon,
    this.prefix,
    this.suffixIcon,
    this.errorText,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.enabled = true,
    this.autofocus = false,
  });

  @override
  State<NeoTextField> createState() => _NeoTextFieldState();
}

class _NeoTextFieldState extends State<NeoTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(NeoTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      oldWidget.focusNode?.removeListener(_handleFocusChange);
      _focusNode = widget.focusNode ?? FocusNode();
      _focusNode.addListener(_handleFocusChange);
    }
  }

  void _handleFocusChange() {
    if (mounted) {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    }
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_handleFocusChange);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;

    final surfaceColor = colorScheme.surface;
    final primaryColor = colorScheme.primary;
    final errorColor = colorScheme.error;

    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    // Recessed background for inset styling
    final recessedBgColor = isDark
        ? Color.lerp(surfaceColor, Colors.black, 0.25)!
        : Color.lerp(surfaceColor, Colors.black, 0.04)!;

    // Dynamic border depending on focus and error state
    final Border border;
    final List<BoxShadow> shadows;

    if (hasError) {
      border = Border.all(color: errorColor, width: 1.5);
      shadows = [
        BoxShadow(
          color: errorColor.withValues(alpha: 0.15),
          blurRadius: 6,
          offset: const Offset(0, 0),
        ),
      ];
    } else if (_isFocused) {
      border = Border.all(color: primaryColor, width: 1.8);
      shadows = [
        BoxShadow(
          color: primaryColor.withValues(alpha: 0.20),
          blurRadius: 8,
          offset: const Offset(0, 1),
        ),
      ];
    } else {
      // Inset subtle shadow simulation
      final insetDarkShadow = isDark
          ? BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              offset: const Offset(1.5, 2),
              blurRadius: 4,
            )
          : BoxShadow(
              color: Color.lerp(surfaceColor, Colors.black, 0.12)!.withValues(alpha: 0.35),
              offset: const Offset(1.5, 2),
              blurRadius: 4,
            );

      final insetLightHighlight = isDark
          ? BoxShadow(
              color: Color.lerp(surfaceColor, Colors.white, 0.04)!,
              offset: const Offset(-1, -1),
              blurRadius: 2,
            )
          : BoxShadow(
              color: Colors.white.withValues(alpha: 0.8),
              offset: const Offset(-1, -1),
              blurRadius: 2,
            );

      border = Border.all(
        color: isDark
            ? Color.lerp(surfaceColor, Colors.white, 0.10)!
            : Color.lerp(surfaceColor, Colors.black, 0.08)!,
        width: 1.0,
      );

      shadows = [insetDarkShadow, insetLightHighlight];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Field Label
        Text(
          widget.label,
          style: (textTheme.bodySmall ?? const TextStyle()).copyWith(
            fontWeight: FontWeight.w600,
            color: hasError
                ? errorColor
                : _isFocused
                    ? primaryColor
                    : colorScheme.onSurfaceVariant,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 6),

        // Inset Input Box
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: recessedBgColor,
            borderRadius: BorderRadius.circular(14),
            border: border,
            boxShadow: shadows,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (widget.prefixIcon != null) ...[
                  IconTheme(
                    data: IconThemeData(
                      color: _isFocused ? primaryColor : colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                    child: widget.prefixIcon!,
                  ),
                  const SizedBox(width: 8),
                ],
                if (widget.prefix != null) ...[
                  widget.prefix!,
                  const SizedBox(width: 6),
                ],
                Expanded(
                  child: TextFormField(
                    controller: widget.controller,
                    focusNode: _focusNode,
                    obscureText: widget.obscureText,
                    keyboardType: widget.keyboardType,
                    textInputAction: widget.textInputAction,
                    enabled: widget.enabled,
                    autofocus: widget.autofocus,
                    style: (textTheme.bodyMedium ?? const TextStyle()).copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                    cursorColor: primaryColor,
                    decoration: InputDecoration(
                      hintText: widget.hintText,
                      hintStyle: (textTheme.bodyMedium ?? const TextStyle()).copyWith(
                        color: colorScheme.outline,
                        fontWeight: FontWeight.normal,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onChanged: widget.onChanged,
                    onFieldSubmitted: widget.onFieldSubmitted,
                  ),
                ),
                if (widget.suffixIcon != null) ...[
                  const SizedBox(width: 4),
                  IconTheme(
                    data: IconThemeData(
                      color: colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                    child: widget.suffixIcon!,
                  ),
                ],
              ],
            ),
          ),
        ),

        // Inline Error Message
        if (hasError) ...[
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 14,
                  color: errorColor,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    widget.errorText!,
                    style: (textTheme.bodySmall ?? const TextStyle()).copyWith(
                      color: errorColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
