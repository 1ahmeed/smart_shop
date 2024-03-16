import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_shop/models/product_model.dart';
import 'package:smart_shop/providers/viewed_prod_provider.dart';

import '../../../core/utils/app_constants.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/product_provider.dart';
import 'product_details.dart';
import '../../../core/services/my_app_method.dart';
import '../../../core/widgets/subtitle_text.dart';
import '../../../core/widgets/heart_btn.dart';

class LatestArrivalProductsWidget extends StatelessWidget {
  const LatestArrivalProductsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final productModel = Provider.of<ProductModel>(context);
    final viewedProvider = Provider.of<ViewedProdProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);

    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () async {
          viewedProvider.addProductToHistory(productId: productModel.productId);
          await Navigator.pushNamed(context, ProductDetails.routName,
              arguments: productModel.productId);
        },
        child: SizedBox(
          width: size.width * 0.45,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: FancyShimmerImage(
                    imageUrl: productModel.productImage,
                    width: size.width * 0.28,
                    height: size.width * 0.28,
                  ),
                ),
              ),
              const SizedBox(
                width: 7,
              ),
              Flexible(
                child: Column(
                   mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      productModel.productTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 15,),
                    FittedBox(
                      child: Row(
                        children: [
                          HeartButtonWidget(
                              size: 30,
                              productId: productModel.productId),
                          const SizedBox(
                            width: 20,
                          ),
                          Material(
                            borderRadius: BorderRadius.circular(16.0),
                            color: Colors.blue,
                            child: IconButton(
                              onPressed: () async {
                                if (cartProvider.isProductIdInCart(
                                    productId: productModel.productId)) {
                                  return;
                                }
                                // cartProvider.addProductToCart(productId:getCurrProduct.productId );
                                try {
                                  await cartProvider.addToCartFirebase(
                                      productId: productModel.productId,
                                      quantity: 1,
                                      context: context);
                                } catch (e) {
                                  MyAppMethods.showErrorORWarningDialog(
                                      context: context,
                                      subtitle: e.toString(),
                                      fct: () {});
                                }
                              },
                              icon: Icon(
                                cartProvider.isProductIdInCart(
                                        productId: productModel.productId)
                                    ? Icons.check
                                    : Icons.add_shopping_cart_rounded,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15,),
                    FittedBox(
                      child: SubtitleTextWidget(
                        label: "${productModel.productPrice}\$",
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
