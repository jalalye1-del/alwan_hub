import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class AdaptiveContentImage extends StatelessWidget {
  const AdaptiveContentImage({
    super.key,
    required this.source,
    this.width,
    this.height,
    this.aspectRatio,
    this.fit = BoxFit.cover,
    this.borderRadius = BorderRadius.zero,
    this.semanticLabel,
    this.fallbackAsset = 'assets/images/program.jpg',
  });

  final String source;
  final double? width;
  final double? height;
  final double? aspectRatio;
  final BoxFit fit;
  final BorderRadiusGeometry borderRadius;
  final String? semanticLabel;
  final String fallbackAsset;

  bool get _isRemote {
    final uri = Uri.tryParse(source.trim());
    return uri != null &&
        const {'http', 'https', 'data', 'blob'}.contains(uri.scheme);
  }

  @override
  Widget build(BuildContext context) {
    final image = source.trim().isEmpty
        ? _fallback()
        : _isRemote
        ? CachedNetworkImage(
            imageUrl: source,
            width: width,
            height: height,
            fit: fit,
            placeholder: (_, _) => const ColoredBox(
              color: Color(0xFFF0EEFA),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            errorWidget: (_, _, _) => _fallback(),
          )
        : Image.asset(
            source,
            width: width,
            height: height,
            fit: fit,
            semanticLabel: semanticLabel,
            errorBuilder: (_, _, _) => _fallback(),
          );

    Widget result = ClipRRect(borderRadius: borderRadius, child: image);
    if (aspectRatio != null) {
      result = AspectRatio(aspectRatio: aspectRatio!, child: result);
    }
    return SizedBox(width: width, height: height, child: result);
  }

  Widget _fallback() => Image.asset(
    fallbackAsset,
    width: width,
    height: height,
    fit: fit,
    semanticLabel: semanticLabel,
  );
}
