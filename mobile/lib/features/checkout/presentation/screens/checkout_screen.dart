import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/picpac_colors.dart';
import '../../../../core/theme/picpac_typography.dart';
import '../../../../core/widgets/picpac_bottom_nav_bar.dart';
import '../../domain/checkout_validator.dart';
import '../../domain/pickup_point.dart';
import '../widgets/cart_album_summary_card.dart';
import '../widgets/checkout_pickup_point_card.dart';
import '../widgets/customer_info_card.dart';
import '../widgets/order_success_dialog.dart';
import '../widgets/payment_summary_card.dart';
import '../widgets/pickup_points_sheet.dart';

class CheckoutScreen extends StatefulWidget {
  final String albumTitle;
  final String userName;
  final double itemsCost;
  final double discount;
  final int spreadsCount;
  final String format;
  final ICheckoutValidator validator;

  const CheckoutScreen({
    super.key,
    this.albumTitle = 'Выпускной 11-Б • 2026',
    this.userName = 'Артём',
    this.itemsCost = 2.90,
    this.discount = 0.81,
    this.spreadsCount = 10,
    this.format = '20×20 см',
    this.validator = const CheckoutValidator(),
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
    final validationError = widget.validator.validate(
      pickupPoint: _selectedPickupPoint,
      phone: _phoneController.text,
      name: _nameController.text,
      surname: _surnameController.text,
      email: _emailController.text,
    );

    if (validationError != null) {
      _showToast(validationError);
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
        return OrderSuccessDialog(
          orderNumber: orderNumber,
          pickupPoint: _selectedPickupPoint,
          onReturnToEditor: () {
            Navigator.pop(dialogContext); // закрываем диалог
            Navigator.pop(context); // возвращаемся в редактор
          },
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
              // 0. Карточка добавленного альбома в корзине
              CartAlbumSummaryCard(
                albumTitle: widget.albumTitle,
                itemsCost: widget.itemsCost,
                spreadsCount: widget.spreadsCount,
                format: widget.format,
              ),

              const SizedBox(height: 14.0),

              // 1. Кнопка / Карточка выбора пункта выдачи
              CheckoutPickupPointCard(
                selectedPickupPoint: _selectedPickupPoint,
                onSelectOrChange: _openPickupPointsModal,
              ),

              const SizedBox(height: 14.0),

              // 2. Карточка «Данные покупателя»
              CustomerInfoCard(
                phoneController: _phoneController,
                nameController: _nameController,
                surnameController: _surnameController,
                emailController: _emailController,
                commentController: _commentController,
              ),

              const SizedBox(height: 14.0),

              // 3. Карточка «Информация об оплате»
              PaymentSummaryCard(
                itemsCost: widget.itemsCost,
                discount: widget.discount,
                onSubmitOrder: _submitOrder,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: PicPacBottomNavBar(
        currentIndex: 0,
        onCartTap: () => Navigator.pop(context),
      ),
    );
  }
}
