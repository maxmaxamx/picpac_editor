import 'package:flutter/material.dart';
import '../../../../core/theme/picpac_colors.dart';
import '../../../../core/theme/picpac_typography.dart';

class PinCodeInput extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onCompleted;

  const PinCodeInput({
    super.key,
    required this.controller,
    this.onCompleted,
  });

  @override
  State<PinCodeInput> createState() => _PinCodeInputState();
}

class _PinCodeInputState extends State<PinCodeInput> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {});
    if (widget.controller.text.length == 6) {
      widget.onCompleted?.call(widget.controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = widget.controller.text;

    return GestureDetector(
      onTap: () {
        _focusNode.requestFocus();
      },
      behavior: HitTestBehavior.opaque,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Скрытое текстовое поле для нативного ввода цифр
          Opacity(
            opacity: 0.0,
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              keyboardType: TextInputType.number,
              maxLength: 6,
              autofocus: false,
              decoration: const InputDecoration(
                counterText: '',
              ),
            ),
          ),

          // Визуальное отображение 6 ячеек с разделителем: [X][X][X] - [X][X][X]
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i < 6; i++) ...[
                  if (i == 3) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0),
                      child: Container(
                        width: 8.0,
                        height: 2.0,
                        decoration: BoxDecoration(
                          color: PicPacColors.textMuted,
                          borderRadius: BorderRadius.circular(1.0),
                        ),
                      ),
                    ),
                  ],
                  _buildDigitBox(
                    digit: i < text.length ? text[i] : '',
                    isFocused: _focusNode.hasFocus && i == text.length,
                  ),
                  if (i != 2 && i != 5) const SizedBox(width: 6.0),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDigitBox({required String digit, required bool isFocused}) {
    final hasChar = digit.isNotEmpty;

    return Container(
      width: 40.0,
      height: 48.0,
      decoration: BoxDecoration(
        color: hasChar ? PicPacColors.white : PicPacColors.surfaceGrey,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: isFocused
              ? PicPacColors.primaryCoral
              : (hasChar
                  ? PicPacColors.textDark
                  : PicPacColors.borderDefault),
          width: isFocused ? 2.0 : 1.0,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        digit,
        style: PicPacTypography.h1Title.copyWith(
          fontSize: 22.0,
          fontWeight: FontWeight.w700,
          color: PicPacColors.textDark,
        ),
      ),
    );
  }
}
