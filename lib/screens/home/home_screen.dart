import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/app_constants.dart';
import '../../providers/product_provider.dart';
import '../../core/services/assets_manager.dart';
import '../../core/widgets/app_name_text.dart';
import 'widgets/ctg_rounded_widget.dart';
import 'widgets/latest_arrival.dart';
import '../../core/widgets/title_text.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final productProvider = Provider.of<ProductProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const AppNameTextWidget(fontSize: 20),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(AssetsManager.shoppingCart),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: size.height * 0.24,
                child: ClipRRect(
                  child: Swiper(
                    itemBuilder: (BuildContext context, int index) {
                      return Image.asset(
                        AppConstants.bannersImages[index],
                        fit: BoxFit.fill,
                      );
                    },
                    autoplay: true,
                    itemCount: AppConstants.bannersImages.length,
                    pagination: const SwiperPagination(
                      alignment: Alignment.bottomCenter,
                      builder: DotSwiperPaginationBuilder(
                        color: Colors.white,
                        activeColor: Colors.red,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 18,
              ),
          Visibility(
            visible: productProvider.getProduct.isNotEmpty,
              child: const TitlesTextWidget(
                label: "Latest arrival",
                fontSize: 22,
              ),),
              const SizedBox(
                height: 18,
              ),
              Visibility(
                visible: productProvider.getProduct.isNotEmpty,
                child: SizedBox(
                  height: size.height * 0.2,
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount:productProvider.getProduct.length<10?
                      productProvider.getProduct.length: 10,
                      itemBuilder: (context, index) {
                        return ChangeNotifierProvider.value(
                            value: productProvider.getProduct[index],
                            child: const LatestArrivalProductsWidget());
                      }),
                ),
              ),
              const SizedBox(
                height: 18,
              ),
              const TitlesTextWidget(
                label: "Categories",
                fontSize: 22,
              ),
              const SizedBox(
                height: 18,
              ),
              GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 4,
                  children: List.generate(AppConstants.categoriesList.length,
                      (index) {
                    return CategoryRoundedWidget(
                      image: AppConstants.categoriesList[index].image,
                      name: AppConstants.categoriesList[index].name,
                    );
                  }))
            ],
          ),
        ),
      ),
    );
  }
}
