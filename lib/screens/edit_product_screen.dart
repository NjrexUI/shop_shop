import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/products.dart';

import '../providers/product.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = "/edit-product";

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final priceFocusNode = FocusNode();
  final descrFocusNode = FocusNode();
  final imageUrlController = TextEditingController();
  final imageUrlFocusNode = FocusNode();
  final form = GlobalKey<FormState>();
  var editedProduct = Product(
    id: null,
    price: 0,
    title: "",
    description: "",
    imageUrl: "",
  );

  var initValues = {
    "title": "",
    "description": "",
    "price": "",
    "imageUrl": "",
  };
  var isInit = true;
  var isLoading = false;

  @override
  void initState() {
    imageUrlFocusNode.addListener(updateImage);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (isInit) {
      final productId = ModalRoute.of(context).settings.arguments as String;
      if (productId != null) {
        editedProduct =
            Provider.of<Products>(context, listen: false).findById(productId);
        initValues = {
          "title": editedProduct.title,
          "description": editedProduct.description,
          "price": editedProduct.price.toString(),
          // "imageUrl": editedProduct.imageUrl,
          "imageUrl": "",
        };
        imageUrlController.text = editedProduct.imageUrl;
      }
    }
    isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    imageUrlFocusNode.removeListener(updateImage);
    priceFocusNode.dispose();
    descrFocusNode.dispose();
    imageUrlController.dispose();
    imageUrlFocusNode.dispose();
    super.dispose();
  }

  void updateImage() {
    if (!imageUrlFocusNode.hasFocus) {
      setState(() {});
    }
  }

  void saveForm() {
    final isValid = form.currentState.validate();
    if (!isValid) {
      return;
    }
    form.currentState.save();
    setState(() {
      isLoading = true;
    });
    if (editedProduct.id != null) {
      Provider.of<Products>(context, listen: false)
          .updateProduct(editedProduct.id, editedProduct);
      setState(() {
        isLoading = false;
      });
      Navigator.of(context).pop();
    } else {
      Provider.of<Products>(context, listen: false)
          .addProduct(editedProduct)
          .catchError((error) {
        return showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text("An error occured!"),
            content: Text("Something went worng!"),
            actions: <Widget>[
              FlatButton(
                child: Text("Okay"),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              ),
            ],
          ),
        );
      }).then((_) {
        setState(() {
          isLoading = false;
        });
        Navigator.of(context).pop();
      });
    }
    // Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Your Product"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              saveForm();
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: form,
                child: ListView(
                  children: <Widget>[
                    TextFormField(
                      initialValue: initValues["title"],
                      decoration: InputDecoration(labelText: "Title"),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(priceFocusNode);
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return "Pease input the text!";
                        }
                        return null;
                      },
                      onSaved: (value) {
                        editedProduct = Product(
                          title: value,
                          price: editedProduct.price,
                          description: editedProduct.description,
                          imageUrl: editedProduct.imageUrl,
                          id: editedProduct.id,
                          isFavourite: editedProduct.isFavourite,
                        );
                      },
                    ),
                    TextFormField(
                      initialValue: initValues["price"],
                      decoration: InputDecoration(labelText: "Price"),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      focusNode: priceFocusNode,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(descrFocusNode);
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return "Please input the price!";
                        }
                        if (double.tryParse(value) == null) {
                          return "Please input the valid number!";
                        }
                        if (double.parse(value) <= 0) {
                          return "Please input the number greater than zero!";
                        }
                        return null;
                      },
                      onSaved: (value) {
                        editedProduct = Product(
                          title: editedProduct.title,
                          price: double.parse(value),
                          description: editedProduct.description,
                          imageUrl: editedProduct.imageUrl,
                          id: editedProduct.id,
                          isFavourite: editedProduct.isFavourite,
                        );
                      },
                    ),
                    TextFormField(
                      initialValue: initValues["description"],
                      decoration: InputDecoration(labelText: "Description"),
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      focusNode: descrFocusNode,
                      validator: (value) {
                        if (value.isEmpty) {
                          return "Please input the description!";
                        }
                        if (value.length < 10) {
                          return "Description should be at least 10 chatacters long!";
                        }
                        return null;
                      },
                      onSaved: (value) {
                        editedProduct = Product(
                          title: editedProduct.title,
                          price: editedProduct.price,
                          description: value,
                          imageUrl: editedProduct.imageUrl,
                          id: editedProduct.id,
                          isFavourite: editedProduct.isFavourite,
                        );
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Container(
                          width: 100,
                          height: 100,
                          margin: EdgeInsets.only(
                            top: 8,
                            right: 10,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: Colors.grey,
                            ),
                          ),
                          child: imageUrlController.text.isEmpty
                              ? Text("Enter a URL")
                              : FittedBox(
                                  child: Image.network(
                                    imageUrlController.text,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(labelText: "Image URL"),
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            controller: imageUrlController,
                            focusNode: imageUrlFocusNode,
                            onFieldSubmitted: (_) {
                              saveForm();
                            },
                            validator: (value) {
                              if (value.isEmpty) {
                                return "Please input the URL";
                              }
                              if (!value.startsWith("http") &&
                                  !value.startsWith("https")) {
                                return "Please input a valid URl";
                              }
                              if (!value.endsWith(".png") &&
                                  !value.endsWith(".jpg") &&
                                  !value.endsWith(".jpeg")) {
                                return "Plese input a valid image URL";
                              }
                              return null;
                            },
                            onSaved: (value) {
                              editedProduct = Product(
                                title: editedProduct.title,
                                price: editedProduct.price,
                                description: editedProduct.description,
                                imageUrl: value,
                                id: editedProduct.id,
                                isFavourite: editedProduct.isFavourite,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
