import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart.dart';
// import '../providers/cart.dart' show Cart ;
import '../widgets/cart_item.dart' as ci;
import '../providers/orders.dart';

class CartScreen extends StatelessWidget {
  static const routeName = '/cart';
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Your Cart"),
      ),
      backgroundColor: Colors.white70,
      body: Column(
        children: <Widget>[
          Card(
            color: Colors.transparent,
            margin: EdgeInsets.all(14),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    "Total",
                    style: TextStyle(fontSize: 20),
                  ),
                  // SizedBox(
                  //   width: 10,
                  // ),
                  Spacer(),
                  Chip(
                    label: Text(
                      'Rs.${cart.totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  OrderButton(cart: cart),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: cart.items.length,
              itemBuilder: (ctx, i) => ci.CartItem(
                // as we hace CartItem in Cart file and as well as in Cart_item.dart file
                //we are putting prefix in the name of file in import function and
                // this can be useed to call which file has our needed cartItem

                //we can also use Show in cart file to show only Cart function which is needed in this file
                //this will make CartItem present in Cart file to not to show in this file and thus no 2 CartItems.
                cart.items.values.toList()[i].id,
                //as they are present in map so extracting values and converting to list
                cart.items.keys.toList()[i],
                cart.items.values.toList()[i].title,
                cart.items.values.toList()[i].quantity,
                cart.items.values.toList()[i].price,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OrderButton extends StatefulWidget {
  const OrderButton({
    Key key,
    @required this.cart,
  }) : super(key: key);

  final Cart cart;

  @override
  _OrderButtonState createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  var _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return FlatButton(
      // disabledColor: Colors.white38,
      child:_isLoading?CircularProgressIndicator(): Text("Order Now",style: TextStyle(color: Colors.tealAccent),),
      onPressed: (widget.cart.totalAmount == 0 || _isLoading)
          ? null
          : () async{
              setState(() {
                _isLoading = true;

              });
              await Provider.of<Orders>(context, listen: false).addOrder(
                  widget.cart.items.values.toList(), widget.cart.totalAmount);
              widget.cart.clear();
              setState(() {
                _isLoading = true;

              });
            },
      textColor: Theme.of(context).primaryColor,
    );
  }
}
