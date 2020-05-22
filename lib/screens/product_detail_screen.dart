import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products_provider.dart';

class ProductDetailScreen extends StatelessWidget {
  // final String title;
  // ProductDetailScreen(this.title);
  static const routeName = '/product-detail';
  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context).settings.arguments as String;
    final loadedProduct =
        Provider.of<Products>(context, listen: false).findById(productId);
    //by listening false this will not rebuild when we have new object
    // if (loadedProduct != null) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(loadedProduct.title),
      // ),
      // backgroundColor:Colors.black38,
      body: CustomScrollView(
        // SingleChildScrollView(
        slivers: <Widget>[
          //slivers are scrollabe parts on screen
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title:  Container(alignment: Alignment.bottomLeft,child: Text(loadedProduct.title,style:TextStyle(color: Colors.pinkAccent)),),
              background: Hero(
                tag: loadedProduct.id,
                child: Image.network(loadedProduct.imageUrl, fit: BoxFit.cover,),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                // Container(alignment: Alignment.bottomLeft,child: Text(loadedProduct.title,style:TextStyle(backgroundColor: Colors.black54)),margin: EdgeInsets.only(left:6,),),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Rs.${loadedProduct.price}",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 22,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  width: double.infinity,
                  child: Text(
                    loadedProduct.description,
                    textAlign: TextAlign.center,
                    style:TextStyle(fontFamily: 'Lato',fontSize: 20,),
                    softWrap: true,
                  ),
                ),
                SizedBox(height: 800,),
              ],
            ),
          ),
        ],
        // // // child: Column(
        // // //   children: <Widget>[
        // // //     Container(
        // // //       height: 300,
        // // //       width: double.infinity,
        // // //       child:
        // // //     ),
        // //   ],
        // ),
      ),
    );
  }
  // return Scaffold(
  //   appBar: AppBar(title:Text('No item')),
  //   body: Center(
  //     child: Text("Add Products"),
  //   ),
  // );
  // }
}
