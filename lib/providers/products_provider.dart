import 'dart:convert';
import 'dart:core';

import 'package:flutter/material.dart';

import "package:http/http.dart" as http;
import '../models/http_Exceptions.dart';
import './product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];
  // var _showFavoritesOnly = false;

  List<Product> get items {
    // if (_showFavoritesOnly) {
    //   return _items.where((prodItem) => prodItem.isFavorite).toList();
    // }
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isfavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  // void showFavoritesOnly() {
  //   _showFavoritesOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavoritesOnly = false;
  //   notifyListeners();
  // }

  String authToken, userId;
  Products(this.authToken, this.userId, this._items);

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    //[] in function means it is optional

    final filterString =
        filterByUser ? "orderBy:'creatorId'&equalTo='$userId'" : "";
    var url =
        'https://flutter-a1-4ddb0.firebaseio.com/products.json?auth=$authToken&$filterString';
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }

      url =
          "https://flutter-a1-4ddb0.firebaseio.com/userFavorites?$userId.json?auth=$authToken "; //firebase specific commands
      final favoriteResponse = await http.get(url);
      final favoriteData = json.decode(favoriteResponse.body);
      final List<Product> loadedProducts = [];
      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(Product(
          id: prodId,
          title: prodData['title'],
          description: prodData['description'],
          price: prodData['price'],
          isfavorite: favoriteData == null
              ? false
              : favoriteData[prodId] ??
                  null, //this last ?? checks if it is null.if it si not null it will assign its own value
          imageUrl: prodData['imageUrl'],
        ));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      //throw (error);
    }
  }

  Future<void> addProduct(Product product) async {
    final url =
        'https://flutter-a1-4ddb0.firebaseio.com/products.json?auth=$authToken';
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'price': product.price,
          'creatorId': userId,
        }),
      );
      final newProduct = Product(
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
        id: json.decode(response.body)['name'],
      );
      _items.add(newProduct);
      // _items.insert(0, newProduct); // at the start of the list
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final url =
          'https://flutter-a1-4ddb0.firebaseio.com/products/$id.json?auth=$authToken';
      await http.patch(url,
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'imageUrl': newProduct.imageUrl,
            'price': newProduct.price
          }));
      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {
      print('...');
    }
  }

  Future<void> deleteProduct(String id) async {
    final url =
        'https://flutter-a1-4ddb0.firebaseio.com/products/$id.json?auth=$authToken';
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    var existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product.');
    }
    existingProduct = null;
  }
}

// class Products with ChangeNotifier {
//   List<Product> _items = [
//     // Product(
//     //   id: 'p1',
//     //   title: 'Red Shirt',
//     //   description: 'A red shirt - it is pretty red!',
//     //   price: 29.99,
//     //   imageUrl:
//     //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
//     // ),
//     // Product(
//     //   id: 'p2',
//     //   title: 'Trousers',
//     //   description: 'A nice pair of trousers.',
//     //   price: 59.99,
//     //   imageUrl:
//     //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
//     // ),
//     // Product(
//     //   id: 'p3',
//     //   title: 'Yellow Scarf',
//     //   description: 'Warm and cozy - exactly what you need for the winter.',
//     //   price: 19.99,
//     //   imageUrl:
//     //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
//     // ),
//     // Product(
//     //   id: 'p4',
//     //   title: 'A Pan',
//     //   description: 'Prepare any meal you want.',
//     //   price: 49.99,
//     //   imageUrl:
//     //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
//     // ),
//   ];

//   // var _showFavorites = false;

//   List<Product> get items {
//     // if (_showFavorites) {
//     //   return _items.where((prodItem) => prodItem.isfavorite).toList();
//     // }
//     return [..._items];
//     //returrning copy of list
//   }

//   List<Product> get favoriteItems {
//     return _items.where((prodItem) => prodItem.isfavorite).toList();
//   }

//   // void showOnlyFavorites() {
//   //   _showFavorites = true;
//   //   notifyListeners();
//   // }

//   // void showAll() {
//   //   _showFavorites = false;
//   //   notifyListeners();
//   // }
//   Product findById(String id) {
//     return _items.firstWhere((prod) => prod.id == id);
//   }

//   Future<void> fetchAndSetProducts() async {
//     const url = "https://flutter-a2.firebaseio.com/products.json";
//     try {
//       final response = await http.get(url);
//       final extractedData = json.decode(response.body) as Map<String, dynamic>;
//       if (extractedData == null) {return;}
//       final List<Product> loadedProduct = [];
//       extractedData.forEach((prodId, prodData) {
//         loadedProduct.add(
//           Product(
//             id: prodId.toString(),
//             description: prodData['description'],
//             imageUrl: prodData['imageUrl'],
//             title: prodData['title'],
//             price: prodData['price'],
//             isfavorite: prodData['isFavorite'],
//           ),
//         );
//         _items = loadedProduct;
//         notifyListeners();
//       });
//     } catch (error) {
//       throw error;
//     }
//   }

//   Future<void> addProduct(Product product) async {
//     const url =
//         "https://flutter-a2.firebaseio.com/products.json"; //copying firebase url from google firebase i created
//     //always add .json at end
//     //under products folder
//     // return http
//     try {
//       final response = await http.post(
//         url,
//         body: json.encode(
//           {
//             'title': product.title,
//             'description': product.description,
//             'isFavorite': product.isfavorite,
//             'price': product.price.toDouble(),
//             'imageUrl': product.imageUrl,
//           },
//         ),
//         //coverting product to json file using dart:convert fiel
//         //help us to find request bode
//         //JSON==JAVASCRIPT OBJECT NOTATTION
//       );
//       final newProduct = Product(
//         title: product.title,
//         description: product.description,
//         price: product.price,
//         imageUrl: product.imageUrl,
//         // id: DateTime.now().toString()/
//         id: json.decode(response.body)['name'],
//         //assingning id encrypted value given by firebase
//       );
//       _items.add(newProduct);
//       // _items.insert(0, newProduct); // at the start of the list
//       notifyListeners();
//     } catch (error) {
//       print(error);
//       throw error;
//     }
//   }
//   // }).catchError((error) {
//   //   print(error);
//   //   throw error;
//   // });

//   Future<void> updateProduct(String id, Product newProduct) async {
//     final prodIndex = _items.indexWhere((prod) => prod.id == id);

//     if (prodIndex >= 0) {
//       final url = "https://flutter-a2.firebaseio.com/products/$id.json";
//     await  http.patch(url,
//           body: json.encode({
//             'title': newProduct.title,
//             'description': newProduct.description,
//             'id': newProduct.id,
//             'imageUrl': newProduct.imageUrl,
//             // 'isFavorite'
//           }));
//       _items[prodIndex] = newProduct;
//       notifyListeners();
//     } else {
//       print("...");
//     }
//   }

//   Future<void> deleteProduct(String id) async {
//     final url = "https://flutter-a2.firebaseio.com/products/$id.json";
//     final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
//     var existingProduct = _items[existingProductIndex];
//     _items.removeAt(existingProductIndex);
//     notifyListeners();
//     final response = await http.delete(url);

//     if (response.statusCode >= 400) {
//       //when status code is >=400 it means that it throws an error which is not caught by catchError
//       _items.insert(existingProductIndex, existingProduct);
//       notifyListeners();
//       throw HttpException("Could not delete the item!!");
//     } else
//       existingProduct = null;
//   }
// }
