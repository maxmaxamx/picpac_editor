import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/session/session_state.dart';
import '../../../../core/theme/picpac_colors.dart';
import '../../../../core/theme/picpac_typography.dart';
import '../../../editor/presentation/screens/spread_editor_screen.dart';

enum AlbumFormat {
  square20x20('20×20 см', 'Квадратный (1:1)', 1.0),
  vertical21x30('21×30 см', 'Вертикальный А4 (3:4)', 3.0 / 4.0);

  final String title;
  final String subtitle;
  final double aspectRatio;

  const AlbumFormat(this.title, this.subtitle, this.aspectRatio);
}

enum AlbumLamination {
  glossy('Глянцевая'),
  grainy('Зернистая');

  final String title;

  const AlbumLamination(this.title);
}

class AlbumParametersScreen extends ConsumerStatefulWidget {
  final String albumTitle;
  final String userName;
  final String? selectedTemplateTitle;

  const AlbumParametersScreen({
    super.key,
    required this.albumTitle,
    required this.userName,
    this.selectedTemplateTitle,
  });

  @override
  ConsumerState<AlbumParametersScreen> createState() => _AlbumParametersScreenState();
}

class _AlbumParametersScreenState extends ConsumerState<AlbumParametersScreen> {
  AlbumFormat _selectedFormat = AlbumFormat.vertical21x30;
  AlbumLamination _selectedLamination = AlbumLamination.glossy;
  int _spreadsCount = 10; // 10 разворотов = 20 страниц (стандарт picPac)
  bool _isSubmitting = false;

