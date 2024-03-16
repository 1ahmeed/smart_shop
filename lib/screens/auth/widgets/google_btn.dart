import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ionicons/ionicons.dart';

import '../../root_screen.dart';
import '../../../core/services/my_app_method.dart';

class GoogleButton extends StatelessWidget {
  const GoogleButton({super.key});
  // Future<void> _goolgeSignIn({required BuildContext context}) async {
  //   final googleSignIn = GoogleSignIn();
  //   final googleAccount = await googleSignIn.signIn();
  //   if (googleAccount != null) {
  //     final googleAuth = await googleAccount.authentication;
  //     if (googleAuth.accessToken != null && googleAuth.idToken != null) {
  //       try {
  //         final authResults = await FirebaseAuth.instance
  //             .signInWithCredential(GoogleAuthProvider.credential(
  //           accessToken: googleAuth.accessToken,
  //           idToken: googleAuth.idToken,
  //         ));
  //         WidgetsBinding.instance.addPostFrameCallback((_) async {
  //           Navigator.pushReplacementNamed(context, RootScreen.routName);
  //         });
  //       } on FirebaseException catch (error) {
  //         WidgetsBinding.instance.addPostFrameCallback((_) async {
  //           await MyAppMethods.showErrorORWarningDialog(
  //             context: context,
  //             subtitle: "An error has been occured ${error.message}",
  //             fct: () {},
  //           );
  //         });
  //       } catch (error) {
  //         WidgetsBinding.instance.addPostFrameCallback((_) async {
  //           await MyAppMethods.showErrorORWarningDialog(
  //             context: context,
  //             subtitle: "An error has been occured $error",
  //             fct: () {},
  //           );
  //         });
  //       }
  //     }
  //   }
  // }
  Future signInWithGoogle({required context}) async {
    try {

      FirebaseAuth _auth = FirebaseAuth.instance;
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      // Create a new credential
      final credential =
          GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      final UserCredential authResult =
      await _auth.signInWithCredential(credential);

      // final User? user = authResult.user;
      if(authResult.additionalUserInfo!.isNewUser){
        await FirebaseFirestore.instance.collection("users").doc(authResult.user!.uid).set(
            {
              "userId": authResult.user!.uid,
              "userName":authResult.user!.displayName,
              "userImage": authResult.user!.photoURL,
              "userEmail":authResult.user!.email,
              "userCart": [],
              "userWish": [],
              "createdAt": Timestamp.now()
            });
      }


      // Once signed in, return the UserCredential
      Navigator.pushReplacementNamed(context, RootScreen.routName);
      return await FirebaseAuth.instance.signInWithCredential(credential);
    }  catch (e) {
      print(e.toString());
    }
  }


  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(12),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            10,
          ),
        ),
      ),
      icon: const Icon(
        Ionicons.logo_google,
        color: Colors.red,
      ),
      label: const Text(
        "Sign in with google",
        style: TextStyle(
          fontSize: 16.0,
          color: Colors.black,
        ),
      ),
      onPressed: () async {
        signInWithGoogle(context: context);
      },
    );
  }
}
