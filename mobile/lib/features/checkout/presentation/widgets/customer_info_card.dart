import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/picpac_colors.dart';
import '../../../../core/theme/picpac_typography.dart';
import '../../../../core/utils/phone_input_formatter.dart';

class CustomerInfoCard extends StatelessWidget {
  final TextEditingController phoneController;
  final TextEditingController nameController;
  final TextEditingController surnameController;
  final TextEditingController emailController;
  final TextEditingController commentController;

  const CustomerInfoCard({
    super.key,
    required this.phoneController,
    required this.nameController,
    required this.surnameController,
    required this.emailController,
    required this.commentController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: PicPacColors.white,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: PicPacColors.borderDefault),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                LucideIcons.user,
                size: 17.0,
                color: PicPacColors.primaryCoral,
              ),
              const SizedBox(width: 8.0),
              Text(
                'Данные покупателя',
                style: PicPacTypography.h2Section.copyWith(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14.0),

          // Телефон
          _buildModernInputField(
            controller: phoneController,
            label: 'Номер телефона',
            hintText: '+375 (__) ___-__-__',
            icon: LucideIcons.phone,
            keyboardType: TextInputType.phone,
            inputFormatters: const [BelarusPhoneFormatter()],
          ),

          const SizedBox(height: 12.0),

          // Имя
          _buildModernInputField(
            controller: nameController,
            label: 'Имя*',
            hintText: 'Имя',
            icon: LucideIcons.user,
          ),

          const SizedBox(height: 12.0),

          // Фамилия
          _buildModernInputField(
            controller: surnameController,
            label: 'Фамилия*',
            hintText: 'Фамилия',
            icon: LucideIcons.userCheck,
          ),

          const SizedBox(height: 12.0),

          // Эл. почта
          _buildModernInputField(
            controller: emailController,
            label: 'Эл. почта*',
            hintText: 'Эл. почта',
            icon: LucideIcons.mail,
            keyboardType: TextInputType.emailAddress,
          ),

          const SizedBox(height: 14.0),

          // Комментарий к заказу
          Text(
            'Комментарий к заказу',
            style: PicPacTypography.metaInfo.copyWith(
              fontWeight: FontWeight.w600,
              color: PicPacColors.textDark,
            ),
          ),
          const SizedBox(height: 6.0),
          Container(
            height: 76.0,
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
            decoration: BoxDecoration(
              color: PicPacColors.surfaceGrey,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: PicPacColors.borderDefault),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2.0),
                  child: Icon(
                    LucideIcons.messageSquare,
                    size: 16.0,
                    color: PicPacColors.textMuted,
                  ),
                ),
                const SizedBox(width: 10.0),
                Expanded(
                  child: TextField(
                    controller: commentController,
                    maxLines: null,
                    expands: true,
                    style: PicPacTypography.photoCaption.copyWith(
                      color: PicPacColors.textDark,
                      fontSize: 14.0,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Пожелания к заказу или доставке...',
                      hintStyle: TextStyle(
                        color: PicPacColors.textMuted,
                        fontSize: 13.5,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernInputField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: PicPacTypography.metaInfo.copyWith(
            fontWeight: FontWeight.w600,
            color: PicPacColors.textDark,
          ),
        ),
        const SizedBox(height: 6.0),
        Container(
          height: 48.0,
          decoration: BoxDecoration(
            color: PicPacColors.surfaceGrey,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: PicPacColors.borderDefault),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              Icon(
                icon,
                size: 16.0,
                color: PicPacColors.textMuted,
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  inputFormatters: inputFormatters,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500,
                    color: PicPacColors.textDark,
                  ),
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: const TextStyle(
                      color: PicPacColors.textMuted,
                      fontSize: 14.0,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
