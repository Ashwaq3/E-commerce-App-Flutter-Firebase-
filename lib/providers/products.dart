import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/http_exception.dart';
import './product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [
    Product(
      id: 'p1',
      title: 'Red Shirt',
      description: 'A red shirt - it is pretty red!',
      price: 29.99,
      imageUrl:
          'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    ),
    Product(
      id: 'p2',
      title: 'Trousers',
      description: 'A nice pair of trousers.',
      price: 59.99,
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    ),
    Product(
      id: 'p3',
      title: 'Yellow Scarf',
      description: 'Warm and cozy - exactly what you need for the winter.',
      price: 19.99,
      imageUrl:
          'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    ),
    Product(
      id: 'p4',
      title: 'A Pan',
      description: 'Prepare any meal you want.',
      price: 49.99,
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    ),
  ];

  String? authToken = '';
  String? userId = '';

  //Return the above data upon each update "Needed in proxy Provider when a provider depend on the other"
  getData(String? authTok, String? uid, List<Product> products) {
    authToken = authTok;
    userId = uid;
    _items = products;
    notifyListeners();
  }

//from private to public
  List<Product> get items {
    return [..._items];
  }

  //return fav items
  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

  //for the search
  Product findById(String id) {
    return _items.firstWhere((element) => element.id == id);
  }

  //Return data from backend
  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    if (authToken != null || userId != null) {
      var filteredString = filterByUser
          ? 'orderBy="creatorId"&equalTo="$userId"'
          : ''; //Syntax given by Firebase
      var url = Uri.parse(
          //Todo replace .. with realTime database url
          'https://.../products.json?auth=$authToken&$filteredString');
      try {
        final res = await http.get(url);
        final Map? extractedData = json.decode(res.body) as Map;
        if (extractedData == null) {
          return;
        }

        url = Uri.parse(
            //Todo replace .. with realTime database url
            'https://.../userFavorites/$userId.json?auth=$authToken');
        final favRes = await http.get(url);
        final favData = json.decode(favRes.body);
        final List<Product> loadedProducts = [];
        extractedData.forEach((prodId, prodData) {
          loadedProducts.add(
            Product(
                id: prodId,
                title: prodData['title'],
                description: prodData['description'],
                imageUrl: prodData['imageUrl'],
                price: prodData['price'],
                isFavorite: favData == null
                    ? false
                    : favData[prodId] ??
                        false), //?? means if the value of favData[prodId] null
          );
        });
        _items = loadedProducts;
        notifyListeners();
      } catch (e) {
        rethrow;
      }
    }
  }

  //add to database
  Future<void> addProduct(Product product) async {
    var url = Uri.parse(
        //Todo replace .. with realTime database url
        'https://.../products.json?auth=$authToken');

    try {
      final res = await http.post(url,
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'price': product.price,
            'creatorId': userId
          }));
      //to add to _item
      final newProduct = Product(
          id: json.decode(res.body)['name'],
          title: product.title,
          description: product.description,
          imageUrl: product.imageUrl,
          price: product.price);
      _items.add(newProduct);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((element) => element.id == id);

    if (prodIndex >= 0) {
      final url = Uri.parse(
          //Todo replace .. with realTime database url
          'https://.../products/$id.json?auth=$authToken');
      await http.patch(url,
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'imageUrl': newProduct.imageUrl,
            'price': newProduct.price,
          }));

      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {
      //nothing
    }
  }

  Future<void> deleteProduct(String id) async {
    final url = Uri.parse(
        //Todo replace .. with realTime database url
        'https://.../products/$id.json?auth=$authToken');
    final existingProductIndex =
        _items.indexWhere((element) => element.id == id);
    Product? existingProduct = _items[
        existingProductIndex]; //Store old value to return if failed to delete in backend

    _items.removeAt(existingProductIndex);
    notifyListeners();

    final res = await http.delete(url);
    if (res.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete Product.');
    }
    existingProduct = null;
  }
}
