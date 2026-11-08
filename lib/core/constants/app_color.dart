import 'package:flutter/material.dart';

/// Central color design system for VidSell.
///
/// Dark palette built on deep black-slate surfaces with an electric cyan accent.
class AppColor {
  AppColor._();

  // --- Brand & Accent ---
  /// Scaffold and app background (#0F1115)
  static const Color primaryColor = Color(0xFF0F1115);

  /// Vibrant cyan accent (#38BDF8)
  static const Color activeColor = Color(0xFF38BDF8);

  /// Semantic alias for primary brand accent
  static const Color brandColor = activeColor;

  // --- Surfaces & Cards ---
  /// Card and list item surface (#1D232D)
  static const Color bgSurfaceColor = Color(0xFF1D232D);

  /// Secondary container background (#171B22)
  static const Color bgSecondary = Color(0xFF171B22);

  /// Elevated surface for dialogs and popups (#252C38)
  static const Color bgElevated = Color(0xFF252C38);

  /// Backward-compatible alias for existing typo references
  static const Color bgElavated = bgElevated;

  /// Info and alert surface (#10202C)
  static const Color bgInfoColor = Color(0xFF10202C);

  /// Deep card background used across settings & profile (#1B222D)
  static const Color cardBackground = Color(0xFF1B222D);

  /// Modal bottom sheet background (#161C24)
  static const Color bottomSheetBackground = Color(0xFF161C24);

  /// High-contrast surface for icons, chips, and avatars (#222B38)
  static const Color surfaceHighlight = Color(0xFF222B38);

  // --- Typography ---
  /// High-contrast primary text
  static const Color primaryTextColor = Colors.white;

  /// Secondary muted text (#9CA3AF)
  static const Color secondaryTextColor = Color(0xFF9CA3AF);

  /// Tertiary placeholder / hint text (#9CA3AF)
  static const Color tertiaryTextColor = Color(0xFF9CA3AF);

  /// Inactive / disabled text (#6B7280)
  static const Color mutedColor = Color(0xFF6B7280);

  // --- Status & Feedback ---
  /// Success green (#22C55E)
  static const Color success = Color(0xFF22C55E);

  /// Bright success green for badges & tags (#3ED08E)
  static const Color successLight = Color(0xFF3ED08E);

  /// Dark background container for success badges (#0E2D28)
  static const Color successBackground = Color(0xFF0E2D28);

  /// Error red (#EF4444)
  static const Color error = Color(0xFFEF4444);

  /// Dark background container for error alerts (#2E1A1A)
  static const Color errorBackground = Color(0xFF2E1A1A);

  /// Warning amber (#F59E0B)
  static const Color warning = Color(0xFFF59E0B);

  /// Dark background container for warning alerts (#2E2310)
  static const Color warningBackground = Color(0xFF2E2310);

  // --- Borders & Dividers ---
  /// Subtle divider and container border (white with 10% opacity)
  static const Color borderSubtle = Color(0x1AFFFFFF);

  /// Moderate border (white with 20% opacity)
  static const Color borderMedium = Color(0x33FFFFFF);

  /// Focused input border
  static const Color borderFocused = activeColor;
}
