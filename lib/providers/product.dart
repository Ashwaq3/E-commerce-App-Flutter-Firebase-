import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final double price;
  bool isFavorite;

  Product(
      {required this.id,
      required this.title,
      required this.description,
      required this.imageUrl,
      required this.price,
      this.isFavorite = false});

  void _setFavValue(bool newValue) {
    isFavorite = newValue;
    notifyListeners();
  }

  Future<void> toggleFavoriteStatus(String token, String userId) async {
    final oldStatus = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();

    final url = Uri.parse(
        //Todo replace .. with realTime database url
        'https://.../userFavorites/$userId/$id.json?auth=$token');
    //Change the backend value
    //put; use to change the data of a specific variable
    try {
      final res = await http.put(url, body: json.encode(isFavorite));
      if (res.statusCode >= 400) {
        //if an error happened in the backend return the value to its OLD value
        _setFavValue(oldStatus);
      }
    } catch (err) {
      //if an error happened in the backend return the value to its OLD value
    }
  }
}
