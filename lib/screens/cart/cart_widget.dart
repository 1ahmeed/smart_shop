import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:provider/provider.dart';
import 'package:smart_shop/models/cart_model.dart';
import 'package:smart_shop/screens/cart/quantity_btm_sheet.dart';

import '../../core/utils/app_constants.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../core/widgets/subtitle_text.dart';
import '../../core/widgets/title_text.dart';
import '../../core/widgets/heart_btn.dart';

class CartWidget extends StatelessWidget {
  const CartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final cartModelProvider = Provider.of<CartModel>(context);
    final productProvider = Provider.of<ProductProvider>(context);
    final getCurrProduct = productProvider.findByProdId(
        cartModelProvider.productId);
    final cartProvider = Provider.of<CartProvider>(context);

    Size size = MediaQuery
        .of(context)
        .size;
    return getCurrProduct == null ? const SizedBox.shrink() : FittedBox(
      child: IntrinsicWidth(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [

              ///image of product in cart
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: FancyShimmerImage(
                  imageUrl: getCurrProduct.productImage,
                  height: size.height * 0.2,
                  width: size.height * 0.2,
                ),
              ),
              const SizedBox(
                width: 10.0,
              ),
              IntrinsicWidth(
                child: Column(
                  children: [

                    ///name of product in cart
                    Row(
                      children: [
                        SizedBox(
                          width: size.width * 0.6,
                          child: TitlesTextWidget(
                            label: getCurrProduct.productTitle,
                            maxLines: 2,
                          ),
                        ),
                        Column(
                          children: [
                            IconButton(
                              onPressed: () async {
                                // cartProvider.removeOneItem(productId: getCurrProduct.productId);
                                cartProvider.removeCartItemFromFirebase(
                                    productId: getCurrProduct.productId,
                                    cartId:  cartModelProvider.cartId,
                                    quantity:  cartModelProvider.quantity);
                              },
                              icon: const Icon(
                                Icons.clear,
                                color: Colors.red,
                              ),
                            ),
                            HeartButtonWidget(
                              productId: getCurrProduct.productId,
                            )
                          ],
                        ),
                      ],
                    ),

                    ///price of product in cart
                    Row(
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SubtitleTextWidget(
                          label: "${getCurrProduct.productPrice}\$",
                          fontSize: 20,
                          color: Colors.blue,
                        ),
                        const Spacer(),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            side: const BorderSide(
                              width: 2,
                              color: Colors.blue,
                            ),
                          ),
                          onPressed: () async {
                            await showModalBottomSheet(
                              backgroundColor:
                              Theme
                                  .of(context)
                                  .scaffoldBackgroundColor,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(16.0),
                                  topRight: Radius.circular(16.0),
                                ),
                              ),
                              context: context,
                              builder: (context) {
                                return QuantityBottomSheetWidget(
                                  cartModel: cartModelProvider,
                                );
                              },
                            );
                          },
                          icon: const Icon(IconlyLight.arrowDown2),
                          label: Text("Qty: ${cartModelProvider.quantity} "),
                        ),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
