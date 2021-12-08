import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youcan/providers/auth.dart';
import 'package:youcan/providers/cart.dart';
import 'package:youcan/providers/product.dart';
import 'package:youcan/screens/product_detail_screen.dart';

class ProductItem extends StatelessWidget {
  const ProductItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context, listen: false);
    final cart = Provider.of<Cart>(context, listen: false);
    final authData = Provider.of<Auth>(context, listen: false);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        //like inkwell
        child: GestureDetector(
          //when pressed send product ID as well
          onTap: () => Navigator.of(context)
              .pushNamed(ProductDetailScreen.routeName, arguments: product.id),
          child: Hero(
            tag: product.id,
            child: FadeInImage(
              placeholder:
                  const AssetImage('asset/images/product-placeholder.png'),
              image: NetworkImage(product.imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
        footer: GridTileBar(
          backgroundColor: Colors.pink[200],
          leading: Consumer<Product>(
            builder: (ctx, product, _) => IconButton(
              icon: Icon(
                  product.isFavorite ? Icons.favorite : Icons.favorite_border),
              color: Colors.black26,
              onPressed: () {
                product.toggleFavoriteStatus(authData.token!, authData.userId!);
              },
            ),
          ),
          title: Text(
            product.title,
            textAlign: TextAlign.center,
          ),
          trailing: IconButton(
            icon: const Icon(Icons.shopping_cart),
            color: Colors.black26,
            onPressed: () {
              cart.addItem(product.id, product.price, product.title);
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Text('Added to Cart!'),
                duration: const Duration(seconds: 2),
                action: SnackBarAction(
                  label: 'Undo',
                  onPressed: () {
                    cart.reduceQuantity(product.id);
                  },
                ),
              ));
            },
          ),
        ),
      ),
    );
  }
}
