import 'package:flutter/material.dart';

/// BuildContext Extensions
/// Provides convenient shorthand methods for accessing common context properties
extension BuildContextExtension on BuildContext {
  /// Theme Data
  ThemeData get theme => Theme.of(this);

  /// Color Scheme
  ColorScheme get colorScheme => theme.colorScheme;

  /// Primary Color
  Color get primaryColor => colorScheme.primary;

  /// Secondary Color
  Color get secondaryColor => colorScheme.secondary;

  /// Surface Color
  Color get surfaceColor => colorScheme.surface;

  /// Error Color
  Color get errorColor => colorScheme.error;

  /// Text Themes
  TextTheme get textTheme => theme.textTheme;

  /// Display Large
  TextStyle? get displayLarge => textTheme.displayLarge;

  /// Display Medium
  TextStyle? get displayMedium => textTheme.displayMedium;

  /// Display Small
  TextStyle? get displaySmall => textTheme.displaySmall;

  /// Headline Medium
  TextStyle? get headlineMedium => textTheme.headlineMedium;

  /// Headline Small
  TextStyle? get headlineSmall => textTheme.headlineSmall;

  /// Title Large
  TextStyle? get titleLarge => textTheme.titleLarge;

  /// Title Medium
  TextStyle? get titleMedium => textTheme.titleMedium;

  /// Body Large
  TextStyle? get bodyLarge => textTheme.bodyLarge;

  /// Body Medium
  TextStyle? get bodyMedium => textTheme.bodyMedium;

  /// Body Small
  TextStyle? get bodySmall => textTheme.bodySmall;

  /// Label Large
  TextStyle? get labelLarge => textTheme.labelLarge;

  /// Media Query
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// Screen Size
  Size get screenSize => mediaQuery.size;

  /// Screen Width
  double get screenWidth => screenSize.width;

  /// Screen Height
  double get screenHeight => screenSize.height;

  /// Device Padding (SafeArea)
  EdgeInsets get devicePadding => mediaQuery.padding;

  /// Device View Insets (Keyboard)
  EdgeInsets get viewInsets => mediaQuery.viewInsets;

  /// Is Portrait
  bool get isPortrait => mediaQuery.orientation == Orientation.portrait;

  /// Is Landscape
  bool get isLandscape => mediaQuery.orientation == Orientation.landscape;

  /// Is Phone
  bool get isPhone => screenWidth < 600;

  /// Is Tablet
  bool get isTablet => screenWidth >= 600;

  /// Device Pixel Ratio
  double get devicePixelRatio => mediaQuery.devicePixelRatio;

  /// Keyboard Height
  double get keyboardHeight => viewInsets.bottom;

  /// Is Keyboard Visible
  bool get isKeyboardVisible => keyboardHeight > 0;

  /// Navigation Methods
  void pushNamedRoute(
    String routeName, {
    Object? arguments,
  }) {
    Navigator.of(this).pushNamed(routeName, arguments: arguments);
  }

  void pushReplacementNamedRoute(
    String routeName, {
    Object? arguments,
  }) {
    Navigator.of(this).pushReplacementNamed(routeName, arguments: arguments);
  }

  void pushNamedAndRemoveUntilRoute(
    String routeName,
    RoutePredicate predicate, {
    Object? arguments,
  }) {
    Navigator.of(this).pushNamedAndRemoveUntil(
      routeName,
      predicate,
      arguments: arguments,
    );
  }

  void popRoute<T>([T? result]) {
    Navigator.of(this).pop<T>(result);
  }

  /// Snackbar
  void showSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 2),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        action: action,
      ),
    );
  }

  /// Dialog
  Future<T?> showCustomDialog<T extends Object?>(
    Widget Function(BuildContext) builder, {
    bool barrierDismissible = true,
  }) =>
      showDialog<T>(
        context: this,
        builder: builder,
        barrierDismissible: barrierDismissible,
      );

  /// Modal Bottom Sheet
  Future<T?> showCustomModalBottomSheet<T extends Object?>(
    Widget Function(BuildContext) builder, {
    bool isDismissible = true,
    bool enableDrag = true,
  }) =>
      showModalBottomSheet<T>(
        context: this,
        builder: builder,
        isDismissible: isDismissible,
        enableDrag: enableDrag,
      );
}
