import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AcademiXNavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final int badgeCount;

  const AcademiXNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    this.badgeCount = 0,
  });
}

class AcademiXBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final List<AcademiXNavItem> items;

  const AcademiXBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: const Border(
          top: BorderSide(color: AppColors.border, width: 0.8),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryText.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = index == selectedIndex;

              return Expanded(
                child: InkWell(
                  onTap: () => onItemSelected(index),
                  splashColor: AppColors.lightBlue.withValues(alpha: 0.5),
                  highlightColor: Colors.transparent,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Compact rounded icon container
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOutCubic,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.lightBlue
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: item.badgeCount > 0
                              ? Badge(
                                  label: Text(
                                    '${item.badgeCount}',
                                    style: const TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  backgroundColor: AppColors.error,
                                  offset: const Offset(8, -4),
                                  child: Icon(
                                    isSelected ? item.selectedIcon : item.icon,
                                    size: 21,
                                    color: isSelected
                                        ? AppColors.primaryBlue
                                        : AppColors.secondaryText,
                                  ),
                                )
                              : Icon(
                                  isSelected ? item.selectedIcon : item.icon,
                                  size: 21,
                                  color: isSelected
                                      ? AppColors.primaryBlue
                                      : AppColors.secondaryText,
                                ),
                        ),
                        const SizedBox(height: 3),
                        // Label that smoothly scales down on small screens without truncation
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              item.label,
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: isSelected
                                    ? AppColors.primaryBlue
                                    : AppColors.secondaryText,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
