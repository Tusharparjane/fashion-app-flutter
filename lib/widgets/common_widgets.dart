import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:shimmer/shimmer.dart';
import '../models/product.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';

// ── Product Card ─────────────────────────────────────────────────────────────

class ProductCard extends ConsumerWidget {
  final Product product;
  final VoidCallback onTap;
  final bool wide;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.wide = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFav = ref.watch(favouritesProvider).contains(product.id);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              flex: wide ? 5 : 6,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: CachedNetworkImage(
                      imageUrl: product.images.first,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Shimmer.fromColors(
                        baseColor: AppTheme.surfaceVariant,
                        highlightColor: AppTheme.surface,
                        child: Container(color: AppTheme.surfaceVariant),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: AppTheme.surfaceVariant,
                        child: const Icon(Icons.image_outlined, color: AppTheme.textHint),
                      ),
                    ),
                  ),
                  // Badge
                  if (product.badge != null || product.isNew)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: product.badge == 'SALE'
                              ? AppTheme.error
                              : product.isNew
                                  ? AppTheme.primary
                                  : AppTheme.accent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          product.badge ?? 'NEW',
                          style: const TextStyle(
                            color: Colors.white, fontSize: 10,
                            fontWeight: FontWeight.w700, letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  // Favourite button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => ref.read(favouritesProvider.notifier).toggle(product.id),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          size: 18,
                          color: isFav ? AppTheme.error : AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Info
            Expanded(
              flex: wide ? 3 : 4,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.brand.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10, fontWeight: FontWeight.w600,
                        color: AppTheme.textHint, letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Text(
                          '\$${product.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        if (product.originalPrice != null) ...[
                          const SizedBox(width: 6),
                          Text(
                            '\$${product.originalPrice!.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 12, color: AppTheme.textHint,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Search Bar ────────────────────────────────────────────────────────────────

class AppSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final String hint;
  final VoidCallback? onTap;
  final bool readOnly;
  final FocusNode? focusNode;

  const AppSearchBar({
    super.key,
    required this.controller,
    this.onChanged,
    this.hint = 'Search styles, brands...',
    this.onTap,
    this.readOnly = false,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      onTap: onTap,
      readOnly: readOnly,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search, color: AppTheme.textHint, size: 20),
        suffixIcon: controller.text.isNotEmpty
            ? GestureDetector(
                onTap: () {
                  controller.clear();
                  onChanged?.call('');
                },
                child: const Icon(Icons.close, color: AppTheme.textHint, size: 18),
              )
            : null,
      ),
    );
  }
}

// ── Section Header ────────────────────────────────────────────────────────────

class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.action,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        if (action != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              action!,
              style: const TextStyle(
                fontSize: 13, color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}

// ── Rating Row ────────────────────────────────────────────────────────────────

class RatingRow extends StatelessWidget {
  final double rating;
  final int reviewCount;
  final double size;

  const RatingRow({
    super.key,
    required this.rating,
    required this.reviewCount,
    this.size = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        RatingBarIndicator(
          rating: rating,
          itemBuilder: (_, __) => const Icon(Icons.star, color: AppTheme.accent),
          itemCount: 5,
          itemSize: size,
          unratedColor: AppTheme.divider,
        ),
        const SizedBox(width: 6),
        Text(
          '$rating ($reviewCount)',
          style: TextStyle(
            fontSize: size - 1,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ── Price Display ─────────────────────────────────────────────────────────────

class PriceDisplay extends StatelessWidget {
  final Product product;
  final double fontSize;

  const PriceDisplay({super.key, required this.product, this.fontSize = 20});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          '\$${product.price.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: fontSize, fontWeight: FontWeight.w700, color: AppTheme.textPrimary,
          ),
        ),
        if (product.originalPrice != null) ...[
          const SizedBox(width: 8),
          Text(
            '\$${product.originalPrice!.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: fontSize - 4, color: AppTheme.textHint,
              decoration: TextDecoration.lineThrough,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '-${product.discountPercent.toInt()}%',
              style: TextStyle(
                fontSize: fontSize - 6, fontWeight: FontWeight.w700,
                color: AppTheme.error,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ── Divider with label ─────────────────────────────────────────────────────────

class LabelDivider extends StatelessWidget {
  final String label;
  const LabelDivider({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(label,
              style: const TextStyle(color: AppTheme.textHint, fontSize: 12)),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}
