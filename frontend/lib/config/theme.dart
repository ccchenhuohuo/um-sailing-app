import 'package:flutter/material.dart';
import 'constants.dart';

class AppTheme {
  // 海洋渐变背景色
  static const Color oceanBlueDark = Color(0xFF0A1628);
  static const Color oceanBlueMid = Color(0xFF15203B);
  static const Color oceanBlueLight = Color(0xFF0D1F35);

  // 主题色
  static const Color goldColor = Color(0xFFE8B84A);
  static const Color tealColor = Color(0xFF1E8C93);
  static const Color errorRed = Color(0xFFFF6B6B);

  // 白色卡片主题 - 用于主要内容页面
  static ThemeData get whiteCardTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: tealColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: tealColor,
        primary: tealColor,
        secondary: goldColor,
        surface: Colors.white,
        error: errorRed,
      ),
      fontFamily: 'Noto Sans SC',
      scaffoldBackgroundColor: Colors.transparent,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: goldColor,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black26),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black26),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: tealColor, width: 2),
        ),
        labelStyle: const TextStyle(color: Colors.black87),
        hintStyle: const TextStyle(color: Colors.black54),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.black),
        bodyMedium: TextStyle(color: Colors.black87),
        bodySmall: TextStyle(color: Colors.black54),
        titleLarge: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
        headlineMedium: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: goldColor,
        unselectedLabelColor: Colors.black54,
        indicatorColor: goldColor,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: const Color(0xCC0A1628),
        selectedItemColor: goldColor,
        unselectedItemColor: Colors.white70,
      ),
    );
  }

  // 海洋主题 - 用于登录注册页面
  static ThemeData get oceanTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: tealColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: tealColor,
        primary: tealColor,
        secondary: goldColor,
        surface: const Color(0xCC15203B),
        error: errorRed,
      ),
      fontFamily: 'Noto Sans SC',
      scaffoldBackgroundColor: oceanBlueDark,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: goldColor,
          foregroundColor: oceanBlueDark,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black26),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black26),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: tealColor, width: 2),
        ),
        labelStyle: const TextStyle(color: Colors.black87),
        hintStyle: const TextStyle(color: Colors.black54),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: Colors.white,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.black),
        bodyMedium: TextStyle(color: Colors.black87),
        bodySmall: TextStyle(color: Colors.black54),
        titleLarge: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
        headlineMedium: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
      ),
    );
  }

  // 原始亮色主题（保留兼容性）
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: const Color(AppConstants.primaryColor),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(AppConstants.primaryColor),
        primary: const Color(AppConstants.primaryColor),
        secondary: const Color(AppConstants.accentColor),
      ),
      fontFamily: 'Noto Sans SC',
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(AppConstants.primaryColor),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(AppConstants.primaryColor),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(AppConstants.primaryColor), width: 2),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  // 海岸优雅主题（保留兼容性）
  static ThemeData get coastalTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: const Color(AppConstants.tealAzure),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(AppConstants.tealAzure),
        primary: const Color(AppConstants.tealAzure),
        secondary: const Color(AppConstants.coralGold),
        surface: const Color(AppConstants.midnightBlue),
      ),
      fontFamily: 'Noto Sans SC',
      scaffoldBackgroundColor: const Color(AppConstants.deepOcean),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(AppConstants.coralGold),
          foregroundColor: const Color(AppConstants.deepOcean),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(AppConstants.surfaceColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0x33FFFFFF)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(AppConstants.tealAzure), width: 2),
        ),
        labelStyle: const TextStyle(color: Color(0x99FFFFFF)),
        hintStyle: const TextStyle(color: Color(0x66FFFFFF)),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: const Color(AppConstants.surfaceColor),
      ),
      textTheme: TextTheme(
        bodyLarge: const TextStyle(color: Color(AppConstants.foamWhite)),
        bodyMedium: const TextStyle(color: Color(0xCCFFFFFF)),
      ),
    );
  }
}
