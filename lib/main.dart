import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_shop/providers/cart_provider.dart';
import 'package:smart_shop/providers/order_provider.dart';
import 'package:smart_shop/providers/product_provider.dart';
import 'package:smart_shop/providers/theme_provider.dart';
import 'package:smart_shop/providers/user_provider.dart';
import 'package:smart_shop/providers/viewed_prod_provider.dart';
import 'package:smart_shop/providers/wishlist_provider.dart';
import 'package:smart_shop/screens/auth/forgot_password.dart';
import 'package:smart_shop/screens/auth/login.dart';
import 'package:smart_shop/screens/auth/register.dart';
import 'package:smart_shop/screens/profile/orders_screen.dart';
import 'package:smart_shop/screens/profile/viewed_recently.dart';
import 'package:smart_shop/screens/search/search_screen.dart';
import 'package:smart_shop/screens/profile/wishlist_screen.dart';
import 'package:smart_shop/screens/splash/splash_screen.dart';

import 'core/utils/theme_data.dart';
import 'firebase_options.dart';
import 'screens/root_screen.dart';
import 'screens/home/widgets/product_details.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ProductProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => CartProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => WishlistProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ViewedProdProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => OrdersProvider(),
        ),
      ],
      child: Consumer<ThemeProvider>(builder: (
          context,
          themeProvider,
          child,
          ) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: Styles.themeData(
              isDarkTheme: themeProvider.getIsDarkTheme, context: context),
          home: const SplashScreen(),
          routes: {
            ProductDetails.routName: (context) => const ProductDetails(),
            WishlistScreen.routName: (context) => const WishlistScreen(),
            ViewedRecentlyScreen.routName: (context) => const ViewedRecentlyScreen(),
            RegisterScreen.routName: (context) => const RegisterScreen(),
            LoginScreen.routName: (context) => const LoginScreen(),
            SearchScreen.routName: (context) => const SearchScreen(),
            OrdersScreenFree.routeName: (context) => const OrdersScreenFree(),
            ForgotPasswordScreen.routeName: (context) => const ForgotPasswordScreen(),
            RootScreen.routName: (context) => const RootScreen(),
          },
        );
      }),
    );
  }
}
