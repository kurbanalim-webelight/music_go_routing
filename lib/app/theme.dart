import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';

abstract final class AppColors {
  static const ink = Color(0xFF17131C);
  static const surface = Color(0xFF221C29);
  static const raised = Color(0xFF2E2637);
  static const marigold = Color(0xFFF2B33D);
  static const paper = Color(0xFFF3EDE4);
  static const muted = Color(0xFF9C92A6);
}

abstract final class AppTheme {
  static ThemeData get dark {
    const scheme = ColorScheme.dark(
      primary: AppColors.marigold,
      onPrimary: AppColors.ink,
      secondary: AppColors.marigold,
      onSecondary: AppColors.ink,
      surface: AppColors.ink,
      onSurface: AppColors.paper,
      onSurfaceVariant: AppColors.muted,
      surfaceContainer: AppColors.surface,
      surfaceContainerHigh: AppColors.raised,
      outlineVariant: AppColors.raised,
    );
    final base = ThemeData(colorScheme: scheme, brightness: Brightness.dark);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.ink,
      textTheme: base.textTheme
          .apply(bodyColor: AppColors.paper, displayColor: AppColors.paper)
          .copyWith(
            headlineMedium: base.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.8),
            headlineSmall: base.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.5),
            titleLarge: base.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.3),
          ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.ink,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
          color: AppColors.paper,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.marigold.withValues(alpha: 0.18),
        height: 68,
        iconTheme: WidgetStateProperty.resolveWith(
          (s) => IconThemeData(color: s.contains(WidgetState.selected) ? AppColors.marigold : AppColors.muted),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (s) => TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: s.contains(WidgetState.selected) ? AppColors.paper : AppColors.muted,
          ),
        ),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: AppColors.paper,
        unselectedLabelColor: AppColors.muted,
        indicatorColor: AppColors.marigold,
        dividerColor: Colors.transparent,
        labelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.marigold, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
      listTileTheme: const ListTileThemeData(iconColor: AppColors.muted),
      pageTransitionsTheme: const PageTransitionsTheme(
        // iOS-native push on every platform: slides in from the right, the page underneath
        // shifts left with a parallax, and swiping from the left edge goes back.
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
