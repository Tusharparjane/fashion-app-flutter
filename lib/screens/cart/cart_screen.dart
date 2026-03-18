import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:gap/gap.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final subtotal = ref.watch(cartSubtotalProvider);
    final total = ref.watch(cartTotalProvider);
    final notifier = ref.read(cartProvider.notifier);

    if (cart.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Bag')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: AppTheme.surfaceVariant,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.shopping_bag_outlined,
                  size: 44,
                  color: AppTheme.textHint,
                ),
              ),
              const Gap(20),
              Text(
                'Your bag is empty',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Gap(8),
              const Text(
                'Add items you love to your bag.',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
              const Gap(28),
              SizedBox(
                width: 180,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Shop Now'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('My Bag (${cart.length})'),
        actions: [
          TextButton(
            onPressed: () => showDialog(
              context: context,
              builder: (_) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: const Text('Clear bag?'),
                content: const Text(
                  'This will remove all items from your bag.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      notifier.clear();
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Clear',
                      style: TextStyle(color: AppTheme.error),
                    ),
                  ),
                ],
              ),
            ),
            child: const Text(
              'Clear',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 200),
            itemCount: cart.length,
            separatorBuilder: (_, __) => const Gap(12),
            itemBuilder: (_, i) {
              final item = cart[i];
              return Dismissible(
                key: ValueKey('${item.product.id}-${item.size}-${item.color}'),
                direction: DismissDirection.endToStart,
                onDismissed: (_) => notifier.removeItem(i),
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: AppTheme.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    color: AppTheme.error,
                    size: 26,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CachedNetworkImage(
                          imageUrl: item.product.images.first,
                          width: 90,
                          height: 110,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const Gap(12),
                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.product.brand.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textHint,
                                letterSpacing: 1,
                              ),
                            ),
                            const Gap(3),
                            Text(
                              item.product.name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const Gap(6),
                            Row(
                              children: [
                                _Chip(item.color),
                                const Gap(6),
                                _Chip(item.size),
                              ],
                            ),
                            const Gap(10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '\$${item.total.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                // Quantity
                                Container(
                                  decoration: BoxDecoration(
                                    color: AppTheme.surfaceVariant,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _QtyButton(
                                        icon: Icons.remove,
                                        onTap: () => notifier.updateQuantity(
                                          i,
                                          item.quantity - 1,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                        ),
                                        child: Text(
                                          '${item.quantity}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      _QtyButton(
                                        icon: Icons.add,
                                        onTap: () => notifier.updateQuantity(
                                          i,
                                          item.quantity + 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
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

          // ── Order Summary ────────────────────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  _SummaryRow('Subtotal', '\$${subtotal.toStringAsFixed(2)}'),
                  const Gap(6),
                  _SummaryRow(
                    'Shipping',
                    subtotal >= 150 ? 'FREE' : '\$12.00',
                    valueColor: subtotal >= 150
                        ? AppTheme.success
                        : AppTheme.textPrimary,
                  ),
                  const Gap(6),
                  const Divider(),
                  const Gap(6),
                  _SummaryRow(
                    'Total',
                    '\$${total.toStringAsFixed(2)}',
                    bold: true,
                    fontSize: 16,
                  ),
                  const Gap(14),
                  ElevatedButton(
                    onPressed: () => _showCheckoutSheet(context, ref),
                    child: const Text('Proceed to Checkout'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCheckoutSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CheckoutSheet(
        total: ref.read(cartTotalProvider),
        onConfirm: () {
          ref.read(cartProvider.notifier).clear();
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 20),
                  Gap(8),
                  Text('Order placed successfully!'),
                ],
              ),
              backgroundColor: AppTheme.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  const _Chip(this.label);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: AppTheme.surfaceVariant,
      borderRadius: BorderRadius.circular(5),
    ),
    child: Text(
      label,
      style: const TextStyle(
        fontSize: 11,
        color: AppTheme.textSecondary,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.all(8),
      child: Icon(icon, size: 16, color: AppTheme.textPrimary),
    ),
  );
}

class _SummaryRow extends StatelessWidget {
  final String label, value;
  final bool bold;
  final double fontSize;
  final Color? valueColor;

  const _SummaryRow(
    this.label,
    this.value, {
    this.bold = false,
    this.fontSize = 14,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
          color: bold ? AppTheme.textPrimary : AppTheme.textSecondary,
        ),
      ),
      Text(
        value,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
          color: valueColor ?? AppTheme.textPrimary,
        ),
      ),
    ],
  );
}

class _CheckoutSheet extends StatefulWidget {
  final double total;
  final VoidCallback onConfirm;

  const _CheckoutSheet({required this.total, required this.onConfirm});

  @override
  State<_CheckoutSheet> createState() => _CheckoutSheetState();
}

class _CheckoutSheetState extends State<_CheckoutSheet> {
  int _step = 0;
  int _paymentMethod = 0;

  final _addressController = TextEditingController(
    text: '123 Fashion Street, Mumbai 400001',
  );
  final _cardController = TextEditingController(text: '**** **** **** 4242');

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Gap(16),
            Row(
              children: ['Delivery', 'Payment', 'Confirm'].asMap().entries.map((
                e,
              ) {
                final active = e.key <= _step;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      children: [
                        Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: active ? AppTheme.primary : AppTheme.divider,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const Gap(4),
                        Text(
                          e.value,
                          style: TextStyle(
                            fontSize: 11,
                            color: active
                                ? AppTheme.primary
                                : AppTheme.textHint,
                            fontWeight: active
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const Gap(20),
            if (_step == 0) ...[
              const Text(
                'Delivery address',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const Gap(12),
              TextField(
                controller: _addressController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.location_on_outlined, size: 18),
                ),
              ),
            ] else if (_step == 1) ...[
              const Text(
                'Payment method',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const Gap(12),
              ...[
                'Credit / Debit Card',
                'UPI',
                'Cash on Delivery',
              ].asMap().entries.map(
                (e) => RadioListTile<int>(
                  title: Text(e.value),
                  value: e.key,
                  groupValue: _paymentMethod,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (v) => setState(() => _paymentMethod = v!),
                  activeColor: AppTheme.primary,
                ),
              ),
              if (_paymentMethod == 0)
                TextField(
                  controller: _cardController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.credit_card, size: 18),
                  ),
                ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.success.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      color: AppTheme.success,
                    ),
                    const Gap(12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Order Total',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          Text(
                            '\$${widget.total.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(12),
              const Text(
                'Estimated delivery: 3-5 business days',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ),
            ],
            const Gap(20),
            ElevatedButton(
              onPressed: () {
                if (_step < 2) {
                  setState(() => _step++);
                } else {
                  widget.onConfirm();
                }
              },
              child: Text(
                _step == 0
                    ? 'Continue to Payment'
                    : _step == 1
                    ? 'Review Order'
                    : 'Place Order',
              ),
            ),
            const Gap(8),
          ],
        ),
      ),
    );
  }
}