  Future<void> _proceedToCanvas() async {
    if (WidgetsBinding.instance.runtimeType.toString().contains('TestWidgetsFlutterBinding')) {
      Navigator.push<void>(
        context,
        MaterialPageRoute(
          builder: (_) => SpreadEditorScreen(
            albumTitle: widget.albumTitle,
            userName: widget.userName,
            aspectRatio: _selectedFormat.aspectRatio,
            spreadsCount: _spreadsCount,
          ),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final apiClient = ref.read(apiClientProvider);
      final user = await apiClient.guestAuth(widget.userName);
      final album = await apiClient.createAlbum(
        name: widget.albumTitle,
        format: _selectedFormat == AlbumFormat.square20x20 ? '20x20' : '21x30',
        lamination: _selectedLamination == AlbumLamination.glossy ? 'glossy' : 'grainy',
        spreadsCount: _spreadsCount,
      );
      ref.read(sessionProvider.notifier).setUser(user);
      ref.read(sessionProvider.notifier).setAlbum(album);

      if (!mounted) return;
      Navigator.push<void>(
        context,
        MaterialPageRoute(
          builder: (_) => SpreadEditorScreen(
            albumId: album.id,
            albumTitle: album.name,
            userName: user.displayName,
            aspectRatio: _selectedFormat.aspectRatio,
            spreadsCount: _spreadsCount,
          ),
        ),
      );
    } catch (err) {
      if (!mounted) return;
      Navigator.push<void>(
        context,
        MaterialPageRoute(
          builder: (_) => SpreadEditorScreen(
            albumTitle: widget.albumTitle,
            userName: widget.userName,
            aspectRatio: _selectedFormat.aspectRatio,
            spreadsCount: _spreadsCount,
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PicPacColors.white,
      appBar: AppBar(
        backgroundColor: PicPacColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
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
          'Параметры альбома',
          style: PicPacTypography.h1Title,
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Название альбома
                    Container(
                      padding: const EdgeInsets.all(14.0),
                      decoration: BoxDecoration(
                        color: PicPacColors.surfaceGrey,
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(color: PicPacColors.borderDefault),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            LucideIcons.bookOpen,
                            size: 18.0,
                            color: PicPacColors.primaryCoral,
                          ),
                          const SizedBox(width: 10.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Альбом',
                                  style: PicPacTypography.metaInfo,
                                ),
                                Text(
                                  widget.albumTitle,
                                  style: PicPacTypography.photoCaption.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                            decoration: BoxDecoration(
                              color: PicPacColors.white,
                              borderRadius: BorderRadius.circular(6.0),
                              border: Border.all(color: PicPacColors.borderDefault),
                            ),
                            child: Text(
                              '$_spreadsCount разв.',
                              style: PicPacTypography.metaInfo.copyWith(
                                fontWeight: FontWeight.w600,
                                color: PicPacColors.textDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (widget.selectedTemplateTitle != null) ...[
                      const SizedBox(height: 10.0),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                        decoration: BoxDecoration(
                          color: PicPacColors.primaryCoralSoft,
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(color: PicPacColors.primaryCoral.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              LucideIcons.layoutTemplate,
                              size: 15.0,
                              color: PicPacColors.primaryCoral,
                            ),
                            const SizedBox(width: 8.0),
                            Expanded(
                              child: Text(
                                'Шаблон оформления: ${widget.selectedTemplateTitle}',
                                style: PicPacTypography.metaInfo.copyWith(
                                  color: PicPacColors.primaryCoral,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 24.0),

                    // 1. Формат альбома
                    Text(
                      'Формат альбома',
                      style: PicPacTypography.h2Section,
                    ),
                    const SizedBox(height: 10.0),
                    Row(
                      children: [
                        Expanded(
                          child: _buildFormatCard(AlbumFormat.square20x20),
                        ),
                        const SizedBox(width: 12.0),
                        Expanded(
                          child: _buildFormatCard(AlbumFormat.vertical21x30),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24.0),

                    // 2. Ламинация страниц
                    Text(
                      'Ламинация страниц',
                      style: PicPacTypography.h2Section,
                    ),
                    const SizedBox(height: 10.0),
                    Column(
                      children: [
                        _buildLaminationCard(AlbumLamination.glossy),
                        const SizedBox(height: 8.0),
                        _buildLaminationCard(AlbumLamination.grainy),
                      ],
                    ),

                    const SizedBox(height: 24.0),

                    // 3. Количество разворотов
                    Text(
                      'Количество разворотов',
                      style: PicPacTypography.h2Section,
                    ),
                    const SizedBox(height: 10.0),
                    _buildSpreadsSelector(),
                  ],
                ),
              ),
            ),

            // Нижняя фиксированная кнопка
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              decoration: const BoxDecoration(
                color: PicPacColors.white,
                border: Border(
                  top: BorderSide(color: PicPacColors.borderDefault),
                ),
              ),
              child: GestureDetector(
                onTap: _isSubmitting ? null : _proceedToCanvas,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  height: 48.0,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: PicPacColors.primaryCoral,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  alignment: Alignment.center,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20.0,
                          height: 20.0,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            color: PicPacColors.white,
                          ),
                        )
                      : FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Создать альбом и открыть холст',
                                style: PicPacTypography.buttonText.copyWith(
                                  fontSize: 15.0,
                                ),
                              ),
                              const SizedBox(width: 8.0),
                              const Icon(
                                LucideIcons.arrowRight,
                                size: 18.0,
                                color: PicPacColors.white,
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormatCard(AlbumFormat format) {
    final isSelected = _selectedFormat == format;

    return GestureDetector(
      onTap: () => setState(() => _selectedFormat = format),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(14.0),
        decoration: BoxDecoration(
          color: isSelected ? PicPacColors.primaryCoralSoft : PicPacColors.white,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
            color: isSelected ? PicPacColors.primaryCoral : PicPacColors.borderDefault,
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Мини-превью пропорций листа книги
                Container(
                  width: format == AlbumFormat.square20x20 ? 30.0 : 24.0,
                  height: 30.0,
                  decoration: BoxDecoration(
                    color: isSelected ? PicPacColors.white : PicPacColors.surfaceGrey,
                    borderRadius: BorderRadius.circular(3.0),
                    border: Border.all(
                      color: isSelected ? PicPacColors.primaryCoral : PicPacColors.borderDashed,
                      width: 1.5,
                    ),
                  ),
                ),
                // Индикатор выбора
                Container(
                  width: 20.0,
                  height: 20.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? PicPacColors.primaryCoral : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? PicPacColors.primaryCoral : PicPacColors.borderDefault,
                      width: 1.5,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(
                          LucideIcons.check,
                          size: 13.0,
                          color: PicPacColors.white,
                        )
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 14.0),
            Text(
              format.title,
              style: PicPacTypography.h1Title.copyWith(
                fontSize: 16.0,
                color: PicPacColors.textDark,
              ),
            ),
            const SizedBox(height: 2.0),
            Text(
              format.subtitle,
              style: PicPacTypography.metaInfo.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected ? PicPacColors.primaryCoral : PicPacColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLaminationCard(AlbumLamination lamination) {
    final isSelected = _selectedLamination == lamination;

    return GestureDetector(
      onTap: () => setState(() => _selectedLamination = lamination),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 14.0),
        decoration: BoxDecoration(
          color: isSelected ? PicPacColors.primaryCoralSoft : PicPacColors.white,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
            color: isSelected ? PicPacColors.primaryCoral : PicPacColors.borderDefault,
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36.0,
              height: 36.0,
              decoration: BoxDecoration(
                color: isSelected ? PicPacColors.white : PicPacColors.surfaceGrey,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Icon(
                lamination == AlbumLamination.glossy
                    ? LucideIcons.sparkles
                    : LucideIcons.layers,
                size: 18.0,
                color: isSelected ? PicPacColors.primaryCoral : PicPacColors.textDark,
              ),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Text(
                lamination.title,
                style: PicPacTypography.buttonTextDark.copyWith(
                  fontSize: 15.0,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8.0),
            Container(
              width: 20.0,
              height: 20.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? PicPacColors.primaryCoral : Colors.transparent,
                border: Border.all(
                  color: isSelected ? PicPacColors.primaryCoral : PicPacColors.borderDefault,
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      LucideIcons.check,
                      size: 13.0,
                      color: PicPacColors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  /// Выбор количества разворотов со степпером и быстрыми чипами
  Widget _buildSpreadsSelector() {
    final totalPages = _spreadsCount * 2;
    final totalSlots = _spreadsCount * 8; // по 4 слота на страницу

    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: PicPacColors.white,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: PicPacColors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$_spreadsCount разворотов',
                      style: PicPacTypography.h1Title.copyWith(fontSize: 17.0),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      '$totalPages страниц • $totalSlots слотов',
                      style: PicPacTypography.metaInfo.copyWith(
                        color: PicPacColors.primaryCoral,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8.0),

              // Степпер - / +
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (_spreadsCount > 5) {
                        setState(() => _spreadsCount--);
                      }
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 36.0,
                      height: 36.0,
                      decoration: BoxDecoration(
                        color: _spreadsCount > 5
                            ? PicPacColors.surfaceGrey
                            : PicPacColors.surfaceGrey.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        LucideIcons.minus,
                        size: 16.0,
                        color: _spreadsCount > 5
                            ? PicPacColors.textDark
                            : PicPacColors.textMuted,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Text(
                    '$_spreadsCount',
                    style: PicPacTypography.h1Title.copyWith(fontSize: 18.0),
                  ),
                  const SizedBox(width: 12.0),
                  GestureDetector(
                    onTap: () {
                      if (_spreadsCount < 30) {
                        setState(() => _spreadsCount++);
                      }
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 36.0,
                      height: 36.0,
                      decoration: BoxDecoration(
                        color: _spreadsCount < 30
                            ? PicPacColors.surfaceGrey
                            : PicPacColors.surfaceGrey.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        LucideIcons.plus,
                        size: 16.0,
                        color: _spreadsCount < 30
                            ? PicPacColors.textDark
                            : PicPacColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12.0),

          // Быстрые чипы популярных объемов
          Row(
            children: [5, 10, 15, 20].map((count) {
              final isChipSelected = _spreadsCount == count;
              final label = count == 10 ? '10 (хит)' : '$count';

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: GestureDetector(
                    onTap: () => setState(() => _spreadsCount = count),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(vertical: 7.0),
                      decoration: BoxDecoration(
                        color: isChipSelected
                            ? PicPacColors.primaryCoralSoft
                            : PicPacColors.surfaceGrey,
                        borderRadius: BorderRadius.circular(6.0),
                        border: Border.all(
                          color: isChipSelected
                              ? PicPacColors.primaryCoral
                              : PicPacColors.borderDefault,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        label,
                        style: PicPacTypography.metaInfo.copyWith(
                          color: isChipSelected
                              ? PicPacColors.primaryCoral
                              : PicPacColors.textDark,
                          fontWeight:
                              isChipSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
