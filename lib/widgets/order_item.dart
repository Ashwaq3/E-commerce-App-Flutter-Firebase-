import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../providers/orders.dart' as ord;

class ItemsOrdered extends StatelessWidget {
  final ord.OrderItem order;

  const ItemsOrdered({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: ExpansionTile(
        title: Text('\$${order.amount}'),
        subtitle: Text(DateFormat('dd/MM/yyy hh:mm').format(order.dateTime)),
        children: order.products
            .map((e) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      e.title,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${e.quantity} x \$${e.price}',
                      style: const TextStyle(fontSize: 18, color: Colors.grey),
                    )
                  ],
                ))
            .toList(),
      ),
    );
  }
}
