
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smart_shop/screens/root_screen.dart';
import 'package:smart_shop/core/widgets/app_name_text.dart';

import '../auth/login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);


  @override
  State<SplashScreen> createState() => _SplashScreenState();
}


class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
        // bool? onBoarding = CacheNetwork.getData(key: "onBoarding");
        final auth=FirebaseAuth.instance;
        User? user=auth.currentUser;

        if (user != null) {

            return RootScreen();
        } else {
          return const LoginScreen();
        }
      }
      ));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
         Expanded(child: Center(child: AppNameTextWidget())),
           

            Text(
           "Made by ahmed tarek", style: TextStyle(color: Theme.of(context).textTheme.bodySmall!.color),)
        ],
      ),
    );
  }
}
