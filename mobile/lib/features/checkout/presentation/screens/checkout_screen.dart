import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/picpac_colors.dart';
import '../../../../core/theme/picpac_typography.dart';
import '../../domain/pickup_point.dart';
import '../widgets/pickup_points_sheet.dart';

class CheckoutScreen extends StatefulWidget {
  final String albumTitle;
  final String userName;
  final double itemsCost;
  final double discount;

  const CheckoutScreen({
    super.key,
    this.albumTitle = 'Выпускной 11-Б • 2026',
    this.userName = 'Артём',
    this.itemsCost = 2.90,
    this.discount = 0.81,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  PickupPoint? _selectedPickupPoint;

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();

  int _selectedBottomNavIndex = 1; // Корзина

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.userName;
    // По умолчанию предвыбираем удобный центральный пункт выдачи
    _selectedPickupPoint = PickupPoint.defaultPoints.first;
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  double get _totalCost {
    final total = widget.itemsCost - widget.discount;
    return total > 0 ? total : 0.0;
  }

  void _openPickupPointsModal() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return PickupPointsSheet(
          initialSelectedPoint: _selectedPickupPoint,
          onPointSelected: (point) {
            setState(() {
              _selectedPickupPoint = point;
            });
          },
        );
      },
    );
  }

  void _submitOrder() {
    final phone = _phoneController.text.trim();
    final name = _nameController.text.trim();
    final surname = _surnameController.text.trim();
    final email = _emailController.text.trim();

    if (_selectedPickupPoint == null) {
      _showToast('Пожалуйста, выберите пункт выдачи');
      return;
    }

    if (phone.isEmpty) {
      _showToast('Введите контактный номер телефона');
      return;
    }

    if (name.isEmpty) {
      _showToast('Введите ваше имя');
      return;
    }

    if (surname.isEmpty) {
      _showToast('Введите вашу фамилию');
      return;
    }

    if (email.isEmpty || !email.contains('@')) {
      _showToast('Введите корректный адрес эл. почты');
      return;
    }

    _showSuccessDialog();
  }

  void _showSuccessDialog() {
    final orderNumber = 'PP-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: PicPacColors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          contentPadding: const EdgeInsets.all(24.0),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60.0,
                height: 60.0,
                decoration: const BoxDecoration(
                  color: Color(0xFFDCFCE7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.check,
                  size: 32.0,
                  color: Color(0xFF16A34A),
                ),
              ),
              const SizedBox(height: 16.0),
              Text(
                'Заказ оформлен!',
                style: PicPacTypography.h1Title.copyWith(fontSize: 20.0),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8.0),
              Text(
                'Заказ №$orderNumber успешно принят в типографию picPac.by',
                style: PicPacTypography.photoCaption,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16.0),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: PicPacColors.surfaceGrey,
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: PicPacColors.borderDefault),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Пункт выдачи:',
                      style: PicPacTypography.metaInfo.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      _selectedPickupPoint?.name ?? '',
                      style: PicPacTypography.photoCaption.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      _selectedPickupPoint?.address ?? '',
                      style: PicPacTypography.metaInfo,
                    ),
                    const SizedBox(height: 6.0),
                    Text(
                      'Ориентировочная готовность: через 2 дня',
                      style: PicPacTypography.metaInfo.copyWith(
                        color: PicPacColors.primaryCoral,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20.0),
              GestureDetector(
                onTap: () {
                  Navigator.pop(dialogContext); // закрываем диалог
                  Navigator.pop(context); // возвращаемся в редактор
                },
                behavior: HitTestBehavior.opaque,
                child: Container(
                  height: 46.0,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: PicPacColors.primaryCoral,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Вернуться в редактор',
                    style: PicPacTypography.buttonText,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: PicPacTypography.buttonText.copyWith(fontSize: 13.0),
        ),
        backgroundColor: PicPacColors.textDark,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: PicPacColors.primaryCoral,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          behavior: HitTestBehavior.opaque,
          child: const Icon(
            LucideIcons.chevronLeft,
            size: 24.0,
            color: PicPacColors.white,
          ),
        ),
        title: const Text(
          'Оформление',
          style: TextStyle(
            color: PicPacColors.white,
            fontSize: 18.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Кнопка / Карточка выбора пункта выдачи
              _buildPickupPointSection(),

              const SizedBox(height: 14.0),

              // 2. Карточка «Данные покупателя»
              _buildCustomerDataCard(),

              const SizedBox(height: 14.0),

              // 3. Карточка «Информация об оплате»
              _buildPaymentInfoCard(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildPickupPointSection() {
    if (_selectedPickupPoint == null) {
      return GestureDetector(
        onTap: _openPickupPointsModal,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 48.0,
          decoration: BoxDecoration(
            color: PicPacColors.white,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: PicPacColors.primaryCoral, width: 1.2),
          ),
          alignment: Alignment.center,
          child: const Text(
            'Выберите пункт выдачи',
            style: TextStyle(
              color: PicPacColors.primaryCoral,
              fontSize: 15.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(14.0),
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
              Container(
                padding: const EdgeInsets.all(6.0),
                decoration: BoxDecoration(
                  color: PicPacColors.primaryCoralSoft,
                  borderRadius: BorderRadius.circular(6.0),
                ),
                child: const Icon(
                  LucideIcons.mapPin,
                  size: 16.0,
                  color: PicPacColors.primaryCoral,
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  _selectedPickupPoint!.name,
                  style: PicPacTypography.buttonTextDark.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 14.5,
                  ),
                ),
              ),
              GestureDetector(
                onTap: _openPickupPointsModal,
                behavior: HitTestBehavior.opaque,
                child: Text(
                  'Изменить',
                  style: PicPacTypography.buttonText.copyWith(
                    color: PicPacColors.primaryCoral,
                    fontSize: 13.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6.0),
          Padding(
            padding: const EdgeInsets.only(left: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedPickupPoint!.address,
                  style: PicPacTypography.photoCaption.copyWith(fontSize: 12.5),
                ),
                const SizedBox(height: 2.0),
                Text(
                  _selectedPickupPoint!.workingHours,
                  style: PicPacTypography.metaInfo,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerDataCard() {
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
          Text(
            'Данные покупателя',
            style: PicPacTypography.photoCaption.copyWith(
              color: PicPacColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12.0),

          // Телефон
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            inputFormatters: [_BelarusPhoneFormatter()],
            style: const TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.w600,
              color: PicPacColors.textDark,
            ),
            decoration: const InputDecoration(
              hintText: '+375 (__) ___-__-__',
              hintStyle: TextStyle(
                color: PicPacColors.textMuted,
                fontSize: 15.0,
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: PicPacColors.borderDefault, width: 1.2),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: PicPacColors.primaryCoral, width: 1.8),
              ),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 8.0),
            ),
          ),

          const SizedBox(height: 16.0),

          // Имя
          TextField(
            controller: _nameController,
            style: PicPacTypography.photoCaption.copyWith(
              fontSize: 15.0,
              fontWeight: FontWeight.w600,
            ),
            decoration: const InputDecoration(
              hintText: 'Имя*',
              hintStyle: TextStyle(color: PicPacColors.textMuted, fontSize: 14.5),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: PicPacColors.borderDefault, width: 1.2),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: PicPacColors.primaryCoral, width: 1.8),
              ),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 8.0),
            ),
          ),

          const SizedBox(height: 16.0),

          // Фамилия
          TextField(
            controller: _surnameController,
            style: PicPacTypography.photoCaption.copyWith(
              fontSize: 15.0,
              fontWeight: FontWeight.w600,
            ),
            decoration: const InputDecoration(
              hintText: 'Фамилия*',
              hintStyle: TextStyle(color: PicPacColors.textMuted, fontSize: 14.5),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: PicPacColors.borderDefault, width: 1.2),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: PicPacColors.primaryCoral, width: 1.8),
              ),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 8.0),
            ),
          ),

          const SizedBox(height: 16.0),

          // Эл. почта
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: PicPacTypography.photoCaption.copyWith(
              fontSize: 15.0,
              fontWeight: FontWeight.w600,
            ),
            decoration: const InputDecoration(
              hintText: 'Эл. почта*',
              hintStyle: TextStyle(color: PicPacColors.textMuted, fontSize: 14.5),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: PicPacColors.borderDefault, width: 1.2),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: PicPacColors.primaryCoral, width: 1.8),
              ),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 8.0),
            ),
          ),

          const SizedBox(height: 20.0),

          // Комментарий к заказу (большое скругленное поле)
          Container(
            height: 84.0,
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: PicPacColors.white,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: PicPacColors.borderDefault, width: 1.2),
            ),
            child: TextField(
              controller: _commentController,
              maxLines: null,
              expands: true,
              style: PicPacTypography.photoCaption,
              decoration: const InputDecoration(
                hintText: 'Комментарий к заказу',
                hintStyle: TextStyle(
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
    );
  }

  Widget _buildPaymentInfoCard() {
    final formattedItemsCost = '${widget.itemsCost.toStringAsFixed(2).replaceAll('.', ',')} руб.';
    final formattedDiscount = '-${widget.discount.toStringAsFixed(2).replaceAll('.', ',')} руб.';
    final formattedTotal = '${_totalCost.toStringAsFixed(2).replaceAll('.', ',')} руб.';

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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Информация об оплате',
            style: PicPacTypography.photoCaption.copyWith(
              color: PicPacColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14.0),

          // Стоимость позиций
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Стоимость позиций:',
                  style: PicPacTypography.photoCaption.copyWith(fontSize: 14.0),
                ),
              ),
              const SizedBox(width: 8.0),
              Text(
                formattedItemsCost,
                style: PicPacTypography.photoCaption.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 14.0,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8.0),

          // Доставка
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Доставка:',
                  style: PicPacTypography.photoCaption.copyWith(fontSize: 14.0),
                ),
              ),
              const SizedBox(width: 8.0),
              Text(
                'Бесплатно',
                style: PicPacTypography.photoCaption.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 14.0,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8.0),

          // Скидка
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Скидка:',
                  style: PicPacTypography.photoCaption.copyWith(fontSize: 14.0),
                ),
              ),
              const SizedBox(width: 8.0),
              Text(
                formattedDiscount,
                style: const TextStyle(
                  color: PicPacColors.primaryCoral,
                  fontWeight: FontWeight.w600,
                  fontSize: 14.0,
                ),
              ),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Divider(color: PicPacColors.borderDefault, height: 1.0),
          ),

          // Итого к оплате
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Итого к оплате:',
                  style: PicPacTypography.h2Section.copyWith(fontSize: 17.0),
                ),
              ),
              const SizedBox(width: 8.0),
              Text(
                formattedTotal,
                style: const TextStyle(
                  color: PicPacColors.textDark,
                  fontSize: 19.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16.0),

          // Кнопка «Подтвердить и заказать»
          GestureDetector(
            onTap: _submitOrder,
            behavior: HitTestBehavior.opaque,
            child: Container(
              height: 48.0,
              decoration: BoxDecoration(
                color: PicPacColors.primaryCoral,
                borderRadius: BorderRadius.circular(8.0),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Подтвердить и заказать',
                style: TextStyle(
                  color: PicPacColors.white,
                  fontSize: 15.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFE2E8F0),
        border: Border(top: BorderSide(color: Color(0xFFCBD5E1), width: 0.8)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 54.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, LucideIcons.home, 'Picpac'),
              _buildNavItem(1, LucideIcons.shoppingCart, 'Корзина', badge: '2'),
              _buildNavItem(2, LucideIcons.receipt, 'Заказы'),
              _buildNavItem(3, LucideIcons.megaphone, 'Новости'),
              _buildNavItem(4, LucideIcons.user, 'Профиль'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, {String? badge}) {
    final isSelected = index == _selectedBottomNavIndex;
    final color = isSelected ? PicPacColors.primaryCoral : const Color(0xFF64748B);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedBottomNavIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(icon, size: 20.0, color: color),
              if (badge != null)
                Positioned(
                  top: -6.0,
                  right: -8.0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 1.0),
                    decoration: BoxDecoration(
                      color: PicPacColors.primaryCoral,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    constraints: const BoxConstraints(minWidth: 14.0, minHeight: 14.0),
                    child: Center(
                      child: Text(
                        badge,
                        style: const TextStyle(
                          color: PicPacColors.white,
                          fontSize: 9.0,
                          fontWeight: FontWeight.w700,
                          height: 1.0,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 3.0),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.0,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Маска ввода белорусского номера телефона: +375 (XX) XXX-XX-XX
class _BelarusPhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');

    // Если начинается с 375, убираем код страны для форматирования
    if (digitsOnly.startsWith('375')) {
      digitsOnly = digitsOnly.substring(3);
    }

    if (digitsOnly.length > 9) {
      digitsOnly = digitsOnly.substring(0, 9);
    }

    final buffer = StringBuffer('+375 ');

    if (digitsOnly.isNotEmpty) {
      buffer.write('(');
      if (digitsOnly.length <= 2) {
        buffer.write(digitsOnly);
      } else {
        buffer.write(digitsOnly.substring(0, 2));
        buffer.write(') ');

        if (digitsOnly.length <= 5) {
          buffer.write(digitsOnly.substring(2));
        } else {
          buffer.write(digitsOnly.substring(2, 5));
          buffer.write('-');

          if (digitsOnly.length <= 7) {
            buffer.write(digitsOnly.substring(5));
          } else {
            buffer.write(digitsOnly.substring(5, 7));
            buffer.write('-');
            buffer.write(digitsOnly.substring(7));
          }
        }
      }
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
