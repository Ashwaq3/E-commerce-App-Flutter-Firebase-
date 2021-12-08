import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:youcan/widgets/app_drawer.dart';
import '../providers/orders.dart';
import '../widgets/order_item.dart' show ItemsOrdered;

class OrderScreen extends StatelessWidget {
  static const routeName = '/order';

  const OrderScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('My Orders'),
      ),
      body: FutureBuilder(
          future:
              Provider.of<Orders>(context, listen: false).fetchAndSetOrders(),
          builder: (ctx, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else {
              if (snapshot.error != null) {
                return const Center(
                  child: Text('An error occured'),
                );
              } else {
                return Consumer<Orders>(
                  builder: (ctx, orderData, child) => ListView.builder(
                    itemCount: orderData.orders.length,
                    itemBuilder: (BuildContext context, int index) =>
                        ItemsOrdered(order: orderData.orders[index]),
                  ),
                );
              }
            }
          }),
    );
  }
}
