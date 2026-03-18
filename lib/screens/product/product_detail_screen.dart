import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:gap/gap.dart';
import '../../models/mock_data.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;
  final VoidCallback onCartTap;

  const ProductDetailScreen({
    super.key,
    required this.productId,
    required this.onCartTap,
  });

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  final _pageController = PageController();
  int _currentImage = 0;
  bool _descExpanded = false;
  bool _addedToCart = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final product = MockData.products.firstWhere((p) => p.id == widget.productId);
    final isFav = ref.watch(favouritesProvider).contains(product.id);
    final selectedSize = ref.watch(selectedSizeProvider(product.id));
    final selectedColor = ref.watch(selectedColorProvider(product.id));
    final cartCount = ref.watch(cartItemCountProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // ── Image Gallery ──────────────────────────────────────
              SliverAppBar(
                expandedHeight: 420,
                pinned: true,
                backgroundColor: AppTheme.surface,
                leading: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back_ios_new,
                        size: 16, color: AppTheme.primary),
                  ),
                ),
                actions: [
                  GestureDetector(
                    onTap: () => ref
                        .read(favouritesProvider.notifier)
                        .toggle(product.id),
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      width: 38,
                      height: 38,
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
                  GestureDetector(
                    onTap: widget.onCartTap,
                    child: Container(
                      margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Stack(
                        children: [
                          const Center(
                            child: Icon(Icons.shopping_bag_outlined,
                                size: 18, color: AppTheme.primary),
                          ),
                          if (cartCount > 0)
                            Positioned(
                              right: 4,
                              top: 4,
                              child: Container(
                                width: 14,
                                height: 14,
                                decoration: const BoxDecoration(
                                  color: AppTheme.error,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '$cartCount',
                                    style: const TextStyle(
                                      fontSize: 8,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    children: [
                      PageView.builder(
                        controller: _pageController,
                        itemCount: product.images.length,
                        onPageChanged: (i) =>
                            setState(() => _currentImage = i),
                        itemBuilder: (_, i) => CachedNetworkImage(
                          imageUrl: product.images[i],
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                      // Thumbnails
                      Positioned(
                        right: 12,
                        top: 60,
                        child: Column(
                          children: List.generate(
                            product.images.length,
                            (i) => GestureDetector(
                              onTap: () => _pageController.animateToPage(
                                i,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              ),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.only(bottom: 8),
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: _currentImage == i
                                        ? AppTheme.primary
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: CachedNetworkImage(
                                    imageUrl: product.images[i],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Product Info ────────────────────────────────────────
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Brand + Category
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.tag,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              product.brand.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.tagText,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceVariant,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              product.category,
                              style: const TextStyle(
                                fontSize: 11, color: AppTheme.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Gap(12),

                      // Name
                      Text(product.name,
                          style: Theme.of(context).textTheme.headlineMedium),
                      const Gap(8),

                      // Rating
                      RatingRow(
                          rating: product.rating,
                          reviewCount: product.reviewCount),
                      const Gap(14),

                      // Price
                      PriceDisplay(product: product, fontSize: 24),
                      const Gap(24),
                      const Divider(),
                      const Gap(20),

                      // Color selector
                      Text('Color',
                          style: Theme.of(context).textTheme.titleMedium),
                      const Gap(10),
                      Wrap(
                        spacing: 8,
                        children: product.colors.map((color) {
                          final selected = color == selectedColor;
                          return GestureDetector(
                            onTap: () => ref
                                .read(selectedColorProvider(product.id).notifier)
                                .state = color,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppTheme.primary
                                    : AppTheme.surfaceVariant,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: selected
                                      ? AppTheme.primary
                                      : Colors.transparent,
                                ),
                              ),
                              child: Text(
                                color,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: selected
                                      ? Colors.white
                                      : AppTheme.textPrimary,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const Gap(20),

                      // Size selector
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Size',
                              style: Theme.of(context).textTheme.titleMedium),
                          GestureDetector(
                            onTap: () {},
                            child: const Text(
                              'Size guide',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Gap(10),
                      Wrap(
                        spacing: 8,
                        children: product.sizes.map((size) {
                          final selected = size == selectedSize;
                          return GestureDetector(
                            onTap: () => ref
                                .read(selectedSizeProvider(product.id).notifier)
                                .state = size,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 52,
                              height: 44,
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppTheme.primary
                                    : AppTheme.surfaceVariant,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  size,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: selected
                                        ? Colors.white
                                        : AppTheme.textPrimary,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const Gap(24),
                      const Divider(),
                      const Gap(20),

                      // Description
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Description',
                              style: Theme.of(context).textTheme.titleMedium),
                          GestureDetector(
                            onTap: () => setState(
                                () => _descExpanded = !_descExpanded),
                            child: Icon(
                              _descExpanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const Gap(8),
                      AnimatedCrossFade(
                        firstChild: Text(
                          product.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                            height: 1.6,
                          ),
                        ),
                        secondChild: Text(
                          product.description,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                            height: 1.6,
                          ),
                        ),
                        crossFadeState: _descExpanded
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        duration: const Duration(milliseconds: 200),
                      ),
                      const Gap(100),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── Bottom CTA ─────────────────────────────────────────────
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Wishlist button
                  GestureDetector(
                    onTap: () => ref
                        .read(favouritesProvider.notifier)
                        .toggle(product.id),
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.divider, width: 1.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        color: isFav ? AppTheme.error : AppTheme.textSecondary,
                      ),
                    ),
                  ),
                  const Gap(12),
                  // Add to cart
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _addedToCart
                          ? OutlinedButton.icon(
                              key: const ValueKey('added'),
                              onPressed: widget.onCartTap,
                              icon: const Icon(Icons.check, size: 18),
                              label: const Text('View Cart'),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 52),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                            )
                          : ElevatedButton(
                              key: const ValueKey('add'),
                              onPressed: () {
                                ref.read(cartProvider.notifier).addItem(
                                      product,
                                      selectedSize,
                                      selectedColor,
                                    );
                                setState(() => _addedToCart = true);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        '${product.name} added to cart'),
                                    duration: const Duration(seconds: 2),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10)),
                                  ),
                                );
                              },
                              child: const Text('Add to Cart'),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
