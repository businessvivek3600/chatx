import 'dart:ui';

import 'package:flutter/material.dart';

class GlassTextField extends StatefulWidget {
  final String hint;
  final IconData icon;
  final bool obscureText;
  final Widget? suffix;
  final String? errorText;
  final Function(String) onChanged;

  const GlassTextField({
    super.key,
    required this.hint,
    required this.icon,
    required this.onChanged,
    this.obscureText = false,
    this.suffix,
    this.errorText,
  });

  @override
  State<GlassTextField> createState() =>
      _GlassTextFieldState();
}

class _GlassTextFieldState extends State<GlassTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    _focusNode.addListener(() {
      setState(() => _focused = _focusNode.hasFocus);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: _focused
            ? [
          BoxShadow(
            color: Colors.blueAccent
                .withOpacity(0.45),
            blurRadius: 20,
            spreadRadius: 1,
          )
        ]
            : [],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter:
          ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: TextField(
            focusNode: _focusNode,
            obscureText: widget.obscureText,
            onChanged: widget.onChanged,
            style: TextStyle(
              color:
              isDark ? Colors.white : Colors.black87,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: TextStyle(
                color: isDark
                    ? Colors.white70
                    : Colors.black45,
              ),
              prefixIcon: Icon(
                widget.icon,
                color: isDark
                    ? Colors.white
                    : Colors.black54,
              ),
              suffixIcon: widget.suffix,
              errorText: widget.errorText,
              filled: true,
              fillColor: isDark
                  ? Colors.white.withOpacity(0.15)
                  : Colors.white.withOpacity(0.6),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      ),
    );
  }
}