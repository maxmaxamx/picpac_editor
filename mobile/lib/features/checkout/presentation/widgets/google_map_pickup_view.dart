import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/picpac_colors.dart';
import '../../../../core/theme/picpac_typography.dart';
import '../../domain/pickup_point.dart';

class GoogleMapPickupView extends StatefulWidget {
  final List<PickupPoint> points;
  final PickupPoint selectedPoint;
  final ValueChanged<PickupPoint> onPointSelected;
  final double height;

  const GoogleMapPickupView({
    super.key,
    required this.points,
    required this.selectedPoint,
    required this.onPointSelected,
    this.height = 165.0,
  });

  @override
  State<GoogleMapPickupView> createState() => _GoogleMapPickupViewState();
}

class _GoogleMapPickupViewState extends State<GoogleMapPickupView> {
  GoogleMapController? _mapController;

  bool get _isGoogleMapsSupported {
    // google_maps_flutter официально поддерживается на Android, iOS и Web.
    // В тестах виджетов (headless) platform views недоступны.
    if (kIsWeb) return true;
    if (WidgetsBinding.instance.runtimeType.toString().contains('TestWidgetsFlutterBinding')) {
      return false;
    }
    return Platform.isAndroid || Platform.isIOS;
  }

  @override
  void didUpdateWidget(covariant GoogleMapPickupView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedPoint.id != widget.selectedPoint.id && _mapController != null) {
      try {
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(widget.selectedPoint.latitude, widget.selectedPoint.longitude),
            13.5,
          ),
        ).catchError((_) {});
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _mapController = null;
    super.dispose();
  }

  Set<Marker> _buildMarkers() {
    return widget.points.map((point) {
      final isSelected = point.id == widget.selectedPoint.id;
      return Marker(
        markerId: MarkerId(point.id),
        position: LatLng(point.latitude, point.longitude),
        infoWindow: InfoWindow(
          title: point.name,
          snippet: point.address,
        ),
        icon: isSelected
            ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed)
            : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose),
        onTap: () {
          try {
            widget.onPointSelected(point);
          } catch (_) {}
        },
      );
    }).toSet();
  }

  @override
  Widget build(BuildContext context) {
    if (_isGoogleMapsSupported) {
      return SizedBox(
        height: widget.height,
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(widget.selectedPoint.latitude, widget.selectedPoint.longitude),
                zoom: 12.0,
              ),
              markers: _buildMarkers(),
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              compassEnabled: true,
              onMapCreated: (controller) {
                if (!mounted) return;
                _mapController = controller;
              },
            ),
            // Индикатор Google Maps и выбранного пункта
            _buildActivePointPill(),
          ],
        ),
      );
    }

    // Стилизованный fallback под Google Maps для тестов и неподдерживаемых платформ
    return SizedBox(
      height: widget.height,
      child: _buildFallbackGoogleMapView(),
    );
  }

  Widget _buildActivePointPill() {
    return Positioned(
      left: 10.0,
      right: 10.0,
      bottom: 8.0,
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 260.0),
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
          decoration: BoxDecoration(
            color: PicPacColors.white.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1F000000),
                blurRadius: 6.0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                LucideIcons.mapPin,
                size: 14.0,
                color: PicPacColors.primaryCoral,
              ),
              const SizedBox(width: 6.0),
              Flexible(
                child: Text(
                  widget.selectedPoint.name,
                  style: PicPacTypography.metaInfo.copyWith(
                    fontWeight: FontWeight.w700,
                    color: PicPacColors.textDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackGoogleMapView() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        return Stack(
          children: [
            // Карта
            GestureDetector(
              onTapUp: (details) {
                if (w <= 0 || h <= 0) return;
                final tapX = details.localPosition.dx / w;
                final tapY = details.localPosition.dy / h;

                PickupPoint? closest;
                double minDistance = double.infinity;

                for (final p in widget.points) {
                  final dx = p.mapX - tapX;
                  final dy = p.mapY - tapY;
                  final dist = dx * dx + dy * dy;
                  if (dist < minDistance) {
                    minDistance = dist;
                    closest = p;
                  }
                }

                if (closest != null && minDistance < 0.08) {
                  widget.onPointSelected(closest);
                }
              },
              child: CustomPaint(
                size: Size(w, h),
                painter: _GoogleMapStyledPainter(
                  points: widget.points,
                  selectedPointId: widget.selectedPoint.id,
                ),
              ),
            ),

            // Водяной знак Google (фирменный стиль Google Maps)
            Positioned(
              left: 10.0,
              top: 8.0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Google',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w700,
                        fontSize: 12.0,
                        letterSpacing: -0.3,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    const SizedBox(width: 3.0),
                    const Text(
                      'Maps',
                      style: TextStyle(
                        fontSize: 10.0,
                        fontWeight: FontWeight.w500,
                        color: PicPacColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Кнопки зума (+/-) в стиле Google Maps
            Positioned(
              right: 8.0,
              bottom: 8.0,
              child: Container(
                decoration: BoxDecoration(
                  color: PicPacColors.white,
                  borderRadius: BorderRadius.circular(4.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1F000000),
                      blurRadius: 4.0,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(6.0),
                      child: Icon(LucideIcons.plus, size: 14.0, color: PicPacColors.textDark),
                    ),
                    Container(height: 1.0, width: 22.0, color: PicPacColors.borderDefault),
                    const Padding(
                      padding: EdgeInsets.all(6.0),
                      child: Icon(LucideIcons.minus, size: 14.0, color: PicPacColors.textDark),
                    ),
                  ],
                ),
              ),
            ),

            _buildActivePointPill(),
          ],
        );
      },
    );
  }
}

