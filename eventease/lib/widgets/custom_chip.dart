import 'package:flutter/material.dart';
import 'package:eventease/theme/app_theme.dart';
import 'package:eventease/utils/animations.dart';

class CustomChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool isSelected;
  final bool showCheckmark;
  final bool animated;
  final ChipSize size;
  final ChipVariant variant;

  const CustomChip({
    super.key,
    required this.label,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.onTap,
    this.onDelete,
    this.isSelected = false,
    this.showCheckmark = false,
    this.animated = true,
    this.size = ChipSize.medium,
    this.variant = ChipVariant.filled,
  });

  @override
  Widget build(BuildContext context) {
    final defaultBackgroundColor = _getDefaultBackgroundColor();
    final defaultTextColor = _getDefaultTextColor();

    Widget chip = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(size.borderRadius),
        child: Container(
          padding: size.padding,
          decoration: BoxDecoration(
            color: backgroundColor ?? defaultBackgroundColor,
            borderRadius: BorderRadius.circular(size.borderRadius),
            border: variant == ChipVariant.outlined
                ? Border.all(
                    color: isSelected
                        ? AppTheme.primaryColor
                        : Colors.grey.withOpacity(0.5),
                    width: 1.5,
                  )
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: size.iconSize,
                  color: textColor ?? defaultTextColor,
                ),
                SizedBox(width: size.spacing),
              ],
              Text(
                label,
                style: TextStyle(
                  color: textColor ?? defaultTextColor,
                  fontSize: size.fontSize,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              if (showCheckmark && isSelected) ...[
                SizedBox(width: size.spacing),
                Icon(
                  Icons.check_rounded,
                  size: size.iconSize,
                  color: textColor ?? defaultTextColor,
                ),
              ],
              if (onDelete != null) ...[
                SizedBox(width: size.spacing),
                InkWell(
                  onTap: onDelete,
                  borderRadius: BorderRadius.circular(size.iconSize),
                  child: Icon(
                    Icons.close_rounded,
                    size: size.iconSize,
                    color: textColor ?? defaultTextColor,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );

    if (animated) {
      chip = AnimatedWidget(
        fadeIn: true,
        scale: true,
        child: chip,
      );
    }

    return chip;
  }

  Color _getDefaultBackgroundColor() {
    switch (variant) {
      case ChipVariant.filled:
        return isSelected
            ? AppTheme.primaryColor
            : Colors.grey.withOpacity(0.1);
      case ChipVariant.outlined:
        return isSelected
            ? AppTheme.primaryColor.withOpacity(0.1)
            : Colors.transparent;
      case ChipVariant.tonal:
        return isSelected
            ? AppTheme.primaryColor.withOpacity(0.2)
            : Colors.grey.withOpacity(0.1);
    }
  }

  Color _getDefaultTextColor() {
    switch (variant) {
      case ChipVariant.filled:
        return isSelected ? Colors.white : Colors.black87;
      case ChipVariant.outlined:
      case ChipVariant.tonal:
        return isSelected ? AppTheme.primaryColor : Colors.black87;
    }
  }
}

enum ChipSize {
  small(
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    fontSize: 12,
    iconSize: 16,
    spacing: 4,
    borderRadius: 16,
  ),
  medium(
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    fontSize: 14,
    iconSize: 18,
    spacing: 6,
    borderRadius: 20,
  ),
  large(
    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    fontSize: 16,
    iconSize: 20,
    spacing: 8,
    borderRadius: 24,
  );

  final EdgeInsets padding;
  final double fontSize;
  final double iconSize;
  final double spacing;
  final double borderRadius;

  const ChipSize({
    required this.padding,
    required this.fontSize,
    required this.iconSize,
    required this.spacing,
    required this.borderRadius,
  });
}

enum ChipVariant {
  filled,
  outlined,
  tonal,
}

// Choice Chips
class CustomChoiceChips<T> extends StatelessWidget {
  final List<ChipOption<T>> options;
  final T? selectedValue;
  final ValueChanged<T?>? onSelected;
  final ChipSize size;
  final ChipVariant variant;
  final bool showCheckmark;
  final ScrollPhysics? physics;
  final bool animated;

  const CustomChoiceChips({
    super.key,
    required this.options,
    this.selectedValue,
    this.onSelected,
    this.size = ChipSize.medium,
    this.variant = ChipVariant.filled,
    this.showCheckmark = true,
    this.physics,
    this.animated = true,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: physics,
      child: Row(
        children: options.map((option) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: CustomChip(
              label: option.label,
              icon: option.icon,
              isSelected: option.value == selectedValue,
              onTap: () => onSelected?.call(option.value),
              showCheckmark: showCheckmark,
              size: size,
              variant: variant,
              animated: animated,
            ),
          );
        }).toList(),
      ),
    );
  }
}

// Filter Chips
class CustomFilterChips<T> extends StatelessWidget {
  final List<ChipOption<T>> options;
  final List<T> selectedValues;
  final ValueChanged<List<T>>? onChanged;
  final ChipSize size;
  final ChipVariant variant;
  final bool showCheckmark;
  final ScrollPhysics? physics;
  final bool animated;

  const CustomFilterChips({
    super.key,
    required this.options,
    required this.selectedValues,
    this.onChanged,
    this.size = ChipSize.medium,
    this.variant = ChipVariant.filled,
    this.showCheckmark = true,
    this.physics,
    this.animated = true,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: physics,
      child: Row(
        children: options.map((option) {
          final isSelected = selectedValues.contains(option.value);
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: CustomChip(
              label: option.label,
              icon: option.icon,
              isSelected: isSelected,
              onTap: () {
                final newValues = List<T>.from(selectedValues);
                if (isSelected) {
                  newValues.remove(option.value);
                } else {
                  newValues.add(option.value);
                }
                onChanged?.call(newValues);
              },
              showCheckmark: showCheckmark,
              size: size,
              variant: variant,
              animated: animated,
            ),
          );
        }).toList(),
      ),
    );
  }
}

class ChipOption<T> {
  final String label;
  final IconData? icon;
  final T value;

  const ChipOption({
    required this.label,
    this.icon,
    required this.value,
  });
}
