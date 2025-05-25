import 'package:flutter/material.dart';
import 'package:eventease/theme/app_theme.dart';
import 'package:eventease/utils/animations.dart';
import 'package:eventease/widgets/custom_button.dart';

class CustomStepper extends StatefulWidget {
  final List<StepItem> steps;
  final int currentStep;
  final ValueChanged<int>? onStepTapped;
  final VoidCallback? onStepContinue;
  final VoidCallback? onStepCancel;
  final StepperStyle style;
  final bool allowStepTapping;
  final bool showButtons;
  final String? continueText;
  final String? cancelText;
  final bool animated;
  final EdgeInsets? contentPadding;
  final Color? activeColor;
  final Color? inactiveColor;

  const CustomStepper({
    super.key,
    required this.steps,
    this.currentStep = 0,
    this.onStepTapped,
    this.onStepContinue,
    this.onStepCancel,
    this.style = StepperStyle.vertical,
    this.allowStepTapping = true,
    this.showButtons = true,
    this.continueText,
    this.cancelText,
    this.animated = true,
    this.contentPadding,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  State<CustomStepper> createState() => _CustomStepperState();
}

class _CustomStepperState extends State<CustomStepper> {
  @override
  Widget build(BuildContext context) {
    return widget.style == StepperStyle.vertical
        ? _buildVerticalStepper()
        : _buildHorizontalStepper();
  }

  Widget _buildVerticalStepper() {
    return Column(
      children: List.generate(
        widget.steps.length * 2 - 1,
        (index) {
          if (index.isOdd) {
            return _buildVerticalLine(index ~/ 2);
          }
          return _buildVerticalStep(index ~/ 2);
        },
      ),
    );
  }

  Widget _buildHorizontalStepper() {
    return Column(
      children: [
        Row(
          children: List.generate(
            widget.steps.length * 2 - 1,
            (index) {
              if (index.isOdd) {
                return _buildHorizontalLine(index ~/ 2);
              }
              return Expanded(child: _buildHorizontalStep(index ~/ 2));
            },
          ),
        ),
        const SizedBox(height: 24),
        _buildCurrentStepContent(),
      ],
    );
  }

  Widget _buildVerticalStep(int index) {
    final step = widget.steps[index];
    final isActive = index == widget.currentStep;
    final isCompleted = index < widget.currentStep;

    Widget stepWidget = Row(
      children: [
        _buildStepIndicator(index, isActive, isCompleted),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStepHeader(step, isActive, isCompleted),
              if (isActive) ...[
                const SizedBox(height: 16),
                _buildStepContent(step),
                if (widget.showButtons) ...[
                  const SizedBox(height: 16),
                  _buildStepButtons(),
                ],
              ],
            ],
          ),
        ),
      ],
    );

    if (widget.animated) {
      stepWidget = AnimatedWidget(
        fadeIn: true,
        scale: true,
        child: stepWidget,
      );
    }

    return stepWidget;
  }

  Widget _buildHorizontalStep(int index) {
    final isActive = index == widget.currentStep;
    final isCompleted = index < widget.currentStep;

    Widget stepWidget = Column(
      children: [
        _buildStepIndicator(index, isActive, isCompleted),
        const SizedBox(height: 8),
        Text(
          widget.steps[index].title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive || isCompleted
                ? (widget.activeColor ?? AppTheme.primaryColor)
                : (widget.inactiveColor ?? Colors.grey),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );

    if (widget.animated) {
      stepWidget = AnimatedWidget(
        fadeIn: true,
        scale: true,
        child: stepWidget,
      );
    }

    return GestureDetector(
      onTap: widget.allowStepTapping ? () => _onStepTapped(index) : null,
      child: stepWidget,
    );
  }

  Widget _buildStepIndicator(int index, bool isActive, bool isCompleted) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isActive || isCompleted
            ? (widget.activeColor ?? AppTheme.primaryColor)
            : (widget.inactiveColor ?? Colors.grey[300]),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: isCompleted
            ? Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 20,
              )
            : Text(
                '${index + 1}',
                style: TextStyle(
                  color: isActive || isCompleted ? Colors.white : Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildStepHeader(StepItem step, bool isActive, bool isCompleted) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                step.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isActive || isCompleted
                      ? (widget.activeColor ?? AppTheme.primaryColor)
                      : (widget.inactiveColor ?? Colors.grey),
                ),
              ),
              if (step.subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  step.subtitle!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
        ),
        if (step.state != null)
          _buildStepState(step.state!, isActive),
      ],
    );
  }

  Widget _buildStepState(StepState state, bool isActive) {
    IconData icon;
    Color color;

    switch (state) {
      case StepState.complete:
        icon = Icons.check_circle_outline_rounded;
        color = Colors.green;
        break;
      case StepState.error:
        icon = Icons.error_outline_rounded;
        color = Colors.red;
        break;
      case StepState.disabled:
        icon = Icons.block_rounded;
        color = Colors.grey;
        break;
      default:
        icon = Icons.circle_outlined;
        color = isActive
            ? (widget.activeColor ?? AppTheme.primaryColor)
            : (widget.inactiveColor ?? Colors.grey);
    }

    return Icon(icon, color: color);
  }

  Widget _buildStepContent(StepItem step) {
    return Container(
      width: double.infinity,
      padding: widget.contentPadding,
      child: step.content,
    );
  }

  Widget _buildCurrentStepContent() {
    final currentStep = widget.steps[widget.currentStep];
    Widget content = Column(
      children: [
        _buildStepContent(currentStep),
        if (widget.showButtons) ...[
          const SizedBox(height: 16),
          _buildStepButtons(),
        ],
      ],
    );

    if (widget.animated) {
      content = AnimatedWidget(
        fadeIn: true,
        slide: true,
        child: content,
      );
    }

    return content;
  }

  Widget _buildStepButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (widget.currentStep > 0)
          CustomButton(
            text: widget.cancelText ?? 'Back',
            onPressed: widget.onStepCancel,
            variant: ButtonVariant.outline,
          ),
        if (widget.currentStep > 0)
          const SizedBox(width: 16),
        CustomButton(
          text: widget.continueText ??
              (widget.currentStep == widget.steps.length - 1
                  ? 'Finish'
                  : 'Continue'),
          onPressed: widget.onStepContinue,
        ),
      ],
    );
  }

  Widget _buildVerticalLine(int index) {
    final isActive = index < widget.currentStep;
    return Container(
      width: 2,
      height: 24,
      margin: const EdgeInsets.only(left: 15),
      color: isActive
          ? (widget.activeColor ?? AppTheme.primaryColor)
          : (widget.inactiveColor ?? Colors.grey[300]),
    );
  }

  Widget _buildHorizontalLine(int index) {
    final isActive = index < widget.currentStep;
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        color: isActive
            ? (widget.activeColor ?? AppTheme.primaryColor)
            : (widget.inactiveColor ?? Colors.grey[300]),
      ),
    );
  }

  void _onStepTapped(int index) {
    if (!widget.allowStepTapping) return;
    widget.onStepTapped?.call(index);
  }
}

enum StepperStyle {
  vertical,
  horizontal,
}

class StepItem {
  final String title;
  final String? subtitle;
  final Widget content;
  final StepState? state;

  const StepItem({
    required this.title,
    this.subtitle,
    required this.content,
    this.state,
  });
}
