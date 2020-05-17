import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product.dart';
import '../providers/products_provider.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/editProductdScreen';

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlcontroller = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  var _editedProduct =
      Product(id: null, title: "", price: 0, description: "", imageUrl: "");
  var _initValues = {
    "title": '',
    "description": "",
    "imageUrl": "",
    "price": "",
  };
  var _isInit = true;
  var _isLoading = false;

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final productId = ModalRoute.of(context).settings.arguments as String;
      if (productId != null) {
        _editedProduct =
            Provider.of<Products>(context, listen: false).findById(productId);
        _initValues = {
          'title': _editedProduct.title,
          'description': _editedProduct.description,
          'imageUrl': '',
          'price': _editedProduct.price.toString(),
        };
        _imageUrlcontroller.text = _editedProduct.imageUrl;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlcontroller.dispose();
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      if (_imageUrlcontroller.text.isEmpty ||
          (!_imageUrlcontroller.text.startsWith("http") &&
              !_imageUrlcontroller.text.startsWith("https")) ||
          (!_imageUrlcontroller.text.endsWith(".jpeg") &&
              !_imageUrlcontroller.text.endsWith(".jpg") &&
              !_imageUrlcontroller.text.endsWith(".png"))) return;
      setState(() {});
    }
  }

  Future<void> _saveForm() async {
    final _isValid = _form.currentState.validate();
    if (!_isValid) {
      return;
    }
    _form.currentState.save();
    setState(() {
      _isLoading = true;
    });
    if (_editedProduct.id != null) {
     await Provider.of<Products>(context, listen: false)
          .updateProduct(_editedProduct.id, _editedProduct);
      
    } else {
     try{await Provider.of<Products>(context, listen: false)
          .addProduct(_editedProduct);}

          catch(error) {
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text("An error occurred!"),
            content: Text("Something went wrong!"),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                  child: Text('Okay!!'))
            ],
          ),
        );
      }
      //   finally{setState(() {
      //     _isLoading = false;
      //   });
      //   Navigator.of(context).pop();
      // }
    }
    setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pop();
    // Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Product"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              _saveForm();
            },
          )
        ],
      ),
      body: (_isLoading)
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                  key: _form,
                  child: ListView(
                    children: <Widget>[
                      TextFormField(
                        initialValue: _initValues["title"],
                        decoration: InputDecoration(labelText: "Title"),
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_priceFocusNode);
                        },
                        onSaved: (value) {
                          _editedProduct = Product(
                            title: value,
                            id: _editedProduct.id,
                            description: _editedProduct.description,
                            price: _editedProduct.price,
                            imageUrl: _editedProduct.imageUrl,
                            isfavorite: _editedProduct.isfavorite,
                          );
                        },
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Please provide a value!!"; //text means error to be showed
                          }

                          return null; //null means no error
                        },
                      ),
                      TextFormField(
                        initialValue: _initValues["price"],
                        decoration: InputDecoration(labelText: "Price"),
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        focusNode: _priceFocusNode,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context)
                              .requestFocus(_descriptionFocusNode);
                        },
                        onSaved: (value) {
                          _editedProduct = Product(
                            title: _editedProduct.title,
                            id: _editedProduct.id,
                            isfavorite: _editedProduct.isfavorite,
                            description: _editedProduct.description,
                            price: double.parse(value),
                            imageUrl: _editedProduct.imageUrl,
                          );
                        },
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Please enter the price";
                          }
                          if (double.tryParse(value) == null) {
                            return "Enter a valid Price";
                          }
                          if (double.parse(value) <= 0) {
                            return "Please add price which is greator than 0";
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                          initialValue: _initValues["description"],
                          decoration: InputDecoration(labelText: "Description"),
                          maxLines: 3,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.multiline,
                          focusNode: _descriptionFocusNode,
                          onSaved: (value) {
                            _editedProduct = Product(
                              title: _editedProduct.title,
                              id: _editedProduct.id,
                              isfavorite: _editedProduct.isfavorite,
                              description: value,
                              price: _editedProduct.price,
                              imageUrl: _editedProduct.imageUrl,
                            );
                          },
                          validator: (value) {
                            if (value.isEmpty) {
                              return "Please provide a value!!";
                            }
                            if (value.length < 10) {
                              return "Please describe the objet more that 10 characters";
                            }
                            return null;
                          }),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Container(
                            width: 100,
                            height: 100,
                            margin: EdgeInsets.only(right: 10, top: 8),
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1,
                                color: Colors.grey,
                              ),
                            ),
                            child: _imageUrlcontroller.text.isEmpty
                                ? Text("Enter the URL")
                                : FittedBox(
                                    child:
                                        Image.network(_imageUrlcontroller.text),
                                    fit: BoxFit.cover),
                          ),
                          Expanded(
                            child: TextFormField(
                                decoration:
                                    InputDecoration(labelText: "Image URL"),
                                textInputAction: TextInputAction.done,
                                keyboardType: TextInputType.url,
                                focusNode: _imageUrlFocusNode,
                                controller: _imageUrlcontroller,
                                onSaved: (value) {
                                  _editedProduct = Product(
                                    title: _editedProduct.title,
                                    id: _editedProduct.id,
                                    isfavorite: _editedProduct.isfavorite,
                                    description: _editedProduct.description,
                                    price: _editedProduct.price,
                                    imageUrl: value,
                                  );
                                },
                                onFieldSubmitted: (_) {
                                  _saveForm();
                                },
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return "Please provide an Image URL!!"; //text means error to be showed
                                  }
                                  if (!value.startsWith("http") &&
                                      !value.startsWith("https")) {
                                    return "enter the valid URL";
                                  }
                                  if (!value.endsWith(".jpeg") &&
                                      !value.endsWith(".jpg") &&
                                      !value.endsWith(".png")) {
                                    return "Please give valid image in jpeg,jpg or png format";
                                  }
                                  return null;
                                }),
                          ),
                        ],
                      )
                    ],
                  )),
            ),
    );
  }
}
