import 'package:flutter/material.dart';

class QuizImage extends StatelessWidget {
  final String? imageUrl;
  final double? maxWidth;
  final double? maxHeight;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;
  final Color? backgroundColor;
  final bool showLoadingIndicator;

  const QuizImage({
    Key? key,
    required this.imageUrl,
    this.maxWidth,
    this.maxHeight,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.borderRadius = 12,
    this.backgroundColor,
    this.showLoadingIndicator = true,
  }) : super(key: key);

  // Constructor cho màn hình quiz
  factory QuizImage.quiz(BuildContext context, {required String? imageUrl}) {
    return QuizImage(
      imageUrl: imageUrl,
      width:
          MediaQuery.of(context).size.width - 32, // Trừ đi padding 16 mỗi bên
      height: 200,
      fit: BoxFit.contain,
      backgroundColor: Colors.grey[100],
    );
  }

  // Constructor cho màn hình chi tiết
  factory QuizImage.detail(BuildContext context, {required String? imageUrl}) {
    return QuizImage(
      imageUrl: imageUrl,
      width:
          MediaQuery.of(context).size.width - 32, // Trừ đi padding 16 mỗi bên
      height: 200,
      fit: BoxFit.contain,
      backgroundColor: Colors.grey[100],
    );
  }

  // Constructor cho màn hình thi thử
  factory QuizImage.practice(
    BuildContext context, {
    required String? imageUrl,
  }) {
    return QuizImage(
      imageUrl: imageUrl,
      width:
          MediaQuery.of(context).size.width - 32, // Trừ đi padding 16 mỗi bên
      height: 200,
      fit: BoxFit.contain,
      backgroundColor: Colors.grey[100],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return const SizedBox.shrink();
    }

    Widget imageWidget = Image.asset(
      imageUrl!,
      width: width,
      height: height,
      fit: fit,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (frame == null && showLoadingIndicator) {
          return Container(
            width: width ?? maxWidth,
            height: height ?? maxHeight,
            color: backgroundColor ?? Colors.grey[200],
            child: const Center(child: CircularProgressIndicator()),
          );
        }
        return child;
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width ?? maxWidth,
          height: height ?? maxHeight,
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.grey[200],
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.grey[400], size: 40),
                SizedBox(height: 8),
                Text(
                  'Không thể tải ảnh',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ),
        );
      },
    );

    return Container(
      width: width ?? maxWidth,
      height: height ?? maxHeight,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.grey[200],
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: imageWidget,
      ),
    );
  }
}
