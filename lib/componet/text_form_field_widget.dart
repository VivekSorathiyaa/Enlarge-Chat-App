import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';


import '../controller/theme_controller.dart';
import '../utils/colors.dart';
import '../utils/validators.dart';
import 'app_text_style.dart';

class TextFormFieldWidget extends StatelessWidget {

   TextFormFieldWidget({
    Key? key,
    this.fieldKey,
    this.hintText,
    this.labelText,
    this.textStyle,
    this.hintStyle,
    this.validator,
    this.prefixIcon,
    required this.controller,
    this.focusNode,
    this.maxLines,
    this.maxLength,
    this.suffixIcon,
    this.onTap,
    this.onChanged,
    this.onFieldSubmitted,
    this.textInputAction,
    this.keyboardType,
    this.borderColor,
    this.filledColor,
    this.enabled,
    this.autofocus,
    this.cursorColor,
    this.readonly,
    this.filled,
    this.scropadding,
    this.textAlign = TextAlign.left,
    this.contentPadding,
// this.change,
  }) : super(key: key);
  final EdgeInsets? scropadding;
  final Key? fieldKey;
  final bool? readonly;
  final String? hintText;
  final String? labelText;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final Color? borderColor;
  Color? filledColor;
  final Color? cursorColor;
  final FormFieldValidator<String?>? validator;
  final ValueChanged<String?>? onFieldSubmitted;
  final ValueChanged<String?>? onChanged;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final GestureTapCallback? onTap;
  final int? maxLines;
  final int? maxLength;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final TextAlign textAlign;
  final bool? enabled;
  final bool? filled;
  final bool? autofocus;
  final EdgeInsetsGeometry? contentPadding;

  @override
  bool isAnotherPage = true;
  Widget build(BuildContext context) {
    final ThemeController themeController =Get.put(ThemeController());

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (labelText != null)
            Padding(
              padding: EdgeInsets.only(top: 18, bottom: 10),
              child: Text(
                labelText ?? "",
                style: AppTextStyle.normalRegular14
                    .copyWith(fontWeight: FontWeight.w500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          textFormField(
            fieldKey: fieldKey,
            focusNode: focusNode,
            hintText: hintText,
            scropadding: scropadding,
            filled: filled,
            controller: controller,
            keyboardType: keyboardType ?? TextInputType.text,
            validator: validator,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
              autofocus: autofocus,
            maxLength: maxLength,
            maxLines: maxLines,
            enabled: enabled ?? true,
            readonly: readonly,
            textInputAction: textInputAction,
            textAlign: textAlign,
            onTap: onTap,
            onFieldSubmitted: onFieldSubmitted,
            onChanged: onChanged,
            textStyle:themeController.isDark.value? TextStyle(color: primaryWhite):
            TextStyle(color: primaryBlack),
            borderColor:themeController.isDark.value?blackThemeColor:Colors.grey,
            filledColor: themeController.isDark.value ?blackThemeColor:primaryWhite,
            // hintStyle: hintStyle ?? TextStyle(color: primaryBlack),
            hintStyle:themeController.isDark.value? TextStyle(color: primaryWhite.withOpacity(0.8)):
                TextStyle(color: greyColor),
            cursorColor: Colors.grey,


          ),

        ],
      );

  }
}


class PasswordWidget extends StatefulWidget {
  final Key? fieldKey;
  final int? maxLength;
  final String? hintText;
  final String? labelText;
  final bool? autofocus;
  final FormFieldValidator<String?>? validator;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;

  const PasswordWidget({
    Key? key,
    required this.controller,
    this.fieldKey,
    this.maxLength,
    this.hintText,
    this.autofocus,
    this.validator,
    this.focusNode,
    this.labelText,
    this.textInputAction,
  }) : super(key: key);

