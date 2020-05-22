import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/userProduct_item.dart';
import '../providers/products_provider.dart';
import '../widgets/app_drawer.dart';
import './edit_product_screen.dart';

class UserProductScreen extends StatelessWidget {
  static const routeName = '/userProduct';

  Future<void> _refreshProducts(BuildContext context) async{
    Provider.of<Products>(context).fetchAndSetProducts(true);
  }

  @override
  Widget build(BuildContext context) {
    // final productData = Provider.of<Products>(context);
    return Scaffold(
      appBar: AppBar(title: const Text("Your Products"), actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            Navigator.of(context).pushNamed(EditProductScreen.routeName);
          },
        )
      ]),
      body: FutureBuilder(
              future: _refreshProducts(context),
              builder:(ctx,snapshot)=>snapshot.connectionState==ConnectionState.waiting?Center(child: CircularProgressIndicator(),) :RefreshIndicator(
          onRefresh: ()=> _refreshProducts(context) ,
                child: Consumer<Products>(
                                  builder:(ctx,productData,_)=> Padding(
            padding: EdgeInsets.all(8),
            child: ListView.builder(
              itemCount: productData.items.length,
              itemBuilder: (_, i) => Column(
                  children: <Widget>[
                    UserProductItem(
                      productData.items[i].id,
                        productData.items[i].title, productData.items[i].imageUrl,),
                    Divider(),
                  ],
              ),
            ),
          ),
                ),
        ),
      ),
      drawer: AppDrawer(),
    );
  }
}
