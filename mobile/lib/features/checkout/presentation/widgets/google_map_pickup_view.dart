import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/picpac_colors.dart';
import '../../../../core/theme/picpac_typography.dart';
import '../../domain/pickup_point.dart';

/// Интерактивная карта пунктов выдачи с реальными тайлами города, дорогами, домами и рекой
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
    this.height = 175.0,
  });

  @override
  State<GoogleMapPickupView> createState() => _GoogleMapPickupViewState();
}

class _GoogleMapPickupViewState extends State<GoogleMapPickupView> {
  final MapController _mapController = MapController();

  @override
  void didUpdateWidget(covariant GoogleMapPickupView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedPoint.id != widget.selectedPoint.id) {
      try {
        _mapController.move(
          ll.LatLng(widget.selectedPoint.latitude, widget.selectedPoint.longitude),
          13.5,
        );
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _zoomIn() {
    try {
      final currentZoom = _mapController.camera.zoom;
      _mapController.move(_mapController.camera.center, (currentZoom + 1).clamp(10.0, 18.0));
    } catch (_) {}
  }

  void _zoomOut() {
    try {
      final currentZoom = _mapController.camera.zoom;
      _mapController.move(_mapController.camera.center, (currentZoom - 1).clamp(10.0, 18.0));
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: ll.LatLng(widget.selectedPoint.latitude, widget.selectedPoint.longitude),
              initialZoom: 13.0,
              minZoom: 10.0,
              maxZoom: 18.0,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'by.picpac.editor',
                tileDisplay: const TileDisplay.fadeIn(),
              ),
              MarkerLayer(
                markers: widget.points.map((point) {
                  final isSelected = point.id == widget.selectedPoint.id;
                  return Marker(
                    point: ll.LatLng(point.latitude, point.longitude),
                    width: isSelected ? 38.0 : 30.0,
                    height: isSelected ? 38.0 : 30.0,
                    alignment: Alignment.topCenter,
                    child: GestureDetector(
                      onTap: () => widget.onPointSelected(point),
                      behavior: HitTestBehavior.opaque,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        decoration: BoxDecoration(
                          color: isSelected ? PicPacColors.primaryCoral : PicPacColors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? PicPacColors.white : PicPacColors.primaryCoral,
                            width: isSelected ? 2.5 : 1.8,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isSelected
                                  ? PicPacColors.primaryCoral.withValues(alpha: 0.4)
                                  : const Color(0x26000000),
                              blurRadius: isSelected ? 8.0 : 4.0,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            LucideIcons.mapPin,
                            size: isSelected ? 18.0 : 14.0,
                            color: isSelected ? PicPacColors.white : PicPacColors.primaryCoral,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          // Водяной знак карты
          Positioned(
            left: 10.0,
            top: 8.0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 3.5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(5.0),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 3.0,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    LucideIcons.mapPin,
                    size: 11.0,
                    color: PicPacColors.primaryCoral,
                  ),
                  const SizedBox(width: 4.0),
                  Text(
                    'Карта Минска',
                    style: PicPacTypography.metaInfo.copyWith(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: PicPacColors.textDark,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Кнопки зума (+/-)
          Positioned(
            right: 8.0,
            top: 8.0,
            child: Container(
              decoration: BoxDecoration(
                color: PicPacColors.white,
                borderRadius: BorderRadius.circular(6.0),
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
                  GestureDetector(
                    onTap: _zoomIn,
                    behavior: HitTestBehavior.opaque,
                    child: const Padding(
                      padding: EdgeInsets.all(6.0),
                      child: Icon(LucideIcons.plus, size: 14.0, color: PicPacColors.textDark),
                    ),
                  ),
                  Container(height: 1.0, width: 22.0, color: PicPacColors.borderDefault),
                  GestureDetector(
                    onTap: _zoomOut,
                    behavior: HitTestBehavior.opaque,
                    child: const Padding(
                      padding: EdgeInsets.all(6.0),
                      child: Icon(LucideIcons.minus, size: 14.0, color: PicPacColors.textDark),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Индикатор выбранного пункта внизу карты
          _buildActivePointPill(),
        ],
      ),
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
          constraints: const BoxConstraints(maxWidth: 270.0),
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
}
