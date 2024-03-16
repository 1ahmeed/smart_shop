import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:provider/provider.dart';
import 'package:smart_shop/core/utils/app_colors.dart';
import 'package:smart_shop/models/user_model.dart';
import 'package:smart_shop/providers/user_provider.dart';
import 'package:smart_shop/screens/auth/login.dart';
import 'package:smart_shop/screens/profile/orders_screen.dart';
import 'package:smart_shop/screens/profile/viewed_recently.dart';
import 'package:smart_shop/core/widgets/loading_manager.dart';
import 'package:smart_shop/screens/profile/wishlist_screen.dart';

import '../../providers/theme_provider.dart';
import '../../core/services/assets_manager.dart';
import '../../core/services/my_app_method.dart';
import '../../core/widgets/app_name_text.dart';
import '../../core/widgets/subtitle_text.dart';
import '../../core/widgets/title_text.dart';
class ProfileScreen extends StatefulWidget {
  static String routName="/ProfileScreen";

  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive =>true;
  User? user=FirebaseAuth.instance.currentUser;
   bool isLoading=true;
   UserModel? userModel;

   @override
  void initState() {
      fetchUserInfo();
      super.initState();
  }

   Future<void> fetchUserInfo()async{
     if(user ==null){
       setState(() {
         isLoading=false;
       });
       return ;
     }
     final userProvider=Provider.of<UserProvider>(context,listen: false);
     try{
        userModel=await userProvider.fetchUserInfo();
     }catch(e){
       if(!mounted)return;
       MyAppMethods.showErrorORWarningDialog(context: context,
           subtitle: "an error has been occurred $e",
           fct: (){});
     }finally{
       setState(() {
         isLoading=false;
       });
     }
   }



  @override
  Widget build(BuildContext context) {
    super.build(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
        appBar: AppBar(
          title: const AppNameTextWidget(fontSize: 20),
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(AssetsManager.shoppingCart),
          ),
        ),
        body: LoadingManager(
          isLoading: isLoading,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Visibility(
                  visible: user ==null ?true:false,
                  child: const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: TitlesTextWidget(
                        label: "Please login to have ultimate access"),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                userModel ==null?const SizedBox.shrink():
                    ///user photo
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Row(
                    children: [
                      Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).cardColor,
                          border: Border.all(
                              color: Theme.of(context).colorScheme.background,
                              width: 3),
                          image:  DecorationImage(
                            image: NetworkImage(
                              userModel!.userImage,
                            ),
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 7,
                      ),
                       Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TitlesTextWidget(label: userModel!.userName),
                          SubtitleTextWidget(label: userModel!.userEmail),
                        ],
                      ),
                    ],
                  ),
                ),
                ///general  & setting
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const TitlesTextWidget(label: "General"),
                      user ==null?const SizedBox.shrink():
                      CustomListTile(
                        imagePath: AssetsManager.orderSvg,
                        text: "All orders",
                        function: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder:
                                  (context) => const  OrdersScreenFree(),));
                        },
                      ),
                      user ==null?const SizedBox.shrink():
                      CustomListTile(
                        imagePath: AssetsManager.wishlistSvg,
                        text: "Wishlist",
                        function: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder:
                                  (context) => const WishlistScreen(),));


                        },
                      ),
                      CustomListTile(
                        imagePath: AssetsManager.recent,
                        text: "Viewed recently",
                        function: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const ViewedRecentlyScreen(),));
                        },
                      ),
                      const Divider(
                        thickness: 1,
                      ),
                      const SizedBox(
                        height: 7,
                      ),
                      const TitlesTextWidget(label: "Settings"),
                      const SizedBox(
                        height: 7,
                      ),
                      SwitchListTile(
                        secondary: Image.asset(
                          AssetsManager.theme,
                          height: 30,
                        ),
                        title: Text(themeProvider.getIsDarkTheme
                            ? "Dark mode"
                            : "Light mode"),
                        value: themeProvider.getIsDarkTheme,
                        onChanged: (value) {
                          themeProvider.setDarkTheme(themeValue: value);
                        },
                      ),
                      const Divider(
                        thickness: 1,
                      ),
                    ],
                  ),
                ),
                ///log out button
                Center(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          30,
                        ),
                      ),
                    ),

                    onPressed: () async{
                      if(user==null) {
                        await Navigator.pushReplacementNamed(context, LoginScreen.routName);
                      }else{
                          MyAppMethods.showErrorORWarningDialog(
                              context: context,
                              subtitle: "Are you sure?",
                              fct: () async{
                                await FirebaseAuth.instance.signOut();
                                if(!mounted)return;
                                 Navigator.pushReplacementNamed(context, LoginScreen.routName);
                              },
                              isError: false);

                      }
                    },

                     icon:  Icon(user==null ?Icons.login:Icons.logout,color: AppColors.lightScaffoldColor),
                    label:  Text(
                      user==null ?"Log in":"Log out",
                      style: const TextStyle(
                        color: AppColors.lightScaffoldColor
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}

class CustomListTile extends StatelessWidget {
  const CustomListTile(
      {super.key,
      required this.imagePath,
      required this.text,
      required this.function});
  final String imagePath, text;
  final Function function;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        function();
      },
      leading: Image.asset(
        imagePath,
        height: 30,
      ),
      title: SubtitleTextWidget(label: text),
      trailing: const Icon(IconlyLight.arrowRight2),
    );
  }
}
