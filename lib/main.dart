import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:badges/badges.dart' as badges;
import 'theme/app_theme.dart';
import 'providers/providers.dart';
import 'screens/home/home_screen.dart';
import 'screens/home/search_screen.dart';
import 'screens/product/product_detail_screen.dart';
import 'screens/cart/cart_screen.dart';
import 'screens/profile/profile_screen.dart';

void main() {
  runApp(const ProviderScope(child: FashionApp()));
}

class FashionApp extends StatelessWidget {
  const FashionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ÉLARA Fashion',
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      home: const RootShell(),
    );
  }
}

// ── Navigation Shell ──────────────────────────────────────────────────────────

class RootShell extends ConsumerStatefulWidget {
  const RootShell({super.key});

  @override
  ConsumerState<RootShell> createState() => _RootShellState();
}

class _RootShellState extends ConsumerState<RootShell> {
  int _tab = 0;

  void _push(Widget screen) {
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => screen));
  }

  void _goToCart() {
    setState(() => _tab = 2);
  }

  @override
  Widget build(BuildContext context) {
    final cartCount = ref.watch(cartItemCountProvider);

    final screens = [
      HomeScreen(
        onProductTap: (id) => _push(ProductDetailScreen(
          productId: id,
          onCartTap: _goToCart,
        )),
        onSearchTap: () => _push(SearchScreen(
          onProductTap: (id) => _push(ProductDetailScreen(
            productId: id,
            onCartTap: _goToCart,
          )),
        )),
      ),
      SearchScreen(
        onProductTap: (id) => _push(ProductDetailScreen(
          productId: id,
          onCartTap: _goToCart,
        )),
      ),
      const CartScreen(),
      ProfileScreen(
        onProductTap: (id) => _push(ProductDetailScreen(
          productId: id,
          onCartTap: _goToCart,
        )),
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _tab,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          border: const Border(
              top: BorderSide(color: AppTheme.divider, width: 1)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: 'Home',
                  selected: _tab == 0,
                  onTap: () => setState(() => _tab = 0),
                ),
                _NavItem(
                  icon: Icons.search,
                  activeIcon: Icons.search,
                  label: 'Search',
                  selected: _tab == 1,
                  onTap: () => setState(() => _tab = 1),
                ),
                _NavItem(
                  icon: Icons.shopping_bag_outlined,
                  activeIcon: Icons.shopping_bag,
                  label: 'Bag',
                  selected: _tab == 2,
                  badge: cartCount > 0 ? '$cartCount' : null,
                  onTap: () => setState(() => _tab = 2),
                ),
                _NavItem(
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: 'Profile',
                  selected: _tab == 3,
                  onTap: () => setState(() => _tab = 3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon, activeIcon;
  final String label;
  final bool selected;
  final String? badge;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            badge != null
                ? badges.Badge(
                    badgeContent: Text(
                      badge!,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 9,
                          fontWeight: FontWeight.w700),
                    ),
                    badgeStyle: const badges.BadgeStyle(
                        badgeColor: AppTheme.error, padding: EdgeInsets.all(4)),
                    child: Icon(
                      selected ? activeIcon : icon,
                      size: 24,
                      color: selected
                          ? AppTheme.primary
                          : AppTheme.textHint,
                    ),
                  )
                : Icon(
                    selected ? activeIcon : icon,
                    size: 24,
                    color: selected ? AppTheme.primary : AppTheme.textHint,
                  ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight:
                    selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? AppTheme.primary : AppTheme.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
