import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../cart/presentation/pages/cart_page.dart';
import '../../../products/presentation/pages/products_page.dart';
import '../../../watchlist/presentation/bloc/watchlist_bloc.dart';
import '../../../watchlist/presentation/pages/watchlist_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const int _shopTab = 0;
  static const int _cartTab = 2;

  int _index = _shopTab;

  void _select(int index) => setState(() => _index = index);

  void _showCartNotice(BuildContext context, CartState state) {
    final notice = state.notice!;
    final scheme = Theme.of(context).colorScheme;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          content: Text(notice.message),
          backgroundColor: notice.isError ? scheme.error : null,
          action: notice.isError || _index == _cartTab
              ? null
              : SnackBarAction(
                  label: 'View cart',
                  onPressed: () => _select(_cartTab),
                ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final cartCount = context.select((CartBloc b) => b.state.cart.totalItems);
    final watchCount = context.select(
      (WatchlistBloc b) => b.state.items.length,
    );

    return BlocListener<CartBloc, CartState>(
      listenWhen: (previous, current) =>
          current.notice != null && !identical(previous.notice, current.notice),
      listener: _showCartNotice,
      child: Scaffold(
        body: IndexedStack(
          index: _index,
          children: [
            const ProductsPage(),
            WatchlistPage(onBrowse: () => _select(_shopTab)),
            CartPage(onBrowse: () => _select(_shopTab)),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: _select,
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.storefront_outlined),
              selectedIcon: Icon(Icons.storefront),
              label: 'Shop',
            ),
            NavigationDestination(
              icon: Badge.count(
                count: watchCount,
                isLabelVisible: watchCount > 0,
                child: const Icon(Icons.favorite_border),
              ),
              selectedIcon: Badge.count(
                count: watchCount,
                isLabelVisible: watchCount > 0,
                child: const Icon(Icons.favorite),
              ),
              label: 'Watchlist',
            ),
            NavigationDestination(
              icon: Badge.count(
                count: cartCount,
                isLabelVisible: cartCount > 0,
                child: const Icon(Icons.shopping_bag_outlined),
              ),
              selectedIcon: Badge.count(
                count: cartCount,
                isLabelVisible: cartCount > 0,
                child: const Icon(Icons.shopping_bag),
              ),
              label: 'Cart',
            ),
          ],
        ),
      ),
    );
  }
}
