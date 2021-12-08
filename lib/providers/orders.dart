import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:youcan/providers/cart.dart';
import 'package:http/http.dart' as http;

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    required this.id,
    required this.amount,
    required this.products,
    required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  String? authToken = '';
  String? userId = '';

  //Return the above data upon each update "Needed in proxy Provider when a provider depend on the other"
  getData(String? authTok, String? uid, List<OrderItem> orders) {
    authToken = authTok;
    userId = uid;
    _orders = orders;
    notifyListeners();
  }

//from private to public
  List<OrderItem> get orders {
    return [..._orders];
  }

  //Return data from backend
  Future<void> fetchAndSetOrders() async {
    final url = Uri.parse(
        //Todo replace .. with realTime database url
        'https://.../orders/$userId.json?auth=$authToken'); //userId to bring only my orders
    try {
      final res = await http.get(url);
      //Get data from firebase based on my uid
      final Map? extractedData = json.decode(res.body) as Map;
      if (extractedData == null) {
        return;
      }

      final List<OrderItem> loadedOrders = [];
      extractedData.forEach((orderId, orderData) {
        //add data to loadedOrders from extractedData
        loadedOrders.add(
          OrderItem(
            id: orderId,
            amount: orderData['amount'],
            products: (orderData['products'] as List<dynamic>)
                .map((e) => CartItem(
                    id: e['id'],
                    title: e['title'],
                    quantity: e['quantity'],
                    price: e['price']))
                .toList(),
            dateTime: DateTime.parse(orderData['dateTime']),
          ),
        );
      });
      //Change the order so last one become above
      _orders = loadedOrders.reversed.toList();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  //add to database
  Future<void> addOrder(List<CartItem> cartProduct, double total) async {
    var url = Uri.parse(
        //Todo replace .. with realTime database url
        'https://.../orders/$userId.json?auth=$authToken');

    final timeStamp = DateTime.now();
    try {
      final res = await http.post(url,
          body: json.encode({
            'amount': total,
            'products': cartProduct
                .map((e) => {
                      'id': e.id,
                      'title': e.title,
                      'quantity': e.quantity,
                      'price': e.price
                    })
                .toList(),
            'dateTime': timeStamp.toIso8601String(),
          }));
      //to add to _item
      _orders.insert(
          0,
          OrderItem(
            id: json.decode(res.body)['name'],
            amount: total,
            products: cartProduct,
            dateTime: timeStamp,
          ));
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}
