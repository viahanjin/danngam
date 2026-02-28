import 'package:flutter/material.dart';
import '../constants/app_dimensions.dart';
import '../extensions/build_context_ext.dart';

/// Primary Button Widget
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final double? width;
  final double height;
  final TextStyle? textStyle;
  final Widget? icon;
  final bool isFullWidth;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.width,
    this.height = AppDimensions.buttonHeight,
    this.textStyle,
    this.icon,
    this.isFullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = !isDisabled && !isLoading && onPressed != null;

    return SizedBox(
      width: isFullWidth ? double.infinity : width,
      height: height,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        child: isLoading
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    context.primaryColor,
                  ),
                ),
              )
            : icon != null
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      icon!,
                      const SizedBox(width: AppDimensions.marginSmall),
                      Text(label, style: textStyle),
                    ],
                  )
                : Text(label, style: textStyle),
      ),
    );
  }
}

/// Secondary Button Widget (Outlined)
class AppSecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final double? width;
  final double height;
  final TextStyle? textStyle;
  final Widget? icon;
  final bool isFullWidth;

  const AppSecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.width,
    this.height = AppDimensions.buttonHeight,
    this.textStyle,
    this.icon,
    this.isFullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = !isDisabled && !isLoading && onPressed != null;

    return SizedBox(
      width: isFullWidth ? double.infinity : width,
      height: height,
      child: OutlinedButton(
        onPressed: isEnabled ? onPressed : null,
        child: isLoading
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    context.primaryColor,
                  ),
                ),
              )
            : icon != null
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      icon!,
                      const SizedBox(width: AppDimensions.marginSmall),
                      Text(label, style: textStyle),
                    ],
                  )
                : Text(label, style: textStyle),
      ),
    );
  }
}

/// Text Button Widget
class AppTextButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final TextStyle? textStyle;
  final bool isDisabled;

  const AppTextButton({
    super.key,
    required this.label,
    this.onPressed,
    this.textStyle,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: isDisabled ? null : onPressed,
      child: Text(label, style: textStyle),
    );
  }
}
