import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CartItem {
  final String title;
  final String id;
  final int quantity;
  final double price;

  CartItem({
    this.title,
    this.id,
    this.quantity,
    this.price,
  });
}

class Cart with ChangeNotifier {
  Map<String, CartItem> items = {};

  Map<String, CartItem> get aitems {
    return {...items};
  }

  int get itemCount {
    return items.length;
  }

  double get totalAmount {
    var total = 0.0;
    items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  void addItems(String prodId, String title, double price) {
    if (items.containsKey(prodId)) {
      items.update(
        prodId,
        (existingCartItem) => CartItem(
            id: existingCartItem.id,
            title: existingCartItem.title,
            price: existingCartItem.price,
            quantity: existingCartItem.quantity + 1),
      );
    } else {
      items.putIfAbsent(
        prodId,
        () => CartItem(
          id: DateTime.now().toString(),
          title: title,
          price: price,
          quantity: 1,
        ),
      );
    }
    notifyListeners();
  }

  void removeItem(String prodId) {
    items.remove(prodId);
    notifyListeners();
  }

  void removeSingleItem(String prodId) {
    if (!items.containsKey(prodId)) {
      return;
    }
    if (items[prodId].quantity > 1) {
      items.update(
        prodId,
        (existingCartItem) => CartItem(
          id: existingCartItem.id,
          title: existingCartItem.title,
          price: existingCartItem.price,
          quantity: existingCartItem.quantity - 1,
        ),
      );
    } else {
      items.remove(prodId);
    }
    notifyListeners();
  }

  void clear() {
    items = {};
    notifyListeners();
  }
}
