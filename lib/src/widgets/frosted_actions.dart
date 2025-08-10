import 'dart:ui';

import 'package:flutter/material.dart';

class FrostedTopRightActions extends StatelessWidget {
  const FrostedTopRightActions({
    super.key,
    this.onOpenSettings,
    this.onOpenStats,
    this.padding = const EdgeInsets.all(16),
  });

  final VoidCallback? onOpenSettings;
  final VoidCallback? onOpenStats;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: padding.top,
      right: padding.right,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _FrostedCircleButton(
            icon: Icons.insights_outlined,
            tooltip: 'Study statistics',
            onPressed: onOpenStats,
          ),
          const SizedBox(width: 8),
          _FrostedCircleButton(
            icon: Icons.settings_outlined,
            tooltip: 'Settings',
            onPressed: onOpenSettings,
          ),
        ],
      ),
    );
  }
}

class _FrostedCircleButton extends StatelessWidget {
  const _FrostedCircleButton({
    required this.icon,
    required this.tooltip,
    this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.surface.withValues(alpha: 0.3),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.4),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Tooltip(
            message: tooltip,
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                borderRadius: BorderRadius.circular(28),
                onTap: onPressed,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Icon(
                    icon,
                    size: 22,
                    color: colorScheme.onSurface.withValues(alpha: 0.9),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FrostedTopRightBackButton extends StatelessWidget {
  const FrostedTopRightBackButton({
    super.key,
    required this.onPressed,
    this.padding = const EdgeInsets.all(16),
  });

  final VoidCallback onPressed;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: padding.top,
      right: padding.right,
      child: _FrostedCircleButton(
        icon: Icons.arrow_back,
        tooltip: 'Back',
        onPressed: onPressed,
      ),
    );
  }
}

class SubtleProgressPill extends StatelessWidget {
  const SubtleProgressPill({
    super.key,
    required this.current,
    required this.total,
  });

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? (current / total).clamp(0.0, 1.0) : 0.0;
    final colorScheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surface.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: IntrinsicWidth(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
              SizedBox(
                width: 34,
                height: 34,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 3,
                    ),
                    Text(
                      total > 0 ? '${(progress * 100).round()}%' : '0%',
                      style: TextStyle(
                        fontSize: 10,
                        color: colorScheme.onSurface.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '$current / $total',
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurface.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }
}
