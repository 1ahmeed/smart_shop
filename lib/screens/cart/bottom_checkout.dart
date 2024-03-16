import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../core/widgets/subtitle_text.dart';
import '../../core/widgets/title_text.dart';

class CartBottomCheckout extends StatelessWidget {
  const CartBottomCheckout({super.key, required this.function});
final Function function;
  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: const Border(
          top: BorderSide(width: 1, color: Colors.grey),
        ),
      ),
      child: SizedBox(
        height: kBottomNavigationBarHeight + 10,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                        child: TitlesTextWidget(
                          fontSize: 15,
                            label: "Total (${cartProvider.getCartItem.length} products/${cartProvider.getQty()} Items)")),
                     Expanded(
                      child: SubtitleTextWidget(
                        label: "${cartProvider.getTotal(productProvider: productProvider)}\$",
                        // fontSize: 10,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: ()async {
                  await function();
                },
                child: const Text("Checkout"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
