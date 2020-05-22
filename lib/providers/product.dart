import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String imageUrl;
  final String description;
  final double price;
  bool isfavorite;

  Product({
    @required this.id,
    @required this.description,
    @required this.price,
    @required this.title,
    @required this.imageUrl,
    this.isfavorite = false,
  });


  Future<void> toggleFavoriteStatus(String token,String userId) async {
    final oldStatus = isfavorite;
    isfavorite = !isfavorite;
    notifyListeners();
    final url = "https://flutter-a1-4ddb0.firebaseio.com/userFavorites/$userId/$id.json?auth=$token";
    
    try {
      final response=await http.put(url,
          body: json.encode(isfavorite,
          ));
        if(response.statusCode>=400){
           isfavorite = oldStatus;
      notifyListeners();
        }
    } catch (error) {
      isfavorite = oldStatus;
      notifyListeners();
    }
  }
}
