import 'package:flutter/material.dart';

import '../theme/kulmis_auth_theme.dart';

/// Large rounded auth field with stable height and focus glow.
class AuthPremiumInput extends StatefulWidget {
  const AuthPremiumInput({
    super.key,
    required this.label,
    required this.hint,
    this.controller,
    this.prefixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.suffix,
    this.onSubmitted,
    this.maxLines = 1,
  });

  final String label;
  final String hint;
  final TextEditingController? controller;
  final IconData? prefixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffix;
  final ValueChanged<String>? onSubmitted;
  final int maxLines;

  @override
  State<AuthPremiumInput> createState() => _AuthPremiumInputState();
}

class _AuthPremiumInputState extends State<AuthPremiumInput> {
  final _focusNode = FocusNode();
  var _focused = false;

  static final _fieldTheme = InputDecorationTheme(
    filled: true,
    fillColor: Colors.transparent,
    border: InputBorder.none,
    enabledBorder: InputBorder.none,
    focusedBorder: InputBorder.none,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    hintStyle: KulmisAuthTheme.inputHint(),
  );

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocus);
  }

  void _onFocus() => setState(() => _focused = _focusNode.hasFocus);

  @override
  void dispose() {
    _focusNode.removeListener(_onFocus);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: KulmisAuthTheme.inputLabel()),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          constraints: BoxConstraints(
            minHeight: widget.maxLines > 1 ? 88 : 56,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _focused ? KulmisAuthTheme.teal : KulmisAuthTheme.borderLight,
              width: _focused ? 1.6 : 1,
            ),
            boxShadow: _focused
                ? [
                    BoxShadow(
                      color: KulmisAuthTheme.teal.withValues(alpha: 0.18),
                      blurRadius: 14,
                      spreadRadius: 0,
                    ),
                    ...KulmisAuthTheme.inputShadow,
                  ]
                : KulmisAuthTheme.inputShadow,
            color: KulmisAuthTheme.inputFill,
          ),
          child: Theme(
            data: Theme.of(context).copyWith(inputDecorationTheme: _fieldTheme),
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              obscureText: widget.obscureText,
              keyboardType: widget.keyboardType,
              maxLines: widget.maxLines,
              onSubmitted: widget.onSubmitted,
              style: KulmisAuthTheme.inputValue(),
              cursorColor: KulmisAuthTheme.teal,
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: KulmisAuthTheme.inputHint(),
                prefixIcon: widget.prefixIcon != null
                    ? Icon(
                        widget.prefixIcon,
                        color: _focused ? KulmisAuthTheme.teal : KulmisAuthTheme.inputIcon,
                        size: 22,
                      )
                    : null,
                suffixIcon: widget.suffix,
                filled: true,
                fillColor: Colors.transparent,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
