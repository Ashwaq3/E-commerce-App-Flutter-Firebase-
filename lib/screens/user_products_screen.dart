import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:youcan/widgets/app_drawer.dart';
import '../providers/products.dart';
import '../widgets/user_product_item.dart';
import './edit_product_screen.dart';

class UserProductsScreen extends StatelessWidget {
  static const routeName = '/user-products';

  const UserProductsScreen({Key? key}) : super(key: key);

  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<Products>(context, listen: false)
        .fetchAndSetProducts(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('My Products'),
        actions: [
          IconButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed(EditProductScreen.routeName),
              icon: const Icon(Icons.add)),
        ],
      ),
      body: FutureBuilder(
        future: _refreshProducts(context),
        builder: (ctx, AsyncSnapshot snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : RefreshIndicator(
                    child: Consumer<Products>(
                      builder: (ctx, productsData, _) => Padding(
                        padding: const EdgeInsets.all(8),
                        child: ListView.builder(
                            itemCount: productsData.items.length,
                            itemBuilder: (_, int index) => Column(
                                  children: [
                                    UserProductItem(
                                        id: productsData.items[index].id,
                                        title: productsData.items[index].title,
                                        imageUrl:
                                            productsData.items[index].imageUrl),
                                    const Divider()
                                  ],
                                )),
                      ),
                    ),
                    onRefresh: () => _refreshProducts(context)),
      ),
    );
  }
}
