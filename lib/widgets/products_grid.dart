import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youcan/providers/products.dart';
import '../widgets/product_item.dart';

class ProductsGrid extends StatelessWidget {
  final bool showFav;
  const ProductsGrid({Key? key, required this.showFav}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final productData = Provider.of<Products>(context);
    final products = showFav ? productData.favoriteItems : productData.items;
    return products.isEmpty
        ? const Center(
            child: Text('There is no products yet'),
          )
        : GridView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: products.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3 / 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10
                //to listen to every product changes
                ),
            itemBuilder: (ctx, index) => ChangeNotifierProvider.value(
                  value: products[index],
                  child: const ProductItem(),
                ));
  }
}
