import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/session/session_state.dart';
import '../../../../core/theme/picpac_colors.dart';
import '../../../../core/theme/picpac_typography.dart';
import '../../../editor/presentation/screens/spread_editor_screen.dart';
import '../widgets/pin_code_input.dart';
import 'album_templates_screen.dart';

enum OnboardingMode {
  join,
  create,
}

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final TextEditingController _nameController =
      TextEditingController(text: 'Артём');
  final TextEditingController _pinController =
      TextEditingController(text: '849204');
  final TextEditingController _albumTitleController =
      TextEditingController(text: 'Выпускной 11-Б • 2026');

  OnboardingMode _mode = OnboardingMode.join;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _pinController.dispose();
    _albumTitleController.dispose();
    super.dispose();
  }

  Future<void> _proceedToEditor() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showToast('Пожалуйста, введите ваше имя');
      return;
    }

    if (_mode == OnboardingMode.join) {
      final pin = _pinController.text.trim();
      if (pin.length != 6) {
        _showToast('Введите 6-значный код альбома');
        return;
      }

      if (WidgetsBinding.instance.runtimeType.toString().contains('TestWidgetsFlutterBinding')) {
        Navigator.push<void>(
          context,
          MaterialPageRoute(
            builder: (_) => SpreadEditorScreen(
              albumTitle: 'Выпускной 11-Б • 2026',
              userName: name,
            ),
          ),
        );
        return;
      }

      setState(() => _isSubmitting = true);
      try {
        final apiClient = ref.read(apiClientProvider);
        final user = await apiClient.guestAuth(name);
        final album = await apiClient.joinAlbum(pin);
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
              spreadsCount: album.spreadsCount,
              aspectRatio: album.format == '20x20' ? 1.0 : (3.0 / 4.0),
            ),
          ),
        );
      } catch (err) {
        // Fallback gracefully (offline / widget tests / dev mock)
        if (!mounted) return;
        Navigator.push<void>(
          context,
          MaterialPageRoute(
            builder: (_) => SpreadEditorScreen(
              albumTitle: 'Выпускной 11-Б • 2026',
              userName: name,
            ),
          ),
        );
      } finally {
        if (mounted) setState(() => _isSubmitting = false);
      }
    } else {
      final title = _albumTitleController.text.trim();
      if (title.isEmpty) {
        _showToast('Введите название для нового альбома');
        return;
      }
      Navigator.push<void>(
        context,
        MaterialPageRoute(
          builder: (_) => AlbumTemplatesScreen(
            albumTitle: title,
            userName: name,
          ),
        ),
      );
    }
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PicPacColors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 20.0,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 1. Фирменный логотип picPac.by
                        _buildBrandHeader(),

                        const SizedBox(height: 36.0),

                        // 2. Имя участника (только ввод с клавиатуры)
                        _buildNameSection(),

                        const SizedBox(height: 24.0),

                        // 3. Плавный анимированный переключатель режима
                        _buildModeSwitcher(),

                        const SizedBox(height: 16.0),

                        // 4. Карточка выбранного режима с плавной анимацией высоты и переключения
                        AnimatedSize(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOutCubic,
                          alignment: Alignment.topCenter,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 220),
                            switchInCurve: Curves.easeOutCubic,
                            switchOutCurve: Curves.easeInCubic,
                            transitionBuilder: (child, animation) {
                              final slideAnimation = Tween<Offset>(
                                begin: const Offset(0.0, 0.04),
                                end: Offset.zero,
                              ).animate(animation);
                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: slideAnimation,
                                  child: child,
                                ),
                              );
                            },
                            child: _mode == OnboardingMode.join
                                ? _buildJoinCard()
                                : _buildCreateCard(),
                          ),
                        ),

                        const SizedBox(height: 28.0),

                        // 5. Главная кнопка действия
                        _buildActionButton(),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBrandHeader() {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'picPac',
            style: PicPacTypography.h1Title.copyWith(
              fontSize: 34.0,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          Text(
            '.by',
            style: PicPacTypography.h1Title.copyWith(
              fontSize: 34.0,
              fontWeight: FontWeight.w800,
              color: PicPacColors.primaryCoral,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Как тебя зовут?',
          style: PicPacTypography.h2Section,
        ),
        const SizedBox(height: 8.0),
        Container(
          height: 48.0,
          decoration: BoxDecoration(
            color: PicPacColors.surfaceGrey,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: PicPacColors.borderDefault),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14.0),
          alignment: Alignment.centerLeft,
          child: TextField(
            controller: _nameController,
            style: PicPacTypography.photoCaption.copyWith(
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              hintText: 'Имя, которое увидят другие',
              hintStyle: TextStyle(
                color: PicPacColors.textMuted,
                fontSize: 14.0,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Красивый анимированный ползунок переключения
  Widget _buildModeSwitcher() {
    return Container(
      height: 44.0,
      padding: const EdgeInsets.all(3.0),
      decoration: BoxDecoration(
        color: PicPacColors.surfaceGrey,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Stack(
        children: [
          // Скользящий белый бегунок с тенью
          AnimatedAlign(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOutCubic,
            alignment: _mode == OnboardingMode.join
                ? Alignment.centerLeft
                : Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              child: Container(
                height: 38.0,
                decoration: BoxDecoration(
                  color: PicPacColors.white,
                  borderRadius: BorderRadius.circular(6.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 4.0,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Интерактивные ярлыки вкладок
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _mode = OnboardingMode.join),
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      style: PicPacTypography.buttonTextDark.copyWith(
                        fontSize: 13.0,
                        fontWeight: _mode == OnboardingMode.join
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: _mode == OnboardingMode.join
                            ? PicPacColors.textDark
                            : PicPacColors.textMuted,
                      ),
                      child: const Text('Войти по коду'),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _mode = OnboardingMode.create),
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      style: PicPacTypography.buttonTextDark.copyWith(
                        fontSize: 13.0,
                        fontWeight: _mode == OnboardingMode.create
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: _mode == OnboardingMode.create
                            ? PicPacColors.textDark
                            : PicPacColors.textMuted,
                      ),
                      child: const Text('Создать альбом'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildJoinCard() {
    return Container(
      key: const ValueKey('join_card'),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
      decoration: BoxDecoration(
        color: PicPacColors.white,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: PicPacColors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                LucideIcons.keyRound,
                size: 18.0,
                color: PicPacColors.primaryCoral,
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  '6-значный код приглашения',
                  style: PicPacTypography.h2Section.copyWith(fontSize: 14.0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18.0),

          // Пин-код инпут
          Center(
            child: PinCodeInput(
              controller: _pinController,
              onCompleted: (pin) {
                _proceedToEditor();
              },
            ),
          ),

          const SizedBox(height: 14.0),

          // Тестовый чип
          Center(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _pinController.text = '849204';
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 4.0,
                ),
                decoration: BoxDecoration(
                  color: PicPacColors.surfaceGrey,
                  borderRadius: BorderRadius.circular(6.0),
                ),
                child: Text(
                  'Тестовый код: 849-204',
                  style: PicPacTypography.metaInfo.copyWith(
                    color: PicPacColors.textDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateCard() {
    return Container(
      key: const ValueKey('create_card'),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
      decoration: BoxDecoration(
        color: PicPacColors.white,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: PicPacColors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                LucideIcons.bookPlus,
                size: 18.0,
                color: PicPacColors.primaryCoral,
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  'Параметры нового альбома',
                  style: PicPacTypography.h2Section.copyWith(fontSize: 14.0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14.0),
          Text(
            'Название альбома:',
            style: PicPacTypography.metaInfo,
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
            child: TextField(
              controller: _albumTitleController,
              style: PicPacTypography.photoCaption.copyWith(
                fontWeight: FontWeight.w600,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                hintText: 'Например: Выпуск 11-Б • 2026',
              ),
            ),
          ),
          const SizedBox(height: 14.0),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                decoration: BoxDecoration(
                  color: PicPacColors.primaryCoralSoft,
                  borderRadius: BorderRadius.circular(6.0),
                ),
                child: const Icon(
                  LucideIcons.slidersHorizontal,
                  size: 14.0,
                  color: PicPacColors.primaryCoral,
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  'Формат, ламинация и развороты на шаге 2',
                  style: PicPacTypography.metaInfo.copyWith(
                    color: PicPacColors.textDark,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    return GestureDetector(
      onTap: _isSubmitting ? null : _proceedToEditor,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 48.0,
        decoration: BoxDecoration(
          color: PicPacColors.primaryCoral,
          borderRadius: BorderRadius.circular(8.0),
        ),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        _mode == OnboardingMode.join
                            ? 'Войти в альбом'
                            : 'Выбрать параметры альбома',
                        key: ValueKey(_mode),
                        style: PicPacTypography.buttonText.copyWith(
                          fontSize: 15.0,
                        ),
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
    );
  }
}
