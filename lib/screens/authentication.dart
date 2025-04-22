import 'package:flutter/material.dart';
import 'package:dressify_app/screens/home_screen.dart';
import 'package:dressify_app/widgets/custom_button.dart';
import 'package:dressify_app/constants.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dressify_app/widgets/label_input_field.dart';

class AuthScreen extends StatefulWidget {
  final bool isLogin; // true for login, false for sign up

  const AuthScreen({Key? key, required this.isLogin}) : super(key: key);

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late bool isLogin;
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Initialize the mode based on the parameter passed from the landing page
  @override
  void initState() {
    super.initState();
    isLogin = widget.isLogin;
  }

  // Toggle the auth mode from within the AuthScreen if needed
  void toggleAuthMode() {
    setState(() {
      isLogin = !isLogin;
    });
  }

  void handleAuth() {
    if (isLogin) {
      // TODO: Insert your login logic here
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      // TODO: Insert your sign up logic here
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // For example, logo positioning
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: screenHeight * 0.10,
            left: screenWidth * 0.08,
            child: SvgPicture.asset(
              "lib/assets/images/Logo_Type.svg",
              width: screenWidth * 0.85,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 80), // Top Spacer
              // Change title based on mode
              Text(
                isLogin ? "Welcome Back!" : "Let's Get Started!",
                style: kH1.copyWith(fontSize: 32),
              ),
              Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Username input field
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('User Name:', style: kH3),
                        const SizedBox(height: 10),
                        LabelInputField(
                          controller: usernameController,
                          hintText: "Enter your email",
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Password input field
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Password:', style: kH3),
                        const SizedBox(height: 10),
                        LabelInputField(
                          controller: passwordController,
                          hintText: "Enter your password",
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    // Button: Its text depends on the mode
                    CustomButton(
                      text: isLogin ? 'Login' : 'Create Account',
                      onPressed: handleAuth,
                    ),
                    const SizedBox(height: 20),
                    // Option to toggle mode from this screen
                    TextButton(
                      onPressed: toggleAuthMode,
                      child: Text(
                        isLogin
                            ? "Don't have an account? Sign Up"
                            : "Already have an account? Login",
                        style: const TextStyle(
                          color: Colors.blue,
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
