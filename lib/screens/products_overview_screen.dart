import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/app_drawer.dart';
import '../providers/products_provider.dart';
import '../screens/cart_screen.dart';
import '../widgets/ProductsGrid.dart';
import '../widgets/badge.dart';
import '../providers/cart.dart';

// enum FilterOptions {
//   favorites,
//   all,
// }

class ProductOverviewScreen extends StatefulWidget {
  @override
  _ProductOverviewScreenState createState() => _ProductOverviewScreenState();
}

class _ProductOverviewScreenState extends State<ProductOverviewScreen> {
 var _showFavorites = false;
  var _isInit = true;
  var _isLoading = false;

  @override
  void initState() {
    // Provider.of<Products>(context).fetchAndSetProducts(); // WON'T WORK!
    // Future.delayed(Duration.zero).then((_) {
    //   Provider.of<Products>(context).fetchAndSetProducts();
    // });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<Products>(context).fetchAndSetProducts().then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

//   var _showFavorites = false;
//   var _isLoading = false;
// // var _isInit = true;

//   @override
//   void initState() {
//     // Provider.of<Products>(context).fetchAndSetProducts();
//     //this will not work because .of(context) are not usable in init state
    
//     // Provider.of<Products>(context).fetchAndSetProducts(); // WON'T WORK!
//     Future.delayed(Duration.zero).then((_) {
//       Provider.of<Products>(context).fetchAndSetProducts();
//     });
//     super.initState();
//   }

  // @override
  // void didChangeDependencies() {
  //   if (_isInit) {
  //     setState(() {
  //       _isLoading = true;
  //     });
  //     Provider.of<Products>(context).fetchAndSetProducts().then((_) {
  //       setState(() {
  //         _isLoading = false;
  //       });
  //     });
  //   }
  //   _isInit = false;
  //   super.didChangeDependencies();
  // }

 
  // @override
  // void didChangeDependencies() {
  //   if (_isInit) {
  //     setState(() {
  //       _isLoading = true;
  //     });
  //     Provider.of<Products>(context).fetchAndSetProducts().then((_) {
  //       setState(() {
  //         _isLoading = false;
  //       });
  //     });
  //   }
  //   _isInit = false;
  //   super.didChangeDependencies();
  // }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  // }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Shop'),
        actions: <Widget>[
          PopupMenuButton(
            onSelected: (int selectedValue) {
              setState(() {
                if (selectedValue == 1) {
                  _showFavorites = true;
                } else {
                  _showFavorites = false;
                }
              });
              print(selectedValue);
            },
            icon: Icon(Icons.more_vert),
            itemBuilder: (_) => [
              PopupMenuItem(child: Text("Show Favorites"), value: 1),
              PopupMenuItem(child: Text("All items"), value: 0),
            ],
          ),
          Consumer<Cart>(
            child: IconButton(
                icon: Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.of(context).pushNamed(CartScreen.routeName);
                }),
            builder: (_, cartData, ch) => Badge(
              child: ch,
              value: cartData.itemCount.toString(),
            ),
          ),
        ],
      ),
      drawer: AppDrawer(),
      body:(_isLoading)?Center(child:CircularProgressIndicator(),): ProductsGrid(_showFavorites),
    );
  }
}
