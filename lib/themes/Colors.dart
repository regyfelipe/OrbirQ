import 'package:flutter/material.dart';

class AppColors {
  // Cor principal (da logo)
  static const Color primary = Color(0xFF1b4332);

  // Variações da cor principal
  static const Color primaryLight = Color(0xFF001427);
  static const Color primaryDark = Color(0xFF1976D2);

  // Cores complementares
  static const Color secondary = Color(0xFF6D1561);
  static const Color accent = Color(0xFFFFC107);

  // Cores neutras
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);
  static const Color warning = Color(0xFFF57C00);
  static const Color info = Color(0xFF17A2B8);

  // Tons de cinza
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);

  // Cores de texto
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textDisabled = Color(0xFF9E9E9E);
  static const Color textWhite = Color(0xFFFFFFFF);

  // Cores de estado
  static const Color disabled = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFBDBDBD);
  static const Color overlay = Color(0x80000000);

  // Cores de gradiente
  static const List<Color> primaryGradient = [
    Color(0xFF15616D),
    Color(0xFF1C7A8A),
  ];

  // Cores de sombra
  static const Color shadow = Color(0x40000000);

  // Cores de estado de botão
  static const Color buttonPrimary = primary;
  static const Color buttonDisabled = disabled;
  static const Color buttonText = textWhite;

  // Cores de input
  static const Color inputBackground = grey100;
  static const Color inputBorder = grey300;
  static const Color inputFocused = primary;
  static const Color inputError = error;

  // Cores de feedback
  static const Color successLight = Color(0xFFD4EDDA);
  static const Color errorLight = Color(0xFFF8D7DA);
  static const Color warningLight = Color(0xFFFFF3CD);
  static const Color infoLight = Color(0xFFD1ECF1);
}
