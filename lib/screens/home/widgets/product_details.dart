import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_shop/core/utils/app_colors.dart';

import '../../../core/utils/app_constants.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/product_provider.dart';
import '../../../core/services/my_app_method.dart';
import '../../../core/widgets/app_name_text.dart';
import '../../../core/widgets/subtitle_text.dart';
import '../../../core/widgets/title_text.dart';
import '../../../core/widgets/heart_btn.dart';

class ProductDetails extends StatefulWidget {
  static const routName = '/ProductDetails';

  const ProductDetails({super.key});

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);
    var productId = ModalRoute.of(context)!.settings.arguments as String?;
    final getCurrProduct = productProvider.findByProdId(productId!);
    final cartProvider = Provider.of<CartProvider>(context);

    return getCurrProduct == null
        ? const SizedBox.shrink()
        : Scaffold(
            appBar: AppBar(
              title: const AppNameTextWidget(fontSize: 20),
              centerTitle: true,
              leading: IconButton(
                  onPressed: () {
                    Navigator.canPop(context) ? Navigator.pop(context) : null;
                  },
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    size: 18,
                  )),
              // automaticallyImplyLeading: false,
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  ///product image
                  FancyShimmerImage(
                    imageUrl: getCurrProduct.productImage,
                    height: size.height * 0.38,
                    width: double.infinity,
                    boxFit: BoxFit.contain,
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        ///product image and price
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(
                              // flex: 5,
                              child: Text(
                                getCurrProduct.productTitle,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 14,
                            ),
                            SubtitleTextWidget(
                              label: "${getCurrProduct.productPrice}\$",
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 25,
                        ),

                        ///btn heart and add cart
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              HeartButtonWidget(
                                productId: getCurrProduct.productId,
                                color: Colors.blue.shade300,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: SizedBox(
                                  height: kBottomNavigationBarHeight - 10,
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.lightBlue,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          30,
                                        ),
                                      ),
                                    ),
                                    onPressed: () async{
                                      if(cartProvider.isProductIdInCart
                                        (productId: getCurrProduct.productId)){
                                        return;
                                      }
                                      // cartProvider.addProductToCart(productId:getCurrProduct.productId );
                                      try {
                                        await cartProvider.addToCartFirebase(
                                            productId: getCurrProduct.productId,
                                            quantity: 1,
                                            context: context);
                                      }  catch (e) {
                                        if(!mounted)return;
                                        MyAppMethods.showErrorORWarningDialog(
                                            context: context,
                                            subtitle: e.toString(), fct: (){});
                                      }
                                    },
                                    icon:Icon(
                                      cartProvider.isProductIdInCart(productId: getCurrProduct.productId)?
                                      Icons.check:
                                      Icons.add_shopping_cart,

                                      color: AppColors.white,
                                    ),
                                    label: Text(
                                      cartProvider.isProductIdInCart(productId: getCurrProduct.productId)?
                                      "in Cart":
                                       "Add to cart",
                                      style:const TextStyle(color: AppColors.white),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 25,
                        ),

                        ///product category
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const TitlesTextWidget(label: "About this item"),
                            SubtitleTextWidget(
                                label: getCurrProduct.productCategory)
                          ],
                        ),
                        const SizedBox(
                          height: 25,
                        ),

                        ///product description
                        SubtitleTextWidget(
                            label: getCurrProduct.productDescription),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
  }
}
