import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/picpac_colors.dart';
import '../../../../core/theme/picpac_typography.dart';
import '../../domain/pickup_point.dart';

class PickupPointsSheet extends StatefulWidget {
  final PickupPoint? initialSelectedPoint;
  final ValueChanged<PickupPoint> onPointSelected;

  const PickupPointsSheet({
    super.key,
    this.initialSelectedPoint,
    required this.onPointSelected,
  });

  @override
  State<PickupPointsSheet> createState() => _PickupPointsSheetState();
}

class _PickupPointsSheetState extends State<PickupPointsSheet> {
  late PickupPoint _selectedPoint;
  String _selectedProviderFilter = 'Все';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<PickupPoint> _allPoints = PickupPoint.defaultPoints;

  @override
  void initState() {
    super.initState();
    _selectedPoint = widget.initialSelectedPoint ?? _allPoints.first;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<PickupPoint> get _filteredPoints {
    return _allPoints.where((p) {
      final matchesProvider = _selectedProviderFilter == 'Все' ||
          p.provider.toLowerCase() == _selectedProviderFilter.toLowerCase();
      final matchesQuery = _searchQuery.isEmpty ||
          p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.address.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesProvider && matchesQuery;
    }).toList();
  }

  void _onMapTap(Offset localPosition, Size mapSize) {
    if (mapSize.width <= 0 || mapSize.height <= 0) return;

    final tapX = localPosition.dx / mapSize.width;
    final tapY = localPosition.dy / mapSize.height;

    PickupPoint? closest;
    double minDistance = double.infinity;

    for (final p in _filteredPoints) {
      final dx = p.mapX - tapX;
      final dy = p.mapY - tapY;
      final dist = dx * dx + dy * dy;
      if (dist < minDistance) {
        minDistance = dist;
        closest = p;
      }
    }

    if (closest != null && minDistance < 0.08) {
      setState(() {
        _selectedPoint = closest!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.55,
      maxChildSize: 0.95,
      expand: false,
      builder: (sheetContext, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: PicPacColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
          ),
          child: Column(
            children: [
              // Верхний хэндл и заголовок
              Center(
                child: Container(
                  width: 36.0,
                  height: 4.0,
                  margin: const EdgeInsets.symmetric(vertical: 12.0),
                  decoration: BoxDecoration(
                    color: PicPacColors.borderDefault,
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Пункты выдачи picPac',
                        style: PicPacTypography.h1Title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: const EdgeInsets.all(6.0),
                        decoration: BoxDecoration(
                          color: PicPacColors.surfaceGrey,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: const Icon(
                          LucideIcons.x,
                          size: 18.0,
                          color: PicPacColors.textDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12.0),

              // Поисковая строка
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  height: 40.0,
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  decoration: BoxDecoration(
                    color: PicPacColors.surfaceGrey,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: PicPacColors.borderDefault),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        LucideIcons.search,
                        size: 16.0,
                        color: PicPacColors.textMuted,
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) => setState(() => _searchQuery = val.trim()),
                          style: PicPacTypography.photoCaption,
                          decoration: const InputDecoration(
                            hintText: 'Поиск по улице или названию...',
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      if (_searchQuery.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                          child: const Icon(LucideIcons.xCircle, size: 16.0, color: PicPacColors.textMuted),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10.0),

              // Фильтры категорий
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: ['Все', 'picPac', 'Европочта', 'Белпочта'].map((cat) {
                    final isSelected = _selectedProviderFilter == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedProviderFilter = cat),
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                          decoration: BoxDecoration(
                            color: isSelected ? PicPacColors.primaryCoral : PicPacColors.surfaceGrey,
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: Text(
                            cat,
                            style: TextStyle(
                              color: isSelected ? PicPacColors.white : PicPacColors.textDark,
                              fontSize: 12.5,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 12.0),

              // МИНИ-КАРТА (Интерактивная векторная карта Минска с маркерами)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: LayoutBuilder(
                    builder: (context, mapConstraints) {
                      final mapWidth = mapConstraints.maxWidth;
                      const mapHeight = 150.0;

                      return GestureDetector(
                        onTapUp: (details) => _onMapTap(details.localPosition, Size(mapWidth, mapHeight)),
                        child: SizedBox(
                          width: mapWidth,
                          height: mapHeight,
                          child: Stack(
                            children: [
                              CustomPaint(
                                size: Size(mapWidth, mapHeight),
                                painter: _MiniMapPainter(
                                  points: _filteredPoints,
                                  selectedPointId: _selectedPoint.id,
                                ),
                              ),
                              // Плашка выбранного пункта на карте
                              Positioned(
                                left: 8.0,
                                bottom: 8.0,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                  decoration: BoxDecoration(
                                    color: PicPacColors.white.withValues(alpha: 0.94),
                                    borderRadius: BorderRadius.circular(6.0),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x1F000000),
                                        blurRadius: 4.0,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        LucideIcons.mapPin,
                                        size: 13.0,
                                        color: PicPacColors.primaryCoral,
                                      ),
                                      const SizedBox(width: 4.0),
                                      Text(
                                        _selectedPoint.name,
                                        style: PicPacTypography.metaInfo.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: PicPacColors.textDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 12.0),

              // Список пунктов выдачи
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                  itemCount: _filteredPoints.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8.0),
                  itemBuilder: (context, index) {
                    final point = _filteredPoints[index];
                    final isSelected = point.id == _selectedPoint.id;

                    return GestureDetector(
                      onTap: () => setState(() => _selectedPoint = point),
                      behavior: HitTestBehavior.opaque,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: isSelected ? PicPacColors.primaryCoralSoft : PicPacColors.surfaceGrey,
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(
                            color: isSelected ? PicPacColors.primaryCoral : PicPacColors.borderDefault,
                            width: isSelected ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 2.0, right: 10.0),
                              child: Container(
                                width: 20.0,
                                height: 20.0,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected ? PicPacColors.primaryCoral : PicPacColors.white,
                                  border: Border.all(
                                    color: isSelected ? PicPacColors.primaryCoral : PicPacColors.borderDefault,
                                    width: 1.5,
                                  ),
                                ),
                                child: isSelected
                                    ? const Icon(LucideIcons.check, size: 12.0, color: PicPacColors.white)
                                    : null,
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          point.name,
                                          style: PicPacTypography.buttonTextDark.copyWith(
                                            color: isSelected ? PicPacColors.primaryCoral : PicPacColors.textDark,
                                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                                        decoration: BoxDecoration(
                                          color: isSelected ? PicPacColors.white : PicPacColors.borderDefault,
                                          borderRadius: BorderRadius.circular(4.0),
                                        ),
                                        child: Text(
                                          point.distance,
                                          style: const TextStyle(
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.w600,
                                            color: PicPacColors.textDark,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3.0),
                                  Text(
                                    point.address,
                                    style: PicPacTypography.metaInfo.copyWith(color: PicPacColors.textDark),
                                  ),
                                  const SizedBox(height: 2.0),
                                  Row(
                                    children: [
                                      const Icon(LucideIcons.clock, size: 11.0, color: PicPacColors.textMuted),
                                      const SizedBox(width: 4.0),
                                      Expanded(
                                        child: Text(
                                          point.workingHours,
                                          style: PicPacTypography.metaInfo,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Кнопка подтверждения выбора
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: const BoxDecoration(
                  color: PicPacColors.white,
                  border: Border(top: BorderSide(color: PicPacColors.borderDefault)),
                ),
                child: GestureDetector(
                  onTap: () {
                    widget.onPointSelected(_selectedPoint);
                    Navigator.pop(context);
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    height: 48.0,
                    decoration: BoxDecoration(
                      color: PicPacColors.primaryCoral,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Выбрать этот пункт',
                      style: PicPacTypography.buttonText,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Красивый векторный отрисовщик мини-карты
class _MiniMapPainter extends CustomPainter {
  final List<PickupPoint> points;
  final String selectedPointId;

  _MiniMapPainter({
    required this.points,
    required this.selectedPointId,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Фон карты (светло-серый)
    final bgPaint = Paint()..color = const Color(0xFFF1F5F9);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // 2. Зеленые зоны (парки)
    final parkPaint = Paint()..color = const Color(0xFFDCFCE7);
    canvas.drawCircle(Offset(size.width * 0.45, size.height * 0.28), 24.0, parkPaint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.65, size.height * 0.45, 50.0, 32.0),
        const Radius.circular(8.0),
      ),
      parkPaint,
    );

    // 3. Водный путь (Река Свислочь)
    final riverPaint = Paint()
      ..color = const Color(0xFFBAE6FD)
      ..strokeWidth = 10.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final riverPath = Path()
      ..moveTo(size.width * 0.15, 0)
      ..cubicTo(
        size.width * 0.35, size.height * 0.3,
        size.width * 0.45, size.height * 0.6,
        size.width * 0.85, size.height,
      );
    canvas.drawPath(riverPath, riverPaint);

    // 4. Сетка дорог и проспектов
    final roadPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke;

    final majorRoadPaint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 5.0
      ..style = PaintingStyle.stroke;

    // Главный проспект (Победителей / Независимости)
    canvas.drawLine(
      Offset(0, size.height * 0.55),
      Offset(size.width, size.height * 0.25),
      majorRoadPaint,
    );
    // Вторая диагональ
    canvas.drawLine(
      Offset(size.width * 0.2, size.height),
      Offset(size.width * 0.65, 0),
      majorRoadPaint,
    );

    // Поперечные улицы
    canvas.drawLine(Offset(size.width * 0.28, 0), Offset(size.width * 0.28, size.height), roadPaint);
    canvas.drawLine(Offset(size.width * 0.52, 0), Offset(size.width * 0.52, size.height), roadPaint);
    canvas.drawLine(Offset(size.width * 0.76, 0), Offset(size.width * 0.76, size.height), roadPaint);
    canvas.drawLine(Offset(0, size.height * 0.75), Offset(size.width, size.height * 0.75), roadPaint);

    // 5. Маркеры пунктов выдачи
    for (final p in points) {
      final isSelected = p.id == selectedPointId;
      final px = p.mapX * size.width;
      final py = p.mapY * size.height;

      if (isSelected) {
        // Пульсирующий ореол для выбранного пункта
        final auraPaint = Paint()..color = PicPacColors.primaryCoral.withValues(alpha: 0.25);
        canvas.drawCircle(Offset(px, py), 15.0, auraPaint);

        // Основной яркий маркер
        final pinPaint = Paint()..color = PicPacColors.primaryCoral;
        canvas.drawCircle(Offset(px, py), 7.0, pinPaint);

        final pinInner = Paint()..color = PicPacColors.white;
        canvas.drawCircle(Offset(px, py), 3.0, pinInner);
      } else {
        // Обычные маркеры
        final pinBorder = Paint()
          ..color = PicPacColors.primaryCoral
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke;
        final pinFill = Paint()..color = PicPacColors.white;

        canvas.drawCircle(Offset(px, py), 5.5, pinFill);
        canvas.drawCircle(Offset(px, py), 5.5, pinBorder);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MiniMapPainter oldDelegate) {
    return oldDelegate.selectedPointId != selectedPointId || oldDelegate.points != points;
  }
}
