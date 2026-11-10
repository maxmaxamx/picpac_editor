import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/picpac_colors.dart';

class PicPacImage extends StatelessWidget {
  final String? imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const PicPacImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final rawUrl = imageUrl?.trim() ?? '';

    Widget imageContent;

    if (rawUrl.isEmpty) {
      imageContent = _buildPlaceholder();
    } else if (rawUrl.startsWith('http://') || rawUrl.startsWith('https://')) {
      imageContent = CachedNetworkImage(
        imageUrl: rawUrl,
        fit: fit,
        width: width,
        height: height,
        placeholder: (context, url) => Container(
          width: width,
          height: height,
          color: PicPacColors.surfaceGrey,
        ),
        errorWidget: (context, url, error) => _buildPlaceholder(),
      );
    } else if (!kIsWeb && (rawUrl.startsWith('/') || rawUrl.startsWith('file://'))) {
      final cleanPath = rawUrl.startsWith('file://') ? rawUrl.replaceFirst('file://', '') : rawUrl;
      final file = File(cleanPath);

      if (file.existsSync()) {
        imageContent = Image.file(
          file,
          fit: fit,
          width: width,
          height: height,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
        );
      } else {
        imageContent = _buildPlaceholder();
      }
    } else {
      // Пытаемся загрузить через Image.network на случай локального dev сервера без схемы
      imageContent = Image.network(
        rawUrl,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageContent,
      );
    }

    return imageContent;
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: PicPacColors.surfaceGrey,
      child: const Center(
        child: Icon(
          LucideIcons.image,
          size: 20.0,
          color: PicPacColors.borderDashed,
        ),
      ),
    );
  }
}

