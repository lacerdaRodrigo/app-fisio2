import 'package:flutter/material.dart';

class FisioCores {
  static const Color primary = Color(0xFF4F6D7A);
  static const Color secondary = Color(0xFF7CB9A8);
  static const Color surface = Color(0xFFF0F4F8);
  static const Color card = Colors.white;
  static const Color accent = Color(0xFFE8D5B7);
  static const Color border = Color(0xFFE2E8F0);
  static const Color inputFill = Color(0xFFF1F5F9);

  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);

  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFC9515B);
  static const Color info = Color(0xFF3B82F6);
  static const Color indigo = Color(0xFF6366F1);
  static const Color pink = Color(0xFFEC4899);

  static const List<Color> avatarPalette = [primary, indigo, warning, pink];

}

class FisioEspacamentos {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double base = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
}

class FisioRaios {
  static const double sm = 8;
  static const double md = 12;
  static const double base = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double pill = 999;
}

class FisioPontoQuebra {
  static const double tablet = 620;
  static const double desktop = 1024;
}


class FisioSombras {
  static List<BoxShadow> get card => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
}

class FisioDecoracoes {
  static BoxDecoration card({
    Color color = FisioCores.card,
    double radius = FisioRaios.base,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: FisioCores.border.withValues(alpha: 0.7)),
      boxShadow: FisioSombras.card,
    );
  }

  static BoxDecoration tinted(Color color, {double radius = FisioRaios.md}) {
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
  const FisioPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.leadingIcon,
    this.onBack,
    this.closeIcon = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    const foreground = FisioCores.textPrimary;
    const secondaryColor = FisioCores.textSecondary;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 48, 20, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(FisioRaios.lg),
          bottomRight: Radius.circular(FisioRaios.lg),
        ),
        boxShadow: FisioSombras.card,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (onBack != null) ...[
            IconButton(
              key: const Key('btn_fechar'),
              icon: Icon(
                closeIcon ? Icons.close_rounded : Icons.arrow_back_rounded,
              ),
              color: foreground,
              onPressed: onBack,
            ),
            const SizedBox(width: FisioEspacamentos.xs),
          ] else if (leadingIcon != null) ...[
            FisioIconBox(icon: leadingIcon!, color: FisioCores.primary),
            const SizedBox(width: FisioEspacamentos.md),
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
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: FisioEspacamentos.xs),
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: secondaryColor,
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
    this.radius = FisioRaios.base,
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
        FisioIconBox(icon: icon, color: FisioCores.primary, size: 34),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
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
        borderRadius: BorderRadius.circular(FisioRaios.pill),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class FisioIconBox extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final double iconSize;

  const FisioIconBox({
    super.key,
    required this.icon,
    required this.color,
    this.size = 44,
    this.iconSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: FisioDecoracoes.tinted(color, radius: FisioRaios.base),
      child: Icon(icon, color: color, size: iconSize),
    );
  }
}

enum FisioButtonVariant { filled, outlined, ghost }

class FisioButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final FisioButtonVariant variant;
  final Color? color;
  final VoidCallback? onPressed;

  const FisioButton({
    super.key,
    required this.label,
    this.icon,
    this.variant = FisioButtonVariant.filled,
    this.color,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? FisioCores.primary;

    switch (variant) {
      case FisioButtonVariant.filled:
        return ElevatedButton.icon(
          onPressed: onPressed,
          icon: icon != null ? Icon(icon, size: 18) : const SizedBox.shrink(),
          label: Text(label),
          style: ElevatedButton.styleFrom(
            backgroundColor: c,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: FisioEspacamentos.xl,
              vertical: FisioEspacamentos.base,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(FisioRaios.base),
            ),
          ),
        );
      case FisioButtonVariant.outlined:
        return OutlinedButton.icon(
          onPressed: onPressed,
          icon: icon != null ? Icon(icon, size: 18) : const SizedBox.shrink(),
          label: Text(label),
          style: OutlinedButton.styleFrom(
            foregroundColor: c,
            side: BorderSide(color: c),
            padding: const EdgeInsets.symmetric(
              horizontal: FisioEspacamentos.xl,
              vertical: FisioEspacamentos.base,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(FisioRaios.base),
            ),
          ),
        );
      case FisioButtonVariant.ghost:
        return TextButton.icon(
          onPressed: onPressed,
          icon: icon != null ? Icon(icon, size: 18) : const SizedBox.shrink(),
          label: Text(label),
          style: TextButton.styleFrom(
            foregroundColor: c,
            padding: const EdgeInsets.symmetric(
              horizontal: FisioEspacamentos.xl,
              vertical: FisioEspacamentos.base,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(FisioRaios.base),
            ),
          ),
        );
    }
  }
}

