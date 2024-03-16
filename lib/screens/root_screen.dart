import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:provider/provider.dart';
import 'package:smart_shop/providers/cart_provider.dart';
import 'package:smart_shop/providers/product_provider.dart';
import 'package:smart_shop/providers/user_provider.dart';
import 'package:smart_shop/providers/wishlist_provider.dart';
import 'package:smart_shop/screens/home/home_screen.dart';
import 'package:smart_shop/screens/profile/profile_screen.dart';
import 'package:smart_shop/screens/search/search_screen.dart';

import 'cart/cart_screen.dart';

class RootScreen extends StatefulWidget {
  static String routName = "/RootScreen";

  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  late PageController controller;
  int currentScreen = 0;
  bool isLoadingProds=true;
  List<Widget> screens = [
    const HomeScreen(),
    const SearchScreen(),
    const CartScreen(),
    const ProfileScreen()
  ];

  @override
  void initState() {
    super.initState();
    controller = PageController(
      initialPage: currentScreen,
    );
  }

  Future<void> fetchFct() async {
    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);
    final cartProvider = Provider.of<CartProvider>(context,listen :false);
    final wishlistProvider = Provider.of<WishlistProvider>(context,listen :false);
    final userProvider = Provider.of<UserProvider>(context,listen: false);


    try {
      Future.wait({productProvider.fetchProducts(),userProvider.fetchUserInfo()});
      Future.wait({cartProvider.fetchCart(),wishlistProvider.fetchWishlist()});
    } catch (error) {
      log(error.toString());
    } finally {
      setState(() {
        isLoadingProds=false;
      });
    }
  }

  @override
  void didChangeDependencies() {
    if(isLoadingProds){
      fetchFct();
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      body: PageView(
        controller: controller,
        physics: const NeverScrollableScrollPhysics(),
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentScreen,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 2,
        height: kBottomNavigationBarHeight,
        onDestinationSelected: (index) {
          setState(() {
            currentScreen = index;
          });
          controller.jumpToPage(currentScreen);
        },
        destinations: [
          const NavigationDestination(
            selectedIcon: Icon(IconlyBold.home),
            icon: Icon(IconlyLight.home),
            label: "Home",
          ),
          const NavigationDestination(
            selectedIcon: Icon(IconlyBold.search),
            icon: Icon(IconlyLight.search),
            label: "Search",
          ),
          NavigationDestination(
            selectedIcon: const Icon(IconlyBold.bag2),
            icon: Badge(
                backgroundColor: Colors.blue,
                label: Text("${cartProvider.getCartItem.length}"),
                child: const Icon(IconlyLight.bag2)),
            label: "Cart",
          ),
          const NavigationDestination(
            selectedIcon: Icon(IconlyBold.profile),
            icon: Icon(IconlyLight.profile),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
