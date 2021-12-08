import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart';

class ItemsOfCart extends StatelessWidget {
  final String id;
  final String productId;
  final int quantity;
  final double price;
  final String title;

  const ItemsOfCart(
      this.id, this.productId, this.quantity, this.price, this.title,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
        key: ValueKey(id),
        background: Container(
          color: Theme.of(context).errorColor,
          child: const Icon(
            Icons.delete,
            color: Colors.white,
            size: 40,
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
        ),
        direction: DismissDirection.endToStart,
        confirmDismiss: (direction) {
          return showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                    title: const Text('Are you sure?'),
                    content: const Text(
                        'Do you want to remove the item from the cart?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('No'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Yes'),
                      ),
                    ],
                  ));
        },
        onDismissed: (direction) {
          Provider.of<Cart>(context, listen: false).removeItem(productId);
        },
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: ListTile(
              leading: CircleAvatar(
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: FittedBox(
                    child: Text('\$$price'),
                  ),
                ),
              ),
              title: Text(title),
              subtitle: Text('Total \$${price * quantity}'),
              trailing: Text('$quantity x'),
            ),
          ),
        ));
  }
}
