import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary colors with vibrant gradient
  static const Color primary = Color(0xFFFF6B35);
  static const Color primaryDark = Color(0xFFE85A2B);
  static const Color primaryLight = Color(0xFFFF8C65);
  static const Color primaryAccent = Color(0xFFFFA07A);

  // Background colors
  static const Color background = Color(0xFFF8F9FA);
  static const Color scaffold = Colors.white;
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F7FA);

  // Text colors
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF4A5568);
  static const Color textMuted = Color(0xFF718096);
  static const Color textLight = Color(0xFFA0AEC0);

  // Accent colors
  static const Color accentGreen = Color(0xFF48BB78);
  static const Color accentRed = Color(0xFFF56565);
  static const Color accentBlue = Color(0xFF4299E1);
  static const Color accentYellow = Color(0xFFF6E05E);
  static const Color accentPurple = Color(0xFF9F7AEA);
  static const Color accentPink = Color(0xFFED64A6);

  // UI elements
  static const Color card = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFEDF2F7);
  static const Color shadow = Color(0x0D000000);
  static const Color shadowDark = Color(0x1A000000);

  // Navigation
  static const Color tabBarInactive = Color(0xFFA0AEC0);
  static const Color chipBackground = Color(0xFFEDF2F7);

  // Gradients - Primary
  static const List<Color> onboardingGradient = [
    Color(0xFFFF6B35),
    Color(0xFFFF8C42),
    Color(0xFFFFA07A),
  ];

  static const List<Color> primaryGradient = [
    Color(0xFFFFA03B),
    Color(0xFFFF7A00),
  ];

  // Gradients - Secondary & Accent
  static const List<Color> secondaryGradient = [
    Color(0xFF6A11CB),
    Color(0xFF2575FC),
  ];

  static const List<Color> successGradient = [
    Color(0xFF2ECC71),
    Color(0xFF28B463),
  ];

  static const List<Color> dangerGradient = [
    Color(0xFFE74C3C),
    Color(0xFFC0392B),
  ];

  static const List<Color> infoGradient = [
    Color(0xFF3498DB),
    Color(0xFF2980B9),
  ];

  static const List<Color> warningGradient = [
    Color(0xFFF1C40F),
    Color(0xFFF39C12),
  ];

  // Card & Surface Gradients
  static const List<Color> cardGradient = [
    Color(0xFFFFFFFF),
    Color(0xFFF8F9FA),
  ];

  static const List<Color> glassMorphismGradient = [
    Color(0x33FFFFFF), // white.withOpacity(0.2)
    Color(0x0DFFFFFF), // white.withOpacity(0.05)
  ];

  // Glass morphism effects
  static Color glassWhite = Colors.white.withOpacity(0.25);
  static Color glassBorder = Colors.white.withOpacity(0.18);
  static Color glassWhiteLight = Colors.white.withOpacity(0.15);
  static Color glassWhiteMedium = Colors.white.withOpacity(0.3);
  static Color glassWhiteStrong = Colors.white.withOpacity(0.4);

  // Shadow variations for depth
  static Color shadowLight = const Color(0x0A000000); // 4% opacity
  static Color shadowMedium = const Color(0x14000000); // 8% opacity
  static Color shadowStrong = const Color(0x1F000000); // 12% opacity
  static Color shadowIntense = const Color(0x33000000); // 20% opacity

  // Gradient shadow colors (for colored shadows)
  static Color primaryShadow = primary.withOpacity(0.3);
  static Color secondaryShadow = const Color(0xFF6A11CB).withOpacity(0.3);
  static Color successShadow = accentGreen.withOpacity(0.3);
  static Color dangerShadow = accentRed.withOpacity(0.3);
  static Color infoShadow = accentBlue.withOpacity(0.3);
  static Color warningShadow = accentYellow.withOpacity(0.3);

  // Enhanced accent colors with variations
  static const Color accentGreenLight = Color(0xFF68D391);
  static const Color accentGreenDark = Color(0xFF38A169);
  static const Color accentRedLight = Color(0xFFFC8181);
  static const Color accentRedDark = Color(0xFFE53E3E);
  static const Color accentBlueLight = Color(0xFF63B3ED);
  static const Color accentBlueDark = Color(0xFF3182CE);
  static const Color accentYellowLight = Color(0xFFFBD38D);
  static const Color accentYellowDark = Color(0xFFD69E2E);
  static const Color accentPurpleLight = Color(0xFFB794F4);
  static const Color accentPurpleDark = Color(0xFF805AD5);
  static const Color accentPinkLight = Color(0xFFF687B3);
  static const Color accentPinkDark = Color(0xFFD53F8C);

  // White variations for overlays
  static Color whiteOverlay10 = Colors.white.withOpacity(0.1);
  static Color whiteOverlay15 = Colors.white.withOpacity(0.15);
  static Color whiteOverlay20 = Colors.white.withOpacity(0.2);
  static Color whiteOverlay25 = Colors.white.withOpacity(0.25);
  static Color whiteOverlay30 = Colors.white.withOpacity(0.3);
  static Color whiteOverlay40 = Colors.white.withOpacity(0.4);
  static Color whiteOverlay50 = Colors.white.withOpacity(0.5);
  static Color whiteOverlay70 = Colors.white.withOpacity(0.7);
  static Color whiteOverlay90 = Colors.white.withOpacity(0.9);

  // Black variations for overlays
  static Color blackOverlay05 = Colors.black.withOpacity(0.05);
  static Color blackOverlay10 = Colors.black.withOpacity(0.1);
  static Color blackOverlay20 = Colors.black.withOpacity(0.2);
  static Color blackOverlay30 = Colors.black.withOpacity(0.3);
  static Color blackOverlay40 = Colors.black.withOpacity(0.4);
  static Color blackOverlay50 = Colors.black.withOpacity(0.5);

  // Dark theme colors (for future use)
  static const Color darkBackground = Color(0xFF1A1A2E);
  static const Color darkCard = Color(0xFF2E2E4A);
  static const Color darkTextPrimary = Colors.white;
  static const Color darkTextSecondary = Color(0xFFB0B0C0);
  static const Color darkTextMuted = Color(0xFF707080);

}

