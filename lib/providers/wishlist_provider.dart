import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uuid/uuid.dart';

import '../core/services/my_app_method.dart';
import '../models/wishlist_model.dart';

class WishlistProvider with ChangeNotifier {
  final Map<String, WishlistModel> _wishlistItems = {};

  Map<String, WishlistModel> get getWishlistItems {
    return _wishlistItems;
  }

  bool isProductInWishlist({required String productId}) {
    return _wishlistItems.containsKey(productId);
  }

  void addOrRemoveFromWishlist({required String productId}) {
    if (_wishlistItems.containsKey(productId)) {
      _wishlistItems.remove(productId);
    } else {
      _wishlistItems.putIfAbsent(
        productId,
        () => WishlistModel(
          id: const Uuid().v4(),
          productId: productId,
        ),
      );
    }

    notifyListeners();
  }

  void clearLocalWishlist() {
    _wishlistItems.clear();
    notifyListeners();
  }

  ///firebase
  final userFromDB = FirebaseFirestore.instance.collection("users");
  final auth = FirebaseAuth.instance;

  Future<void> addToWishlistFirebase(
      {required String productId,
        required BuildContext context}) async {
    final User? user = auth.currentUser;
    if (user == null) {
      MyAppMethods.showErrorORWarningDialog(
          context: context, subtitle: "Login to can access", fct: () {});
      return;
    }
    final uId = user.uid;
    final wishlistId = const Uuid().v4();
    try {
      userFromDB.doc(uId).update({
        "userWish": FieldValue.arrayUnion([
          {
            "wishlistId": wishlistId,
            "productId": productId,
          }
        ]),
      });
      await fetchWishlist();
      Fluttertoast.showToast(
          msg: "Item has been added to wishlist", backgroundColor: Colors.green);
    } catch (error) {
      rethrow;
    }
  }

  Future<void> fetchWishlist() async {
    final User? user = auth.currentUser;
    if (user == null) {
      _wishlistItems.clear();
      return;
    }
    try {
      final userDoc = await userFromDB.doc(user.uid).get();
      final data = userDoc.data();
      if (data == null || !data.containsKey("userWish")) {
        return;
      }
      final lengthOfUserWishlist = userDoc.get("userWish").length;
      for (int index = 0; index < lengthOfUserWishlist; index++) {
        _wishlistItems.putIfAbsent(
            userDoc.get("userWish")[index]["productId"],
                () => WishlistModel(
                  id:  userDoc.get("userWish")[index]["wishlistId"],
                productId: userDoc.get("userWish")[index]["productId"],
               ));
      }
      // Fluttertoast.showToast(
      //     msg: "Item has been added to wishlist", backgroundColor: Colors.green);
    } catch (error) {
      rethrow;
    }
    notifyListeners();
  }

  Future<void> removeWishlistItemFromFirebase(
      {required String productId,
        required String wishlistId,
        }) async {
    final User? user = auth.currentUser;
    if (user == null) {
      _wishlistItems.clear();
      return;
    }
    try {
      await userFromDB.doc(user.uid).update({
        "userWish": FieldValue.arrayRemove([
          {
            "wishlistId": wishlistId,
            "productId": productId,

          }
        ]),
      });
      _wishlistItems.remove(productId);
      // await fetchWishlist();
    } catch (error) {
      rethrow;
    }
    notifyListeners();
  }

  Future<void> clearWishlistFromFirebase() async {
    final User? user = auth.currentUser;
    if (user == null) {
      _wishlistItems.clear();
      return;
    }
    try {
      await userFromDB.doc(user.uid).update({"userWish": []});
      _wishlistItems.clear();
    } catch (error) {
      rethrow;
    }
    notifyListeners();
  }
}
