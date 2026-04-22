import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class AnimalNetworkImage extends StatelessWidget {
  const AnimalNetworkImage({
    super.key,
    required this.imageUrl,
    required this.fit,
    this.borderRadius,
    this.width,
    this.height,
  });

  final String? imageUrl;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final child = ((imageUrl ?? '').isNotEmpty)
        ? Image.network(
            imageUrl!,
            fit: fit,
            width: width,
            height: height,
            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
              if (wasSynchronouslyLoaded || frame != null) {
                return child;
              }
              return const _AnimalImageShimmer();
            },
            errorBuilder: (context, error, stackTrace) =>
                const _AnimalImageFallback(),
          )
        : const _AnimalImageFallback();

    if (borderRadius == null) {
      return child;
    }

    return ClipRRect(borderRadius: borderRadius!, child: child);
  }
}

class _AnimalImageShimmer extends StatelessWidget {
  const _AnimalImageShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFEFE5D9),
      highlightColor: const Color(0xFFF8F1E9),
      child: Container(color: const Color(0xFFEFE5D9)),
    );
  }
}

class _AnimalImageFallback extends StatelessWidget {
  const _AnimalImageFallback();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;
        final compact = height > 0 && height < 150;
        final tiny = height > 0 && height < 110;

        final iconSize = tiny
            ? 28.0
            : compact
            ? 34.0
            : 42.0;
        final titleSize = tiny
            ? 13.0
            : compact
            ? 15.0
            : 18.0;
        final horizontalPadding = tiny
            ? 12.0
            : compact
            ? 16.0
            : 24.0;
        final verticalPadding = tiny
            ? 10.0
            : compact
            ? 14.0
            : 24.0;

        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF4ECE2), Color(0xFFEDE0D1)],
            ),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.photo_camera_back_outlined,
                  size: iconSize,
                  color: const Color(0xFF9B8068),
                ),
                SizedBox(height: tiny ? 6 : 10),
                Text(
                  compact ? '暫無照片' : '目前沒有照片',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF6B5848),
                  ),
                ),
                if (!compact) ...[
                  const SizedBox(height: 6),
                  const Text(
                    '可以先查看基本資料與收容資訊',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: Color(0xFF8A7563),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
