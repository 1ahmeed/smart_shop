import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_shop/providers/product_provider.dart';
import 'package:smart_shop/core/services/my_app_method.dart';
import '../../providers/cart_provider.dart';
import '../../providers/viewed_prod_provider.dart';
import '../../screens/home/widgets/product_details.dart';
import 'subtitle_text.dart';
import 'title_text.dart';
import 'heart_btn.dart';

class ProductWidget extends StatefulWidget {
  const ProductWidget({super.key,  this.productId});
final String? productId;
  @override
  State<ProductWidget> createState() => _ProductWidgetState();
}

class _ProductWidgetState extends State<ProductWidget> {
  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final getCurrProduct=productProvider.findByProdId(widget.productId!);
    final cartProvider = Provider.of<CartProvider>(context);
    final viewedProvider=Provider.of<ViewedProdProvider>(context);


    Size size = MediaQuery.of(context).size;
    return getCurrProduct == null? const SizedBox.shrink():Padding(
      padding: const EdgeInsets.all(3.0),
      child: GestureDetector(
        onTap: () async {
          viewedProvider.addProductToHistory(productId: getCurrProduct.productId);

          await Navigator.pushNamed(context, ProductDetails.routName,arguments: getCurrProduct.productId);
        },
        child: Column(
          children: [
            /// image product
            ClipRRect(
              borderRadius: BorderRadius.circular(30.0),
              child: FancyShimmerImage(
                imageUrl: getCurrProduct.productImage,
                width: double.infinity,
                height: size.height * 0.22,
              ),
            ),
            const SizedBox(
              height: 15.0,
            ),
            ///product title
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Flexible(
                  flex: 4,
                  child: TitlesTextWidget(
                    label: getCurrProduct.productTitle,
                    maxLines: 2,
                    fontSize: 18,
                  ),
                ),
                 // SizedBox(width: 90),
                // Spacer(),
                Flexible(
                  flex: 2,
                  child: HeartButtonWidget(productId:getCurrProduct.productId),
                ),
              ],
            ),
            const SizedBox(
              height: 15.0,
            ),
            ///product price
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Flexible(
                    flex: 3,
                    child: SubtitleTextWidget(label: "${getCurrProduct.productPrice}\$"),
                  ),
                  Flexible(
                    child: Material(
                      borderRadius: BorderRadius.circular(16.0),
                      color: Colors.lightBlue,
                      child: InkWell(
                        splashColor: Colors.red,
                        borderRadius: BorderRadius.circular(16.0),
                        onTap: ()async {
                          if(cartProvider.isProductIdInCart(productId: getCurrProduct.productId)){
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
                        child:  Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                           cartProvider.isProductIdInCart(productId: getCurrProduct.productId)?
                           Icons.check:
                           Icons.add_shopping_cart_rounded,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // SizedBox(
                  //   width: 1,
                  // ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }
}
