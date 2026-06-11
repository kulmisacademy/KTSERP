import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/kulmis_auth_theme.dart';

/// Premium 6-digit OTP entry with auto-advance and paste support.
class OtpInputWidget extends StatefulWidget {
  const OtpInputWidget({
    super.key,
    required this.onCompleted,
    this.enabled = true,
    this.length = 6,
  });

  final ValueChanged<String> onCompleted;
  final bool enabled;
  final int length;

  @override
  State<OtpInputWidget> createState() => OtpInputWidgetState();
}

class OtpInputWidgetState extends State<OtpInputWidget> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.enabled) _focusNodes.first.requestFocus();
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get code => _controllers.map((c) => c.text).join();

  void clear() {
    for (final c in _controllers) {
      c.clear();
    }
    _focusNodes.first.requestFocus();
  }

  void _onChanged(int index, String value) {
    if (value.length > 1) {
      _applyPaste(value, index);
      return;
    }
    if (value.isNotEmpty && index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    if (code.length == widget.length) {
      widget.onCompleted(code);
    }
  }

  void _applyPaste(String raw, int startIndex) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    var i = startIndex;
    for (final d in digits.split('')) {
      if (i >= widget.length) break;
      _controllers[i].text = d;
      i++;
    }
    if (code.length == widget.length) {
      widget.onCompleted(code);
      FocusScope.of(context).unfocus();
    } else if (i < widget.length) {
      _focusNodes[i].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.length, (i) {
        return Padding(
          padding: EdgeInsets.only(right: i == widget.length - 1 ? 0 : 10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 48,
            height: 56,
            child: TextField(
              controller: _controllers[i],
              focusNode: _focusNodes[i],
              enabled: widget.enabled,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 1,
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: KulmisAuthTheme.textDark,
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                counterText: '',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: KulmisAuthTheme.borderLight),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: KulmisAuthTheme.borderLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: KulmisAuthTheme.teal, width: 2),
                ),
              ),
              onChanged: (v) => _onChanged(i, v),
              onTap: () => _controllers[i].selection = TextSelection(
                baseOffset: 0,
                extentOffset: _controllers[i].text.length,
              ),
            ),
          ),
        );
      }),
    );
  }
}
