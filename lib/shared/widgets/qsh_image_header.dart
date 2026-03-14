import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class QshImageHeader extends StatelessWidget {
  final String imageUrl;
  final String heroTag;
  final double expandedHeight;
  final List<Widget>? actions;

  const QshImageHeader({
    super.key,
    required this.imageUrl,
    required this.heroTag,
    this.expandedHeight = 400,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: expandedHeight,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Hero(
          tag: heroTag,
          child: imageUrl.startsWith('http')
              ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Theme.of(context).colorScheme.surface,
                    child: Center(
                      child: Icon(
                        Icons.image_not_supported,
                        size: 48,
                        color: context.iconFaint,
                      ),
                    ),
                  ),
                )
              : Image.asset(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Theme.of(context).colorScheme.surface,
                    child: Center(
                      child: Icon(
                        Icons.image_not_supported,
                        size: 48,
                        color: context.iconFaint,
                      ),
                    ),
                  ),
                ),
        ),
      ),
      actions: actions,
    );
  }
}
