import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:smart_shop/models/cart_model.dart';
import 'package:smart_shop/providers/product_provider.dart';
import 'package:uuid/uuid.dart';

import '../core/services/my_app_method.dart';
import '../models/product_model.dart';

class CartProvider with ChangeNotifier {
  final Map<String, CartModel> _cartItem = {};

  Map<String, CartModel> get getCartItem {
    return _cartItem;
  }

  bool isProductIdInCart({required String productId}) {
    return _cartItem.containsKey(productId);
  }

  void addProductToCart({required String productId}) {
    ///put product  in cart if there is not
    _cartItem.putIfAbsent(
        productId,
        () => CartModel(
            cartId: const Uuid().v4(), productId: productId, quantity: 1));
    notifyListeners();
  }

  void updateCartQuantity({required String productId, required int quantity}) {
    _cartItem.update(
      productId,
      (item) => CartModel(
        cartId: item.productId,
        productId: productId,
        quantity: quantity,
      ),
    );
    notifyListeners();
  }

  double getTotal({required ProductProvider productProvider}) {
    double total = 0.0;
    _cartItem.forEach((key, value) {
      final ProductModel? getCurrProduct =
          productProvider.findByProdId(value.productId);
      if (getCurrProduct == null) {
        total += 0;
      } else {
        total += double.parse(getCurrProduct.productPrice) * value.quantity;
      }
    });
    return total;
  }

  int getQty() {
    int total = 0;
    _cartItem.forEach((key, value) {
      total += value.quantity;
    });
    return total;
  }

  void removeOneItem({required String productId}) {
    _cartItem.remove(productId);
    notifyListeners();
  }

  void clearLocalCart() {
    _cartItem.clear();
    notifyListeners();
  }

  ///firebase
  final userFromDB = FirebaseFirestore.instance.collection("users");
  final auth = FirebaseAuth.instance;

  Future<void> addToCartFirebase(
      {required String productId,
      required int quantity,
      required BuildContext context}) async {
    final User? user = auth.currentUser;
    if (user == null) {
      MyAppMethods.showErrorORWarningDialog(
          context: context, subtitle: "Login to can access", fct: () {});
      return;
    }
    final uId = user.uid;
    final cartId = const Uuid().v4();
    try {
      userFromDB.doc(uId).update({
        "userCart": FieldValue.arrayUnion([
          {
            "cartId": cartId,
            "productId": productId,
            "qty": quantity,
          }
        ]),
      });
      await fetchCart();
      Fluttertoast.showToast(
          msg: "Item has been added to cart", backgroundColor: Colors.green);
    } catch (error) {
      rethrow;
    }
  }

  Future<void> fetchCart() async {
    final User? user = auth.currentUser;
    if (user == null) {
      _cartItem.clear();
      return;
    }
    try {
      final userDoc = await userFromDB.doc(user.uid).get();
      final data = userDoc.data();
      if (data == null || !data.containsKey("userCart")) {
        return;
      }
      final lengthOfUserCart = userDoc.get("userCart").length;
      for (int index = 0; index < lengthOfUserCart; index++) {
        _cartItem.putIfAbsent(
            userDoc.get("userCart")[index]["productId"],
            () => CartModel(
                cartId: userDoc.get("userCart")[index]["cartId"],
                productId: userDoc.get("userCart")[index]["productId"],
                quantity: userDoc.get("userCart")[index]["qty"]));
      }
      // Fluttertoast.showToast(
      //     msg: "Item has been added to cart", backgroundColor: Colors.green);
    } catch (error) {
      rethrow;
    }
    notifyListeners();
  }

  Future<void> removeCartItemFromFirebase(
      {required String productId,
      required String cartId,
      required int quantity}) async {
    final User? user = auth.currentUser;
    if (user == null) {
      _cartItem.clear();
      return;
    }
    try {
      await userFromDB.doc(user.uid).update({
        "userCart": FieldValue.arrayRemove([
          {
            "cartId": cartId,
            "productId": productId,
            "qty": quantity,
          }
        ]),
      });
      _cartItem.remove(productId);
      await fetchCart();
    } catch (error) {
      rethrow;
    }
    notifyListeners();
  }

  Future<void> clearCartFromFirebase() async {
    final User? user = auth.currentUser;
    if (user == null) {
      _cartItem.clear();
      return;
    }
    try {
      await userFromDB.doc(user.uid).update({"userCart": []});
      _cartItem.clear();
    } catch (error) {
      rethrow;
    }
    notifyListeners();
  }
}
