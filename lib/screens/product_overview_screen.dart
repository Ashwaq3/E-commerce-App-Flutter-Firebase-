import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart';
import '../providers/products.dart';
import '../widgets/app_drawer.dart';
import '../widgets/badge.dart';
import '../widgets/products_grid.dart';
import './cart_screen.dart';

enum FilterOption { favorites, all }

class ProductOverviewScreen extends StatefulWidget {
  const ProductOverviewScreen({Key? key}) : super(key: key);

  @override
  State<ProductOverviewScreen> createState() => _ProductOverviewScreenState();
}

class _ProductOverviewScreenState extends State<ProductOverviewScreen> {
  var _isLoading = false;
  var _showOnlyFavorite = false; //Filter the product based on this value

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    //On building the screen calls data from Firebase
    Provider.of<Products>(context, listen: false)
        .fetchAndSetProducts()
        .then((_) => setState(() => _isLoading = false))
        .catchError((error) => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Spring Products'),
        actions: [
          //The 3 dots menu
          PopupMenuButton(
            onSelected: (FilterOption selectedVal) {
              setState(() {
                if (selectedVal == FilterOption.favorites) {
                  _showOnlyFavorite = true;
                } else {
                  _showOnlyFavorite = false;
                }
              });
            },
            icon: const Icon(Icons.more_vert_sharp),
            itemBuilder: (_) => [
              const PopupMenuItem(
                child: Text('Only Favorites'),
                value: FilterOption.favorites,
              ),
              const PopupMenuItem(
                child: Text('Show All'),
                value: FilterOption.all,
              ),
            ],
          ),
          Consumer<Cart>(
              child: IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () =>
                    Navigator.of(context).pushNamed(CartScreen.routeName),
              ),
              //Use Badge to add number of items in the cart
              builder: (_, cart, ch) => Badge(
                    child: ch!,
                    value: cart.itemCount.toString(),
                  ))
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ProductsGrid(showFav: _showOnlyFavorite),
    );
  }
}
