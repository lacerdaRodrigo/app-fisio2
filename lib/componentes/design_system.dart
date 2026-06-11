import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class FisioCores {
  static const Color primaryDark = Color(0xFF0F172A);
  static const Color primary = Color(0xFF00796B);
  static const Color primaryLight = Color(0xFF00BFA5);
  static const Color secondary = Color(0xFF0D9488);
  static const Color surface = Color(0xFFF8FAFC);
  static const Color card = Colors.white;
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  static const Color indigo = Color(0xFF6366F1);
  static const Color pink = Color(0xFFEC4899);

  static const List<Color> avatarPalette = [primary, indigo, warning, pink];
}

class FisioGradientes {
  static const LinearGradient hero = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      FisioCores.primaryDark,
      FisioCores.primary,
      FisioCores.primaryLight,
    ],
  );

  static const LinearGradient teal = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [FisioCores.primary, FisioCores.primaryLight],
  );
}

class FisioSombras {
  static List<BoxShadow> get card => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.055),
      blurRadius: 22,
      offset: const Offset(0, 10),
    ),
  ];

  static List<BoxShadow> colored(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: 0.28),
      blurRadius: 18,
      offset: const Offset(0, 8),
    ),
  ];
}

class FisioDecoracoes {
  static BoxDecoration card({
    Color color = FisioCores.card,
    double radius = 24,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: const Color(0xFFE2E8F0).withValues(alpha: 0.7)),
      boxShadow: FisioSombras.card,
    );
  }

  static BoxDecoration tinted(Color color, {double radius = 18}) {
    return BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: color.withValues(alpha: 0.18)),
    );
  }
}

Color fisioAvatarColor(String seed) {
  if (seed.isEmpty) return FisioCores.primary;
  return FisioCores.avatarPalette[seed.length %
      FisioCores.avatarPalette.length];
}

String fisioIniciais(String nome) {
  final partes = nome
      .trim()
      .split(RegExp(r'\s+'))
      .where((parte) => parte.isNotEmpty)
      .take(2)
      .map((parte) => parte[0])
      .join();
  return partes.isEmpty ? '?' : partes.toUpperCase();
}

class FisioResponsiveCenter extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const FisioResponsiveCenter({
    super.key,
    required this.child,
    this.maxWidth = 520,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

class FisioPageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? leadingIcon;
  final VoidCallback? onBack;
  final bool closeIcon;
  final Widget? trailing;
  final bool gradient;

  const FisioPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.leadingIcon,
    this.onBack,
    this.closeIcon = false,
    this.trailing,
    this.gradient = false,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = gradient ? Colors.white : FisioCores.textPrimary;
    final secondary = gradient
        ? Colors.white.withValues(alpha: 0.76)
        : FisioCores.textSecondary;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 48, 20, 18),
      decoration: BoxDecoration(
        gradient: gradient ? FisioGradientes.teal : null,
        color: gradient ? null : Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: gradient ? 0.1 : 0.055),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (onBack != null) ...[
            IconButton(
              icon: Icon(
                closeIcon ? Icons.close_rounded : Icons.arrow_back_rounded,
              ),
              color: foreground,
              onPressed: onBack,
            ),
            const SizedBox(width: 4),
          ] else if (leadingIcon != null) ...[
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: (gradient ? Colors.white : FisioCores.primary)
                    .withValues(alpha: gradient ? 0.18 : 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: (gradient ? Colors.white : FisioCores.primary)
                      .withValues(alpha: 0.2),
                ),
              ),
              child: Icon(leadingIcon, color: foreground),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: secondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

class FisioCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color color;
  final VoidCallback? onTap;
  final double radius;

  const FisioCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.margin,
    this.color = FisioCores.card,
    this.onTap,
    this.radius = 24,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      margin: margin,
      padding: padding,
      decoration: FisioDecoracoes.card(color: color, radius: radius),
      child: child,
    );

    if (onTap == null) return content;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: onTap,
        child: content,
      ),
    );
  }
}

class FisioSectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;

  const FisioSectionTitle({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: FisioDecoracoes.tinted(FisioCores.primary, radius: 12),
          child: Icon(icon, color: FisioCores.primary, size: 19),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: FisioCores.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class FisioBadge extends StatelessWidget {
  final String label;
  final Color color;

  const FisioBadge({
    super.key,
    required this.label,
    this.color = FisioCores.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class FisioGlass extends StatelessWidget {
  final Widget child;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry padding;
  final Color color;

  const FisioGlass({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(28)),
    this.padding = const EdgeInsets.all(24),
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.13),
            borderRadius: borderRadius,
            border: Border.all(color: color.withValues(alpha: 0.22)),
          ),
          child: child,
        ),
      ),
    );
  }
}
