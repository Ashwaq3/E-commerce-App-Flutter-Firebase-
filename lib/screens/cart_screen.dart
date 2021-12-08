import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart' show Cart;
import '../widgets/cart_item.dart';
import '../providers/orders.dart';

class CartScreen extends StatelessWidget {
  static const routeName = '/cart';

  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(15),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(fontSize: 20),
                  ),
                  const Spacer(),
                  //Will separate between widgets "One in left and the other in right"
                  Chip(
                    label: Text(
                      '\$${cart.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.pink,
                  ),
                  OrderButton(cart: cart),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: ListView.builder(
                itemCount: cart.items.length,
                itemBuilder: (ctx, int index) => ItemsOfCart(
                      cart.items.values.toList()[index].id,
                      cart.items.keys.toList()[index],
                      cart.items.values.toList()[index].quantity,
                      cart.items.values.toList()[index].price,
                      cart.items.values.toList()[index].title,
                    )),
          )
        ],
      ),
    );
  }
}

class OrderButton extends StatefulWidget {
  final Cart cart;

  const OrderButton({Key? key, required this.cart}) : super(key: key);

  @override
  _OrderButtonState createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: (widget.cart.totalAmount <= 0 || _isLoading)
          ? null
          : () async {
              setState(() {
                _isLoading = true;
              });
              await Provider.of<Orders>(context, listen: false).addOrder(
                  widget.cart.items.values.toList(), widget.cart.totalAmount);

              setState(() {
                _isLoading = false;
              });

              widget.cart.clear();
            },
      child: _isLoading
          ? const CircularProgressIndicator()
          : const Text(
              'Order Now',
            ),
    );
  }
}