  @override
  _PasswordWidgetState createState() => _PasswordWidgetState();
}


class _PasswordWidgetState extends State<PasswordWidget> {
  bool _obscureText = true;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText != null)
          Padding(
            padding: EdgeInsets.only(top: 18, bottom: 8),
            child: Text(
              widget.labelText ?? "",
              style: AppTextStyle.normalRegular14
                  .copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        textFormField(
          
            fieldKey: widget.fieldKey,
            hintText: widget.hintText,
            obscureText: _obscureText,
            autofocus: widget.autofocus ?? false,
            focusNode: widget.focusNode,
            controller: widget.controller,
            textInputAction: widget.textInputAction,
            maxLength: widget.maxLength,
            maxLines: 1,
            suffixIcon: GestureDetector(
              onTap: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
              child: Icon(
                !_obscureText
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: greyColor,
              ),
            ),
            validator: widget.validator ??
                (value) =>
                    Validators.validateRequired(value!.trim(), 'Password')),
      ],
    );
  }
}

TextFormField textFormField({
  final Key? fieldKey,
  final String? hintText,
  final String? labelText,
  final String? helperText,
  final String? initialValue,
  final int? errorMaxLines,
  final int? maxLines,
  final int? maxLength,
  final double? borderRaduis = 8,
  final bool? enabled,
  final bool? filled,
  final bool? autofocus,
  final bool obscureText = false,
  Color? filledColor,
  final Color? cursorColor,
  final Color? borderColor,
  final Widget? prefixIcon,
  final Widget? suffixIcon,
  final FocusNode? focusNode,
  final TextStyle? style,
  final TextStyle? textStyle,
  final TextStyle? hintStyle,
  final TextAlign textAlign = TextAlign.left,
  final TextEditingController? controller,
  final List<TextInputFormatter>? inputFormatters,
  final TextInputAction? textInputAction,
  final TextInputType? keyboardType,
  final TextCapitalization textCapitalization = TextCapitalization.none,
  final GestureTapCallback? onTap,
  final FormFieldSetter<String?>? onSaved,
  final FormFieldValidator<String?>? validator,
  final ValueChanged<String?>? onChanged,
  final ValueChanged<String?>? onFieldSubmitted,
  final BorderSide? border,
  final EdgeInsetsGeometry? contentPadding,
  final bool? readonly,
  final EdgeInsets? scropadding,
}) {
  return TextFormField(
    autovalidateMode: AutovalidateMode.onUserInteraction,
    scrollPadding: scropadding ?? EdgeInsets.zero,
    key: fieldKey,
    readOnly: readonly ?? false,
    controller: controller,
    focusNode: focusNode,
    maxLines: maxLines,
    initialValue: initialValue,
    keyboardType: keyboardType,
    textCapitalization: textCapitalization,
    obscureText: obscureText,
    enabled: enabled,
    validator: validator,
    maxLength: maxLength,
    textInputAction: textInputAction,
    inputFormatters: inputFormatters,
    onTap: onTap,
    minLines: 1,
    onSaved: onSaved,
    onChanged: onChanged,
    onFieldSubmitted: onFieldSubmitted,
    autocorrect: true,
    autofocus: autofocus ?? false,
    textAlign: textAlign,
    cursorColor: cursorColor ?? primaryBlack,
    cursorHeight: 20,
    style:
        textStyle ?? AppTextStyle.normalRegular14.copyWith(color: primaryBlack),
    decoration: InputDecoration(
      prefixIcon: prefixIcon,
      enabled: enabled ?? true,
      suffixIcon: suffixIcon,
      labelText: labelText,
      helperText: helperText,
      filled: filled ?? true,
      fillColor: filledColor ?? primaryWhite,
      errorMaxLines: 5,
      prefixIconColor: hintTextColor,
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      errorStyle: AppTextStyle.normalRegular12.copyWith(color: redColor),
      hintText: hintText,
      hintStyle: hintStyle ??
          AppTextStyle.normalRegular14.copyWith(color: hintTextColor),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRaduis ?? 8),
          borderSide: BorderSide(color: borderColor ?? greyBorderColor)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRaduis ?? 8),
          borderSide: BorderSide(color: borderColor ?? greyBorderColor)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRaduis ?? 8),
          borderSide: BorderSide(color: borderColor ?? greyBorderColor)),
    ),
  );
}
