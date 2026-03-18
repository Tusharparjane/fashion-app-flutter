import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../models/mock_data.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final void Function(String productId) onProductTap;
  final VoidCallback onSearchTap;

  const HomeScreen({
    super.key,
    required this.onProductTap,
    required this.onSearchTap,
  });

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _bannerController = PageController();
  final _searchController = TextEditingController();

  static const _banners = [
    _BannerData(
      image: 'https://images.unsplash.com/photo-1490481651871-ab68de25d43d?w=800',
      label: 'New Season',
      title: 'Spring / Summer\n2025 Collection',
      cta: 'Shop Now',
    ),
    _BannerData(
      image: 'https://images.unsplash.com/photo-1469334031218-e382a71b716b?w=800',
      label: 'Up to 30% Off',
      title: 'End of Season\nSale',
      cta: 'View Sale',
    ),
    _BannerData(
      image: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800',
      label: 'New In',
      title: 'Curated\nEssentials',
      cta: 'Explore',
    ),
  ];

  @override
  void dispose() {
    _bannerController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final filtered = ref.watch(filteredProductsProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          // ── App Bar ──────────────────────────────────────────────────
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: AppTheme.background,
            title: const Text('ÉLARA'),
            centerTitle: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {},
              ),
              const SizedBox(width: 4),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: GestureDetector(
                  onTap: widget.onSearchTap,
                  child: AppSearchBar(
                    controller: _searchController,
                    readOnly: true,
                    onTap: widget.onSearchTap,
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Hero Banner ──────────────────────────────────────
                _HeroBanner(
                  controller: _bannerController,
                  banners: _banners,
                ),
                const SizedBox(height: 24),

                // ── Categories ───────────────────────────────────────
                SizedBox(
                  height: 38,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: MockData.categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final cat = MockData.categories[i];
                      final selected = cat == selectedCategory;
                      return GestureDetector(
                        onTap: () => ref
                            .read(selectedCategoryProvider.notifier)
                            .state = cat,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppTheme.primary
                                : AppTheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            cat,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: selected
                                  ? Colors.white
                                  : AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // ── Featured ─────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SectionHeader(
                    title: 'Featured',
                    action: 'View all',
                    onAction: () {},
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 280,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filtered.take(5).length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (_, i) {
                      final product = filtered.take(5).toList()[i];
                      return SizedBox(
                        width: 180,
                        child: ProductCard(
                          product: product,
                          wide: true,
                          onTap: () => widget.onProductTap(product.id),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 28),

                // ── Promo Banner ─────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _PromoBanner(),
                ),
                const SizedBox(height: 28),

                // ── All Products Grid ─────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SectionHeader(
                    title: selectedCategory == 'All'
                        ? 'All Products'
                        : selectedCategory,
                    action: null,
                  ),
                ),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.62,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) => ProductCard(
                      product: filtered[i],
                      onTap: () => widget.onProductTap(filtered[i].id),
                    ),
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Hero Banner Widget ────────────────────────────────────────────────────────

class _BannerData {
  final String image, label, title, cta;
  const _BannerData({
    required this.image,
    required this.label,
    required this.title,
    required this.cta,
  });
}

class _HeroBanner extends StatelessWidget {
  final PageController controller;
  final List<_BannerData> banners;

  const _HeroBanner({required this.controller, required this.banners});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 220,
          child: PageView.builder(
            controller: controller,
            itemCount: banners.length,
            itemBuilder: (_, i) {
              final b = banners[i];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(b.image, fit: BoxFit.cover),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            colors: [
                              Colors.black.withOpacity(0.0),
                              Colors.black.withOpacity(0.65),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.accent,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                b.label,
                                style: const TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.w700,
                                  color: AppTheme.primary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              b.title,
                              style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.w700,
                                color: Colors.white, height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                b.cta,
                                style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w700,
                                  color: AppTheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        SmoothPageIndicator(
          controller: controller,
          count: banners.length,
          effect: const ExpandingDotsEffect(
            dotColor: AppTheme.divider,
            activeDotColor: AppTheme.primary,
            dotHeight: 6,
            dotWidth: 6,
            expansionFactor: 3,
          ),
        ),
      ],
    );
  }
}

// ── Promo Banner ──────────────────────────────────────────────────────────────

class _PromoBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: AppTheme.tag,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Free Shipping',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: AppTheme.tagText),
                ),
                const SizedBox(height: 4),
                const Text(
                  'On all orders over \$150',
                  style: TextStyle(
                    fontSize: 12, color: AppTheme.tagText,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.local_shipping_outlined,
              size: 40, color: AppTheme.tagText),
        ],
      ),
    );
  }
}
