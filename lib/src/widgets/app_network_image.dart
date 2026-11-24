import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';
import 'shimmer_box.dart';

class AppNetworkImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final IconData fallbackIcon;
  final String? semanticsLabel;

  const AppNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.fallbackIcon = Icons.storefront,
    this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    final clipRadius = borderRadius ?? BorderRadius.zero;
    final validUrl = imageUrl != null && imageUrl!.trim().isNotEmpty && imageUrl!.startsWith('http');

    if (!validUrl) {
      return ClipRRect(
        borderRadius: clipRadius,
        child: Container(
          width: width,
          height: height,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Semantics(
            label: semanticsLabel ?? 'Placeholder image',
            child: Center(
              child: Icon(fallbackIcon, size: (width != null && width! < 50) ? 20 : 32, color: AllGoColors.textTertiary),
            ),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: clipRadius,
      child: CachedNetworkImage(
        imageUrl: imageUrl!.trim(),
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => ShimmerBox(
          width: width ?? double.infinity,
          height: height ?? double.infinity,
          borderRadius: borderRadius?.topLeft.x ?? 8.0,
        ),
        errorWidget: (context, url, error) => Container(
          width: width,
          height: height,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Semantics(
            label: semanticsLabel ?? 'Error loading image',
            child: Center(
              child: Icon(fallbackIcon, size: (width != null && width! < 50) ? 20 : 32, color: AllGoColors.textTertiary),
            ),
          ),
        ),
      ),
    );
  }
}
