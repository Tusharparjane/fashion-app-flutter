import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class SearchScreen extends ConsumerStatefulWidget {
  final void Function(String productId) onProductTap;

  const SearchScreen({super.key, required this.onProductTap});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  static const _trending = [
    'Silk dress', 'Linen blazer', 'Wide leg trousers',
    'Cashmere knit', 'Leather bag', 'Minimalist jewellery',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);
    final results = ref.watch(searchResultsProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: 16),
          child: AppSearchBar(
            controller: _controller,
            focusNode: _focusNode,
            onChanged: (v) =>
                ref.read(searchQueryProvider.notifier).state = v,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () {
            ref.read(searchQueryProvider.notifier).state = '';
            Navigator.pop(context);
          },
        ),
      ),
      body: query.isEmpty
          ? _EmptyState(
              trending: _trending,
              onTap: (t) {
                _controller.text = t;
                ref.read(searchQueryProvider.notifier).state = t;
              },
            )
          : results.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.search_off,
                          size: 48, color: AppTheme.textHint),
                      const Gap(12),
                      Text('No results for "$query"',
                          style: const TextStyle(
                              color: AppTheme.textSecondary)),
                    ],
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Text(
                        '${results.length} results',
                        style: const TextStyle(
                            fontSize: 13, color: AppTheme.textSecondary),
                      ),
                    ),
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.62,
                        ),
                        itemCount: results.length,
                        itemBuilder: (_, i) => ProductCard(
                          product: results[i],
                          onTap: () => widget.onProductTap(results[i].id),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final List<String> trending;
  final void Function(String) onTap;

  const _EmptyState({required this.trending, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Trending Searches',
            style:
                TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        const Gap(12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: trending
              .map((t) => GestureDetector(
                    onTap: () => onTap(t),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.trending_up,
                              size: 14, color: AppTheme.textHint),
                          const Gap(6),
                          Text(t,
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.textPrimary)),
                        ],
                      ),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }
}

// Extend AppSearchBar to accept optional focusNode
extension _SearchBarExt on AppSearchBar {
  // ignore: unused_element
  static AppSearchBar withFocus({
    required TextEditingController controller,
    required FocusNode focusNode,
    required ValueChanged<String> onChanged,
  }) {
    return AppSearchBar(controller: controller, onChanged: onChanged);
  }
}
