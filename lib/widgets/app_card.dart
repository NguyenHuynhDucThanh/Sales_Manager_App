import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// AppCard - Card component với styling chuẩn
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final VoidCallback? onTap;
  final double? elevation;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.onTap,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    final cardContent = Padding(
      padding: padding ?? EdgeInsets.all(AppSpacing.md),
      child: child,
    );

    return Card(
      elevation: elevation ?? 2,
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: onTap != null
          ? InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: cardContent,
            )
          : cardContent,
    );
  }
}

/// AppContainer - Container với decoration chuẩn
class AppContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final BoxDecoration? decoration;
  final double? width;
  final double? height;

  const AppContainer({
    super.key,
    required this.child,
    this.padding,
    this.decoration,
    this.width,
    this.height,
  });

  factory AppContainer.gradient({
    required Widget child,
    EdgeInsetsGeometry? padding,
  }) {
    return AppContainer(
      decoration: AppDecoration.gradient,
      padding: padding,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding ?? EdgeInsets.all(AppSpacing.md),
      decoration: decoration ?? AppDecoration.card,
      child: child,
    );
  }
}
