import 'package:flutter/material.dart';

/// A utility class for consistent app decorations.
/// Using a class prevents global namespace pollution.
abstract class AppDecorations {

  /// Professional 3D-effect card decoration.
  /// Added parameters to allow minor overrides while keeping the "3D" style.
  static BoxDecoration card3D({
    Color color = Colors.white,
    double borderRadius = 14,
  }) =>
      BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000), // very soft shadow
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      );
}