class _GoogleMapStyledPainter extends CustomPainter {
  final List<PickupPoint> points;
  final String selectedPointId;

  _GoogleMapStyledPainter({
    required this.points,
    required this.selectedPointId,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Палитра картографии Google Maps:
    // Фон суши #E8ECE9
    final bgPaint = Paint()..color = const Color(0xFFF0EFE9);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Водные объекты #AADAFF (река Свислочь)
    final riverPaint = Paint()
      ..color = const Color(0xFFAADAFF)
      ..strokeWidth = 14.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final riverPath = Path()
      ..moveTo(size.width * 0.1, 0)
      ..cubicTo(
        size.width * 0.35, size.height * 0.35,
        size.width * 0.45, size.height * 0.65,
        size.width * 0.88, size.height,
      );
    canvas.drawPath(riverPath, riverPaint);

    // Зеленые зоны (парки) #C8E8C8
    final parkPaint = Paint()..color = const Color(0xFFCEECC8);
    canvas.drawCircle(Offset(size.width * 0.44, size.height * 0.28), 28.0, parkPaint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.68, size.height * 0.42, 60.0, 36.0),
        const Radius.circular(10.0),
      ),
      parkPaint,
    );

    // Автомагистрали #FAD99B (оранжево-желтые артерии Google)
    final highwayPaint = Paint()
      ..color = const Color(0xFFFBE8B3)
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke;

    final majorStreetPaint = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;

    // Проспект Победителей / Независимости
    canvas.drawLine(Offset(0, size.height * 0.55), Offset(size.width, size.height * 0.22), highwayPaint);
    canvas.drawLine(Offset(size.width * 0.18, size.height), Offset(size.width * 0.62, 0), highwayPaint);

    // Улицы
    canvas.drawLine(Offset(size.width * 0.3, 0), Offset(size.width * 0.3, size.height), majorStreetPaint);
    canvas.drawLine(Offset(size.width * 0.52, 0), Offset(size.width * 0.52, size.height), majorStreetPaint);
    canvas.drawLine(Offset(size.width * 0.74, 0), Offset(size.width * 0.74, size.height), majorStreetPaint);
    canvas.drawLine(Offset(0, size.height * 0.76), Offset(size.width, size.height * 0.76), majorStreetPaint);

    // Маркеры в стиле классических булавок Google Maps (Red Marker)
    for (final p in points) {
      final isSelected = p.id == selectedPointId;
      final px = p.mapX * size.width;
      final py = p.mapY * size.height;

      if (isSelected) {
        // Тень маркера
        final shadowPaint = Paint()..color = const Color(0x33000000);
        canvas.drawOval(Rect.fromCenter(center: Offset(px, py + 1.0), width: 14.0, height: 6.0), shadowPaint);

        // Булавка выбранного пункта
        final pinPaint = Paint()..color = const Color(0xFFEA4335); // Красный Google
        canvas.drawCircle(Offset(px, py - 9.0), 9.0, pinPaint);

        // Точка булавки
        final needlePath = Path()
          ..moveTo(px - 6.5, py - 6.0)
          ..lineTo(px, py)
          ..lineTo(px + 6.5, py - 6.0)
          ..close();
        canvas.drawPath(needlePath, pinPaint);

        // Белая внутренняя точка
        final innerPaint = Paint()..color = Colors.white;
        canvas.drawCircle(Offset(px, py - 9.0), 4.0, innerPaint);
      } else {
        // Невыбранные булавки (меньший размер)
        final pinPaint = Paint()..color = PicPacColors.primaryCoral.withValues(alpha: 0.85);
        canvas.drawCircle(Offset(px, py - 6.0), 6.5, pinPaint);

        final needlePath = Path()
          ..moveTo(px - 4.5, py - 4.0)
          ..lineTo(px, py)
          ..lineTo(px + 4.5, py - 4.0)
          ..close();
        canvas.drawPath(needlePath, pinPaint);

        final innerPaint = Paint()..color = Colors.white;
        canvas.drawCircle(Offset(px, py - 6.0), 2.5, innerPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GoogleMapStyledPainter oldDelegate) {
    return oldDelegate.selectedPointId != selectedPointId || oldDelegate.points != points;
  }
}
