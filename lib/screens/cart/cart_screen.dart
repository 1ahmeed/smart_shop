import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_shop/providers/product_provider.dart';
import 'package:smart_shop/providers/user_provider.dart';
import 'package:smart_shop/screens/root_screen.dart';
import 'package:smart_shop/core/widgets/loading_manager.dart';
import 'package:smart_shop/core/services/my_app_method.dart';
import 'package:uuid/uuid.dart';

import '../../models/cart_model.dart';
import '../../providers/cart_provider.dart';
import '../../core/services/assets_manager.dart';
import '../../core/widgets/empty_bag.dart';
import '../../core/widgets/title_text.dart';
import 'bottom_checkout.dart';
import 'cart_widget.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
   bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context,listen: false);
    final userProvider = Provider.of<UserProvider>(context,listen: false);

    return cartProvider.getCartItem.isEmpty
        ? Scaffold(
      body: EmptyBagWidget(
        imagePath: AssetsManager.shoppingBasket,
        function: () {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const RootScreen(),
              ));
        },
        title: "Your cart is empty",
        subtitle:
        'Looks like you didn\'t add anything yet to your cart \ngo ahead and start shopping now',
        buttonText: "Shop Now",
      ),
    )
        : Scaffold(
      bottomSheet: CartBottomCheckout(
        function: () async {
          await placeOrder(
            cartProvider:cartProvider,
            productProvider:productProvider,
            userProvider:userProvider,);
        },
      ),
      appBar: AppBar(
        title: TitlesTextWidget(
            label: "Cart (${cartProvider.getCartItem.length})"),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(AssetsManager.shoppingCart),
        ),
        actions: [
          IconButton(
            onPressed: () {
              MyAppMethods.showErrorORWarningDialog(
                  context: context,
                  isError: false,
                  subtitle: "Remove items",
                  fct: () async {
                    // cartProvider.clearLocalCart();
                    await cartProvider.clearCartFromFirebase();
                  });
            },
            icon: const Icon(
              Icons.delete_forever_rounded,
              color: Colors.red,
            ),
          ),
        ],
      ),
      body: LoadingManager(
      isLoading: isLoading,
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: cartProvider.getCartItem.length,
                itemBuilder: (context, index) {
                  return ChangeNotifierProvider.value(
                      value: cartProvider.getCartItem.values
                          .toList()
                          .reversed
                          .toList()[index],
                      child: const CartWidget());
                },
              ),
            ),
            const SizedBox(
              height: kBottomNavigationBarHeight + 10,
            )
          ],
        ),
      ),
    );
  }

  Future<void> placeOrder({
    required CartProvider cartProvider,
    required ProductProvider productProvider,
    required UserProvider userProvider,
  }) async {
    final auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    if (user == null) {
      return;
    }
    final uId = user.uid;
    try{
      setState(() {
        isLoading=true;
      });

      cartProvider.getCartItem.forEach((key, value)async {
        final getCurrProduct=productProvider.findByProdId(value.productId);
        final orderId=const Uuid().v4();
       FirebaseFirestore.instance.collection("orders").doc(orderId).set({
        "orderId":orderId,
        "userId":uId,
         "totalPrice":cartProvider.getTotal(productProvider: productProvider),
        "productId":value.productId,
        "productTitle":getCurrProduct!.productTitle,
        "userName":userProvider.getUserModel!.userName,
        "price":double.parse(getCurrProduct.productPrice)*value.quantity,
        "imageUrl":getCurrProduct.productImage,
        "quantity":value.quantity,
      "orderDate":Timestamp.now(),
       });
      });
      await cartProvider.clearCartFromFirebase();
      // cartProvider.clearLocalCart();
    }catch(e){
      if(!mounted)return;
      MyAppMethods.showErrorORWarningDialog(
          context: context,
          subtitle: e.toString(), fct: (){});
    }finally{
      setState(() {
        isLoading=true;
      });
    }
  }
}
