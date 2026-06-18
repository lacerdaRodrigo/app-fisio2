import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'componentes/design_system.dart';
import 'componentes/rodape_versao.dart';
import 'telas/tela_login.dart';

void main() {
  runApp(const ProviderScope(child: FisioHomeCareApp()));
}

class FisioHomeCareApp extends StatelessWidget {
  const FisioHomeCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fisio Home Care',
      debugShowCheckedModeBanner: false,
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR'), Locale('en', 'US')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: FisioCores.primary,
          primary: FisioCores.primary,
          secondary: FisioCores.primaryLight,
          surface: FisioCores.surface,
          error: FisioCores.danger,
        ),
        textTheme: GoogleFonts.outfitTextTheme(Theme.of(context).textTheme)
            .copyWith(
              headlineMedium: const TextStyle(
                color: FisioCores.textPrimary,
                fontWeight: FontWeight.w800,
              ),
              titleLarge: const TextStyle(
                color: FisioCores.textPrimary,
                fontWeight: FontWeight.w800,
              ),
              titleMedium: const TextStyle(
                color: FisioCores.textPrimary,
                fontWeight: FontWeight.w700,
              ),
              bodyLarge: const TextStyle(color: FisioCores.textPrimary),
              bodyMedium: const TextStyle(color: FisioCores.textPrimary),
              bodySmall: const TextStyle(color: FisioCores.textSecondary),
              labelMedium: const TextStyle(
                color: FisioCores.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
        scaffoldBackgroundColor: FisioCores.surface,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: FisioCores.textPrimary,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 4,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            backgroundColor: FisioCores.primary,
            foregroundColor: Colors.white,
            shadowColor: FisioCores.primary.withValues(alpha: 0.28),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            backgroundColor: FisioCores.primary,
            foregroundColor: Colors.white,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: FisioCores.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF1F5F9),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: FisioCores.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: FisioCores.danger),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: FisioCores.danger, width: 2),
          ),
          labelStyle: const TextStyle(
            color: FisioCores.textSecondary,
            fontWeight: FontWeight.w600,
          ),
          hintStyle: const TextStyle(color: FisioCores.textMuted),
          prefixIconColor: FisioCores.textMuted,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: FisioCores.primary.withValues(alpha: 0.1),
          selectedColor: FisioCores.primary,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          side: BorderSide(color: FisioCores.primary.withValues(alpha: 0.12)),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: FisioCores.primaryDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          backgroundColor: Colors.transparent,
        ),
      ),
      builder: (context, child) =>
          VersaoOverlay(child: child ?? const SizedBox.shrink()),
      home: const TelaLogin(),
    );
  }
}
