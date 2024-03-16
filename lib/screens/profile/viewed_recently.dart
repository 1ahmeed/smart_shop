import 'package:dynamic_height_grid_view/dynamic_height_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/viewed_prod_provider.dart';
import '../../core/services/assets_manager.dart';
import '../../core/widgets/empty_bag.dart';
import '../../core/widgets/product_widget.dart';
import '../../core/widgets/title_text.dart';

class ViewedRecentlyScreen extends StatelessWidget {
  static const routName = '/ViewedRecentlyScreen';
  const ViewedRecentlyScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final viewedProvider=Provider.of<ViewedProdProvider>(context);

    return viewedProvider.getViewedProdItems.isEmpty
        ? Scaffold(
            body: EmptyBagWidget(
              imagePath: AssetsManager.shoppingBasket,
              title: "Your Viewed recently is empty",
              subtitle:
                  'Looks like you didn\'t add anything yet to your cart \ngo ahead and start shopping now',
              buttonText: "Shop Now",
            ),
          )
        : Scaffold(
            appBar: AppBar(
              title:  TitlesTextWidget(label: "Viewed recently (${viewedProvider.getViewedProdItems.length})"),
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(AssetsManager.shoppingCart),
              ),
              // actions: [
              //   IconButton(
              //     onPressed: () {},
              //     icon: const Icon(
              //       Icons.delete_forever_rounded,
              //       color: Colors.red,
              //     ),
              //   ),
              // ],
            ),
            body: DynamicHeightGridView(
              itemCount: viewedProvider.getViewedProdItems.length,
              builder: ((context, index) {
                return  Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ProductWidget(
                    productId:  viewedProvider.getViewedProdItems.values.toList()[index].productId,
                  ),
                );
              }),
              crossAxisCount: 2,
            ),
          );
  }
}
