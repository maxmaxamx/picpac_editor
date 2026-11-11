import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/session/session_state.dart';
import '../../../../core/theme/picpac_colors.dart';
import '../../../../core/theme/picpac_typography.dart';
import '../../../../core/widgets/picpac_bottom_nav_bar.dart';
import '../../../checkout/domain/pickup_point.dart';
import '../../../checkout/presentation/screens/checkout_screen.dart';
import '../../../checkout/presentation/widgets/pickup_points_sheet.dart';
import '../widgets/album_cover_thumbnail.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  PickupPoint? _selectedPickupPoint;
  bool _splitPaymentEnabled = false;

  @override
  void initState() {
    super.initState();
    _selectedPickupPoint = PickupPoint.defaultPoints.first;
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

  void _onCheckoutTap(List<CartItem> selectedItems, double totalCost) {
    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Выберите хотя бы один альбом для заказа')),
      );
      return;
    }

    final firstItem = selectedItems.first;
    final session = ref.read(sessionProvider);
    final userName = session.user?.displayName.isNotEmpty == true
        ? session.user!.displayName
        : 'Артём';

    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => CheckoutScreen(
          albumTitle: firstItem.title,
          userName: userName,
          itemsCost: totalCost,
          discount: 0.0,
          spreadsCount: firstItem.spreadsCount,
          format: firstItem.format,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final items = session.cartItems;

    final selectedItems = items.where((e) => e.isSelected).toList();
    final allSelected = items.isNotEmpty && selectedItems.length == items.length;
    final totalCost = selectedItems.fold<double>(
      0.0,
      (sum, item) => sum + (item.price * item.quantity),
    );
    final totalCount = selectedItems.fold<int>(
      0,
      (sum, item) => sum + item.quantity,
    );

    return Scaffold(
      backgroundColor: PicPacColors.surfaceGrey,
      appBar: AppBar(
        backgroundColor: PicPacColors.white,
        elevation: 0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          behavior: HitTestBehavior.opaque,
          child: const Icon(
            LucideIcons.chevronLeft,
            size: 24.0,
            color: PicPacColors.textDark,
          ),
        ),
        title: Text(
          items.isNotEmpty ? 'Корзина (${items.length})' : 'Корзина',
          style: const TextStyle(
            color: PicPacColors.textDark,
            fontSize: 17.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          if (items.isNotEmpty)
            IconButton(
              icon: const Icon(
                LucideIcons.trash2,
                size: 20.0,
                color: PicPacColors.textMuted,
              ),
              onPressed: () {
                for (final item in selectedItems) {
                  ref.read(sessionProvider.notifier).removeCartItem(item.id);
                }
              },
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: PicPacColors.borderDefault,
            height: 0.8,
          ),
        ),
      ),
      body: items.isEmpty
          ? _buildEmptyState()
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Верхняя плашка адреса доставки (как на Wildberries)
                        _buildAddressBanner(),

                        const SizedBox(height: 10.0),

                        // Строка управления выбором («Выбрать все»)
                        _buildSelectionControls(allSelected, selectedItems.length),

                        const SizedBox(height: 10.0),

                        // Список карточек альбомов в корзине
                        ...items.map((item) => _buildCartItemCard(item)),

                        const SizedBox(height: 12.0),

                        // Плашка оплаты частями / долями
                        _buildSplitPaymentBanner(totalCost),

                        const SizedBox(height: 16.0),
                      ],
                    ),
                  ),
                ),

                // Нижний блок подтверждения заказа с кнопкой «Оформить заказ»
                _buildBottomCheckoutBar(selectedItems, totalCost, totalCount),
              ],
            ),
      bottomNavigationBar: const PicPacBottomNavBar(currentIndex: 0),
    );
  }

  Widget _buildAddressBanner() {
    final addressText = _selectedPickupPoint?.name ?? 'Пункт выдачи picPac Hub';
    return GestureDetector(
      onTap: _openPickupPointsModal,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: PicPacColors.white,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: PicPacColors.borderDefault),
        ),
        child: Row(
          children: [
            const Icon(
              LucideIcons.mapPin,
              size: 16.0,
              color: PicPacColors.primaryCoral,
            ),
            const SizedBox(width: 8.0),
            Expanded(
              child: Text(
                addressText,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: PicPacColors.textDark,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(
              LucideIcons.chevronDown,
              size: 16.0,
              color: PicPacColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionControls(bool allSelected, int selectedCount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: PicPacColors.white,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: PicPacColors.borderDefault),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              ref.read(sessionProvider.notifier).toggleSelectAll(!allSelected);
            },
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                _buildCheckbox(allSelected),
                const SizedBox(width: 8.0),
                Text(
                  'Выбрать все ($selectedCount)',
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: PicPacColors.textDark,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          const Icon(
            LucideIcons.heart,
            size: 18.0,
            color: PicPacColors.textMuted,
          ),
          const SizedBox(width: 14.0),
          const Icon(
            LucideIcons.share2,
            size: 18.0,
            color: PicPacColors.textMuted,
          ),
        ],
      ),
    );
  }

  Widget _buildCartItemCard(CartItem item) {
    final formattedPrice = '${(item.price * item.quantity).toStringAsFixed(2).replaceAll('.', ',')} руб.';
    final formattedOldPrice = item.oldPrice != null
        ? '${(item.oldPrice! * item.quantity).toStringAsFixed(2).replaceAll('.', ',')} руб.'
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: PicPacColors.white,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(
          color: item.isSelected
              ? PicPacColors.primaryCoral.withValues(alpha: 0.3)
              : PicPacColors.borderDefault,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Чекбокс выбора позиции
              Padding(
                padding: const EdgeInsets.only(top: 36.0, right: 8.0),
                child: GestureDetector(
                  onTap: () {
                    ref.read(sessionProvider.notifier).toggleItemSelection(item.id);
                  },
                  behavior: HitTestBehavior.opaque,
                  child: _buildCheckbox(item.isSelected),
                ),
              ),

              // Реалистичное превью твердой обложки альбома
              AlbumCoverThumbnail(
                title: item.title,
                templateId: item.templateId,
                coverImageUrl: item.coverImageUrl,
                width: 82.0,
                height: 104.0,
              ),

              const SizedBox(width: 12.0),

              // Блок описания и параметров товара (стиль маркетплейса)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Бейдж акции и опции
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444),
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          child: const Text(
                            'АКЦИЯ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9.0,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            ref.read(sessionProvider.notifier).removeCartItem(item.id);
                          },
                          behavior: HitTestBehavior.opaque,
                          child: const Icon(
                            LucideIcons.moreVertical,
                            size: 16.0,
                            color: PicPacColors.textMuted,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6.0),

                    // Цена (актуальная крупно и перечеркнутая)
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 6.0,
                      children: [
                        Text(
                          formattedPrice,
                          style: const TextStyle(
                            fontSize: 17.5,
                            fontWeight: FontWeight.w900,
                            color: PicPacColors.primaryCoral,
                          ),
                        ),
                        if (formattedOldPrice != null)
                          Text(
                            formattedOldPrice,
                            style: const TextStyle(
                              fontSize: 12.0,
                              fontWeight: FontWeight.w500,
                              color: PicPacColors.textMuted,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 3.0),

                    // Категория товара с галочкой подлинности
                    Row(
                      children: [
                        const Icon(
                          LucideIcons.badgeCheck,
                          size: 13.0,
                          color: Color(0xFF3B82F6),
                        ),
                        const SizedBox(width: 4.0),
                        Text(
                          'Фотокниги picPac',
                          style: PicPacTypography.metaInfo.copyWith(
                            color: const Color(0xFF3B82F6),
                            fontWeight: FontWeight.w600,
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 3.0),

                    // Название альбома
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w700,
                        color: PicPacColors.textDark,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 3.0),

                    // Параметры книги
                    Text(
                      '${item.format} • Твердая обложка • ${item.spreadsCount} разворотов',
                      style: PicPacTypography.metaInfo.copyWith(
                        fontSize: 11.5,
                        color: PicPacColors.textMuted,
                      ),
                    ),

                    const SizedBox(height: 3.0),

                    // Сроки и условия доставки
                    Row(
                      children: [
                        Text(
                          'Доставка: ',
                          style: PicPacTypography.metaInfo.copyWith(
                            fontSize: 11.5,
                            color: PicPacColors.textMuted,
                          ),
                        ),
                        const Text(
                          '1–2 дня',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: PicPacColors.textDark,
                          ),
                        ),
                      ],
                    ),
                    const Text(
                      'Бесплатное согласование макета',
                      style: TextStyle(
                        fontSize: 11.0,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF16A34A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10.0),
          const Divider(height: 1.0, color: PicPacColors.borderDefault),
          const SizedBox(height: 8.0),

          // Нижняя панель карточки: счетчик тиража и быстрая кнопка заказа
          Row(
            children: [
              // Степпер количества: [ - ] 1 [ + ]
              Container(
                decoration: BoxDecoration(
                  color: PicPacColors.surfaceGrey,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  children: [
                    _buildStepperButton(
                      icon: LucideIcons.minus,
                      onTap: () {
                        if (item.quantity > 1) {
                          ref.read(sessionProvider.notifier).updateQuantity(item.id, item.quantity - 1);
                        } else {
                          ref.read(sessionProvider.notifier).removeCartItem(item.id);
                        }
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0),
                      child: Text(
                        '${item.quantity}',
                        style: const TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w700,
                          color: PicPacColors.textDark,
                        ),
                      ),
                    ),
                    _buildStepperButton(
                      icon: LucideIcons.plus,
                      onTap: () {
                        ref.read(sessionProvider.notifier).updateQuantity(item.id, item.quantity + 1);
                      },
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Кнопка удаления
              IconButton(
                icon: const Icon(
                  LucideIcons.trash2,
                  size: 18.0,
                  color: PicPacColors.textMuted,
                ),
                onPressed: () {
                  ref.read(sessionProvider.notifier).removeCartItem(item.id);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepperButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 32.0,
        height: 32.0,
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 15.0,
          color: PicPacColors.textDark,
        ),
      ),
    );
  }

  Widget _buildCheckbox(bool isChecked) {
    return Container(
      width: 20.0,
      height: 20.0,
      decoration: BoxDecoration(
        color: isChecked ? PicPacColors.primaryCoral : Colors.white,
        borderRadius: BorderRadius.circular(5.0),
        border: Border.all(
          color: isChecked ? PicPacColors.primaryCoral : const Color(0xFFCBD5E1),
          width: 1.5,
        ),
      ),
      child: isChecked
          ? const Icon(
              LucideIcons.check,
              size: 14.0,
              color: Colors.white,
            )
          : null,
    );
  }

  Widget _buildSplitPaymentBanner(double totalCost) {
    final partCost = (totalCost / 4).toStringAsFixed(2).replaceAll('.', ',');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F3FF),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: const Color(0xFFDDD6FE)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: const Icon(
              LucideIcons.clover,
              size: 18.0,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$partCost руб. × 4 платежа',
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF5B21B6),
                  ),
                ),
                const SizedBox(height: 2.0),
                const Text(
                  'Оплата долями без комиссий и переплат',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF6D28D9),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _splitPaymentEnabled,
            activeThumbColor: const Color(0xFF8B5CF6),
            onChanged: (val) {
              setState(() {
                _splitPaymentEnabled = val;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomCheckoutBar(
    List<CartItem> selectedItems,
    double totalCost,
    int totalCount,
  ) {
    final formattedTotal = '${totalCost.toStringAsFixed(2).replaceAll('.', ',')} руб.';

    return Container(
      padding: const EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 10.0),
      decoration: BoxDecoration(
        color: PicPacColors.white,
        border: const Border(
          top: BorderSide(color: PicPacColors.borderDefault, width: 0.8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8.0,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        bottom: false,
        child: GestureDetector(
          onTap: () => _onCheckoutTap(selectedItems, totalCost),
          behavior: HitTestBehavior.opaque,
          child: Container(
            height: 48.0,
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF5252), Color(0xFFFF3366)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: PicPacColors.primaryCoral.withValues(alpha: 0.35),
                  blurRadius: 10.0,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Оформить заказ • $totalCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8.0),
                Text(
                  formattedTotal,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80.0,
              height: 80.0,
              decoration: BoxDecoration(
                color: PicPacColors.primaryCoralSoft,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  LucideIcons.shoppingBag,
                  size: 38.0,
                  color: PicPacColors.primaryCoral,
                ),
              ),
            ),
            const SizedBox(height: 18.0),
            Text(
              'Ваша корзина пуста',
              style: PicPacTypography.h2Section.copyWith(fontSize: 18.0),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Создайте альбом или выберите шаблон фотокниги, чтобы заполнить макет и заказать печать',
              textAlign: TextAlign.center,
              style: PicPacTypography.photoCaption.copyWith(fontSize: 13.5),
            ),
          ],
        ),
      ),
    );
  }
}
