import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:gap/gap.dart';
import '../../models/product.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class ProfileScreen extends ConsumerWidget {
  final void Function(String productId) onProductTap;

  const ProfileScreen({super.key, required this.onProductTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersProvider);
    final wishlist = ref.watch(favouriteProductsProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: NestedScrollView(
          headerSliverBuilder: (_, __) => [
            SliverAppBar(
              expandedHeight: 220,
              pinned: true,
              backgroundColor: AppTheme.surface,
              flexibleSpace: FlexibleSpaceBar(
                background: _ProfileHeader(),
              ),
              bottom: const TabBar(
                labelColor: AppTheme.textPrimary,
                unselectedLabelColor: AppTheme.textHint,
                indicatorColor: AppTheme.primary,
                indicatorSize: TabBarIndicatorSize.label,
                labelStyle: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600),
                unselectedLabelStyle: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w400),
                tabs: [
                  Tab(text: 'Orders'),
                  Tab(text: 'Wishlist'),
                  Tab(text: 'Settings'),
                ],
              ),
            ),
          ],
          body: TabBarView(
            children: [
              _OrdersTab(orders: orders),
              _WishlistTab(products: wishlist, onProductTap: onProductTap),
              const _SettingsTab(),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Profile Header ────────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.surface,
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 16),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.surfaceVariant,
              border: Border.all(color: AppTheme.divider, width: 2),
            ),
            child: const Center(
              child: Text('A',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary)),
            ),
          ),
          const Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Aasha Mehta',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w600)),
                const Gap(2),
                const Text('aasha.mehta@email.com',
                    style: TextStyle(
                        fontSize: 13, color: AppTheme.textSecondary)),
                const Gap(8),
                Row(
                  children: [
                    _StatChip('12', 'Orders'),
                    const Gap(12),
                    _StatChip('5', 'Wishlist'),
                    const Gap(12),
                    _StatChip('Elite', 'Tier'),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined,
                color: AppTheme.textSecondary, size: 20),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String value, label;
  const _StatChip(this.value, this.label);

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700)),
          Text(label,
              style: const TextStyle(
                  fontSize: 10, color: AppTheme.textSecondary)),
        ],
      );
}

// ── Orders Tab ────────────────────────────────────────────────────────────────

class _OrdersTab extends StatelessWidget {
  final List<Order> orders;
  const _OrdersTab({required this.orders});

  Color _statusColor(String status) => switch (status) {
        'Delivered' => AppTheme.success,
        'Shipped' => Colors.blue,
        'Processing' => AppTheme.accent,
        _ => AppTheme.textSecondary,
      };

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return const Center(
        child: Text('No orders yet.',
            style: TextStyle(color: AppTheme.textSecondary)),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const Gap(12),
      itemBuilder: (_, i) {
        final order = orders[i];
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(order.id,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600)),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusColor(order.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      order.status,
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _statusColor(order.status)),
                    ),
                  ),
                ],
              ),
              const Gap(8),
              Text(
                '${order.date.day}/${order.date.month}/${order.date.year}',
                style: const TextStyle(
                    fontSize: 12, color: AppTheme.textSecondary),
              ),
              const Gap(12),
              SizedBox(
                height: 56,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: order.items.length,
                  separatorBuilder: (_, __) => const Gap(8),
                  itemBuilder: (_, j) => ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: order.items[j].product.images.first,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const Gap(12),
              const Divider(),
              const Gap(8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${order.items.length} item(s)',
                      style: const TextStyle(
                          fontSize: 13, color: AppTheme.textSecondary)),
                  Text(
                    '\$${order.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Wishlist Tab ──────────────────────────────────────────────────────────────

class _WishlistTab extends ConsumerWidget {
  final List products;
  final void Function(String) onProductTap;

  const _WishlistTab(
      {required this.products, required this.onProductTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.favorite_border,
                size: 48, color: AppTheme.textHint),
            const Gap(12),
            const Text('Your wishlist is empty',
                style: TextStyle(color: AppTheme.textSecondary)),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.62,
      ),
      itemCount: products.length,
      itemBuilder: (_, i) => ProductCard(
        product: products[i],
        onTap: () => onProductTap(products[i].id),
      ),
    );
  }
}

// ── Settings Tab ──────────────────────────────────────────────────────────────

class _SettingsTab extends StatelessWidget {
  const _SettingsTab();

  @override
  Widget build(BuildContext context) {
    final sections = [
      _Section('Account', [
        _SettingItem(Icons.person_outline, 'Edit Profile', null),
        _SettingItem(Icons.lock_outline, 'Change Password', null),
        _SettingItem(Icons.location_on_outlined, 'Saved Addresses', null),
      ]),
      _Section('Preferences', [
        _SettingItem(Icons.notifications_outlined, 'Notifications', null),
        _SettingItem(Icons.language_outlined, 'Language', 'English'),
        _SettingItem(Icons.straighten_outlined, 'Size Preferences', 'S / EU 38'),
      ]),
      _Section('Support', [
        _SettingItem(Icons.help_outline, 'Help & FAQ', null),
        _SettingItem(Icons.chat_bubble_outline, 'Contact Us', null),
        _SettingItem(Icons.star_outline, 'Rate the App', null),
      ]),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ...sections.map((s) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8, top: 8),
                  child: Text(
                    s.title.toUpperCase(),
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textHint,
                        letterSpacing: 1.2),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: s.items
                        .asMap()
                        .entries
                        .map((e) => _buildItem(context, e.value,
                            isLast: e.key == s.items.length - 1))
                        .toList(),
                  ),
                ),
                const Gap(8),
              ],
            )),
        const Gap(16),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.logout, size: 18),
          label: const Text('Sign Out'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.error,
            side: const BorderSide(color: AppTheme.error),
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const Gap(32),
      ],
    );
  }

  Widget _buildItem(BuildContext ctx, _SettingItem item,
      {bool isLast = false}) {
    return Column(
      children: [
        ListTile(
          leading: Icon(item.icon, color: AppTheme.textSecondary, size: 20),
          title: Text(item.label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (item.value != null)
                Text(item.value!,
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.textSecondary)),
              const Gap(4),
              const Icon(Icons.chevron_right,
                  color: AppTheme.textHint, size: 18),
            ],
          ),
          onTap: () {},
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        if (!isLast)
          const Divider(indent: 52, endIndent: 0, height: 1),
      ],
    );
  }
}

class _Section {
  final String title;
  final List<_SettingItem> items;
  const _Section(this.title, this.items);
}

class _SettingItem {
  final IconData icon;
  final String label;
  final String? value;
  const _SettingItem(this.icon, this.label, this.value);
}
