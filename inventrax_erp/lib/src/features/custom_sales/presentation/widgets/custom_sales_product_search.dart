import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local/app_database.dart';
import '../../../../data/local/store_settings_provider.dart';
import '../../application/custom_sales_controller.dart';
import '../../application/custom_sales_products_provider.dart';

class CustomSalesProductSearch extends ConsumerStatefulWidget {
  const CustomSalesProductSearch({super.key});

  @override
  ConsumerState<CustomSalesProductSearch> createState() =>
      _CustomSalesProductSearchState();
}

class _CustomSalesProductSearchState
    extends ConsumerState<CustomSalesProductSearch> {
  final _controller = TextEditingController();
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _selectProduct(Product product) {
    ref.read(customSalesControllerProvider.notifier).addProduct(product);
    _controller.clear();
    ref.read(customSalesSearchProvider.notifier).set('');
    _focus.requestFocus();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${product.name}'),
        duration: const Duration(milliseconds: 1200),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = _controller.text.trim();
    final products = ref.watch(customSalesProductsProvider);
    final currency =
        ref.watch(storeSettingsProvider).value?.currencyCode ?? 'USD';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _controller,
          focusNode: _focus,
          decoration: InputDecoration(
            labelText: 'Search product, barcode, or SKU',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: query.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _controller.clear();
                      ref.read(customSalesSearchProvider.notifier).set('');
                    },
                  )
                : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
          ),
          textInputAction: TextInputAction.search,
          onChanged: (v) => ref.read(customSalesSearchProvider.notifier).set(v),
          onSubmitted: (_) {
            final list = products.asData?.value;
            if (list != null && list.isNotEmpty) _selectProduct(list.first);
          },
        ),
        if (query.isNotEmpty) ...[
          const SizedBox(height: 8),
          products.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(12),
              child: LinearProgressIndicator(),
            ),
            error: (_, __) => const SizedBox.shrink(),
            data: (list) {
              if (list.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    'No products found',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                );
              }
              return Material(
                elevation: 2,
                borderRadius: BorderRadius.circular(12),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 240),
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final p = list[i];
                      return ListTile(
                        dense: true,
                        title: Text(p.name),
                        subtitle: Text(
                          [
                            if (p.barcode?.isNotEmpty == true) p.barcode,
                            if (p.sku?.isNotEmpty == true) 'SKU: ${p.sku}',
                            'Stock: ${p.quantity}',
                          ].whereType<String>().join(' · '),
                        ),
                        trailing: Text(
                          formatMoney(p.sellingPriceCents, currency: currency),
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        onTap: () => _selectProduct(p),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ],
    );
  }
}
