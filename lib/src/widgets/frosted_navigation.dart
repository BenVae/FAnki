import 'dart:ui';

import 'package:flutter/material.dart';

class FrostedNavigationButtons extends StatelessWidget {
  const FrostedNavigationButtons({
    super.key,
    required this.selectedIndex,
    required this.onNavigate,
    this.padding = const EdgeInsets.all(16),
  });

  final int selectedIndex;
  final Function(int) onNavigate;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final safePadding = MediaQuery.of(context).padding;
    return Positioned(
      top: safePadding.top + padding.top,
      right: safePadding.right + padding.right,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _FrostedNavButton(
            icon: Icons.insights_outlined,
            selectedIcon: Icons.insights,
            tooltip: 'Statistics',
            isSelected: selectedIndex == 0,
            onPressed: () => onNavigate(0),
          ),
          const SizedBox(width: 8),
          _FrostedNavButton(
            icon: Icons.settings_outlined,
            selectedIcon: Icons.settings,
            tooltip: 'Settings',
            isSelected: selectedIndex == 1,
            onPressed: () => onNavigate(1),
          ),
        ],
      ),
    );
  }
}

class _FrostedNavButton extends StatelessWidget {
  const _FrostedNavButton({
    required this.icon,
    required this.selectedIcon,
    required this.tooltip,
    required this.isSelected,
    required this.onPressed,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String tooltip;
  final bool isSelected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected 
              ? colorScheme.primary.withValues(alpha: 0.2)
              : colorScheme.surface.withValues(alpha: 0.3),
            border: Border.all(
              color: isSelected
                ? colorScheme.primary.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.4),
              width: isSelected ? 2 : 1,
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
                    isSelected ? selectedIcon : icon,
                    size: 22,
                    color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurface.withValues(alpha: 0.9),
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