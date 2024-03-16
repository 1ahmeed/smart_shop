import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:smart_shop/core/utils/app_colors.dart';
import 'package:smart_shop/screens/root_screen.dart';
import 'package:smart_shop/screens/auth/register.dart';
import 'package:smart_shop/core/widgets/loading_manager.dart';
import '../../core/utils/my_validators.dart';
import '../../core/services/my_app_method.dart';
import '../../core/widgets/app_name_text.dart';
import 'widgets/google_btn.dart';
import '../../core/widgets/subtitle_text.dart';
import '../../core/widgets/title_text.dart';
import 'forgot_password.dart';

class LoginScreen extends StatefulWidget {
  static const routName = '/LoginScreen';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final FocusNode _emailFocusNode;
  late final FocusNode _passwordFocusNode;
  late final _formKey = GlobalKey<FormState>();
  bool obscureText = true;
  bool isLoading= false;
  final auth=FirebaseAuth.instance;

  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    // Focus Nodes
    _emailFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    // Focus Nodes
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loginFct() async {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    if (isValid) {
      try{
        setState(() {
          isLoading=true;
        });
        await auth.signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim());
        Navigator.pushReplacementNamed(context,RootScreen.routName);

        Fluttertoast.showToast(
            msg: "Log in successfully",
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0
        );
        // if(!mounted)return;

      }on FirebaseAuthException catch(e){
        MyAppMethods.showErrorORWarningDialog(context: context,
            subtitle: "error has been occurred ${e.message}",
            fct: (){});
      } catch(e){
        MyAppMethods.showErrorORWarningDialog(context: context,
            subtitle: "an error has been occurred $e",
            fct: (){});
      }finally{
        setState(() {
          isLoading=false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: LoadingManager(
          isLoading: isLoading,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 60.0,
                  ),
                  ///headers
                  const AppNameTextWidget(
                    fontSize: 30,
                  ),
                  const SizedBox(
                    height: 50.0,
                  ),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: TitlesTextWidget(label: "Welcome back"),
                  ),
                  const SizedBox(
                    height: 1.0,
                  ),
                   const Align(
                    alignment: Alignment.centerLeft,
                    child: SubtitleTextWidget(
                        fontSize: 17,
                        color: AppColors.grey,
                        label: "Let\'s get your logged in so you can start explore"),
                  ),


                  const SizedBox(
                    height: 100.0,
                  ),
                  /// form inputs
                  Form(
                    key: _formKey,
                    child: Column(
                      // mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        /// email field
                        TextFormField(
                          controller: _emailController,
                          focusNode: _emailFocusNode,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            hintText: "Email address",
                            prefixIcon: Icon(
                              IconlyLight.message,
                            ),
                          ),
                          validator: (value) {
                            return MyValidators.emailValidator(value);
                          },
                          onFieldSubmitted: (value) {
                            FocusScope.of(context)
                                .requestFocus(_passwordFocusNode);
                          },
                        ),
                        const SizedBox(
                          height: 16.0,
                        ),
                        ///password field
                        TextFormField(
                          controller: _passwordController,
                          focusNode: _passwordFocusNode,
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: obscureText,
                          decoration: InputDecoration(
                            hintText: "*********",
                            prefixIcon: const Icon(
                              IconlyLight.lock,
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  obscureText = !obscureText;
                                });
                              },
                              icon: Icon(
                                obscureText
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                            ),
                          ),
                          validator: (value) {
                            return MyValidators.passwordValidator(value);
                          },
                          onFieldSubmitted: (value) {
                            _loginFct();
                          },
                        ),
                        const SizedBox(
                          height: 16.0,
                        ),
                        /// forget password
                          Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, ForgotPasswordScreen.routeName);
                            },
                            child: const SubtitleTextWidget(
                              label: "Forgot password?",
                              textDecoration: TextDecoration.underline,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 16.0,
                        ),
                        ///login button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(12),
                              // backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  10,
                                ),
                              ),
                            ),
                            icon: const Icon(Icons.login),
                            label: const Text(
                              "Login",
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                            onPressed: () async {
                              _loginFct();
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 16.0,
                        ),
                        SubtitleTextWidget(
                          color: AppColors.black,
                          fontWeight: FontWeight.bold,
                          label: "OR connect using".toUpperCase(),
                        ),
                        const SizedBox(
                          height: 16.0,
                        ),
                        /// contact as guest or sign by google
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            const Expanded(
                                flex: 2,
                                child: GoogleButton()),
                            const SizedBox(
                              width: 15,
                            ),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.all(12),
                                  // backgroundColor:
                                  // Theme.of(context).colorScheme.background,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      10,
                                    ),
                                  ),
                                ),
                                child: const Text(
                                  "Guest",
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                                onPressed: () async {
                                 Navigator.pushReplacementNamed(context, RootScreen.routName);
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 16.0,
                        ),
                        ///go to sign up
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SubtitleTextWidget(
                              label: "Don't have an account?",
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, RegisterScreen.routName);
                              },
                              child: const SubtitleTextWidget(
                                label: "Sign up",
                                textDecoration: TextDecoration.underline,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
