import 'package:flutter/material.dart';

class ProductImage extends StatelessWidget {
  const ProductImage({super.key, required this.url, this.padding = 12});

  final String url;
  final double padding;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ColoredBox(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Image.network(
          url,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return Center(
              child: SizedBox.square(
                dimension: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: scheme.outline,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) => Center(
            child: Icon(
              Icons.checkroom_outlined,
              size: 40,
              color: scheme.outline,
            ),
          ),
        ),
      ),
    );
  }
}
