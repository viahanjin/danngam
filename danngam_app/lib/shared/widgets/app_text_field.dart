import 'package:flutter/material.dart';
import '../constants/app_dimensions.dart';

/// Custom Text Input Field Widget
class AppTextField extends StatefulWidget {
  final String? label;
  final String? hintText;
  final String? initialValue;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final int maxLines;
  final int minLines;
  final int? maxLength;
  final bool obscureText;
  final bool readOnly;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final String? errorText;
  final bool isRequired;

  const AppTextField({
    super.key,
    this.label,
    this.hintText,
    this.initialValue,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.maxLines = 1,
    this.minLines = 1,
    this.maxLength,
    this.obscureText = false,
    this.readOnly = false,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.onTap,
    this.errorText,
    this.isRequired = false,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscureText;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(
              bottom: AppDimensions.marginSmall,
            ),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: widget.label,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  if (widget.isRequired)
                    const TextSpan(
                      text: ' *',
                      style: TextStyle(color: Colors.red),
                    ),
                ],
              ),
            ),
          ),
        TextField(
          controller: widget.controller ?? (widget.initialValue != null ? TextEditingController(text: widget.initialValue) : null),
          focusNode: _focusNode,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          maxLines: widget.obscureText ? 1 : widget.maxLines,
          minLines: widget.minLines,
          maxLength: widget.maxLength,
          obscureText: _obscureText,
          readOnly: widget.readOnly,
          onChanged: widget.onChanged,
          onTap: widget.onTap,
          decoration: InputDecoration(
            hintText: widget.hintText,
            errorText: widget.errorText,
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.obscureText
                ? IconButton(
                    icon: Icon(
                      _obscureText
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: _toggleObscureText,
                  )
                : widget.suffixIcon,
          ),
        ),
      ],
    );
  }
}

/// Phone Number Input Field
class PhoneNumberField extends StatelessWidget {
  final String? label;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final String? errorText;

  const PhoneNumberField({
    super.key,
    this.label,
    this.controller,
    this.validator,
    this.onChanged,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: label,
      controller: controller,
      hintText: '010-1234-5678',
      keyboardType: TextInputType.phone,
      prefixIcon: const Icon(Icons.phone_outlined),
      validator: validator,
      onChanged: onChanged,
      errorText: errorText,
      isRequired: true,
    );
  }
}

/// OTP Input Field
class OtpField extends StatelessWidget {
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final String? errorText;

  const OtpField({
    super.key,
    this.controller,
    this.validator,
    this.onChanged,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: '인증번호',
      controller: controller,
      hintText: '123456',
      keyboardType: TextInputType.number,
      maxLength: 6,
      prefixIcon: const Icon(Icons.lock_outline),
      validator: validator,
      onChanged: onChanged,
      errorText: errorText,
      isRequired: true,
    );
  }
}

/// Search Field
class SearchField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final void Function(String)? onChanged;
  final VoidCallback? onClear;

  const SearchField({
    super.key,
    this.controller,
    this.hintText,
    this.onChanged,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      hintText: hintText ?? '장비 검색',
      keyboardType: TextInputType.text,
      prefixIcon: const Icon(Icons.search),
      suffixIcon: controller?.text.isNotEmpty ?? false
          ? IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                controller?.clear();
                onClear?.call();
              },
            )
          : null,
      onChanged: onChanged,
    );
  }
}
