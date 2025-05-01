import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:dressify_app/screens/home_screen.dart';
import 'package:dressify_app/widgets/custom_button.dart';
import 'package:dressify_app/constants.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dressify_app/widgets/label_input_field.dart';
import 'package:dressify_app/services/authentication_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthScreen extends StatefulWidget {
  final bool isLogin; // true for login, false for sign up

  const AuthScreen({Key? key, required this.isLogin}) : super(key: key);

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late bool isLogin;
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController retypePasswordController =
      TextEditingController(); // new retype field

  bool passwordValid = false;
  bool passwordsMatch = false;
  bool usernameTaken = false;
  bool emailTaken = false;

  final AuthenticationService _authService = AuthenticationService();

  @override
  void initState() {
    super.initState();
    isLogin = widget.isLogin;

    // Listen to password changes to validate strength and match
    passwordController.addListener(_checkPasswords);
    retypePasswordController.addListener(_checkPasswords);

    // Listen for changes in the username field (sign-up only)
    usernameController.addListener(() {
      final username = usernameController.text.trim();

      if (!isLogin && username.isNotEmpty) {
        Future.delayed(const Duration(milliseconds: 300), () async {
          final available = await _authService.isUsernameAvailable(username);
          if (mounted) {
            setState(() {
              usernameTaken = !available;
            });
          }
        });
      } else {
        if (mounted) {
          setState(() {
            usernameTaken = false;
          });
        }
      }
    });

    // Real-time check for email availability during sign-up
    emailController.addListener(() {
      final email = emailController.text.trim();

      if (!isLogin && email.isNotEmpty) {
        Future.delayed(const Duration(milliseconds: 300), () async {
          final inUse = await _authService.isEmailInUse(email);
          if (mounted) {
            setState(() {
              emailTaken = inUse;
            });
          }
        });
      } else {
        if (mounted) {
          setState(() {
            emailTaken = false;
          });
        }
      }
    });

    // Listen to all fields to trigger UI rebuilds (e.g., for enabling the button)
    _addFieldListeners();
  }

// Helper method to auto-update UI on any form change
  void _addFieldListeners() {
    for (final controller in [
      usernameController,
      emailController,
      passwordController,
      retypePasswordController,
    ]) {
      controller.addListener(() {
        if (mounted) setState(() {});
      });
    }
  }

  bool _validatePassword(String password) {
    final bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final bool hasLowercase = password.contains(RegExp(r'[a-z]'));
    final bool hasDigit = password.contains(RegExp(r'\d'));
    final bool hasMinLength = password.length >= 8;

    return hasUppercase && hasLowercase && hasDigit && hasMinLength;
  }

  void _checkPasswords() {
    setState(() {
      passwordValid = _validatePassword(passwordController.text);
      passwordsMatch = passwordController.text == retypePasswordController.text;
    });
  }

  bool get isFormComplete {
    if (isLogin) {
      return emailController.text.isNotEmpty &&
          passwordController.text.isNotEmpty;
    } else {
      return usernameController.text.isNotEmpty &&
          emailController.text.isNotEmpty &&
          passwordController.text.isNotEmpty &&
          retypePasswordController.text.isNotEmpty &&
          passwordValid &&
          passwordsMatch &&
          !usernameTaken &&
          !emailTaken;
    }
  }

  // Toggle the auth mode from within the AuthScreen if needed
  void toggleAuthMode() {
    setState(() {
      isLogin = !isLogin;
    });
  }

  void handleAuth() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final usernameInput =
        usernameController.text.trim(); // renamed to usernameInput

    setState(() {
      emailTaken = false; // reset before every attempt
    });

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all fields.')),
      );
      return;
    }

    User? user;

    if (isLogin) {
      // Attempt to log in
      user = await _authService.signIn(email, password);
    } else {
      // Validate password strength before signing up
      if (!_authService.validatePassword(password)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Password must be at least 8 characters, include an uppercase letter, and a number.')),
        );
        return; // Don't continue to signup if password is invalid
      }
      // Attempt to sign up
      try {
        user = await _authService.signUp(email, password, usernameInput);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          setState(() {
            emailTaken = true;
          });
          return;
        } else {
          print("Other Firebase signup error: ${e.code}");
        }
      } catch (e) {
        print("Unexpected error during signup: $e");
      }
    }

    if (user != null) {
      if (isLogin) {
        // After login, fetch username based on the logged-in UID
        final snapshot = await FirebaseFirestore.instance
            .collection('usernames')
            .where('uid', isEqualTo: user.uid) // use user.uid DIRECTLY
            .limit(1)
            .get();

        if (snapshot.docs.isNotEmpty) {
          kUsername = snapshot.docs.first.id; // username = doc ID
          print('Username loaded after login: $kUsername');
        } else {
          print('Username not found for UID: ${user.uid}');
        }
      } else {
        // 🔥 After signup, use the input username
        kUsername = usernameInput;
        print('Username set after signup: $kUsername');
      }

      // ✅ Now navigate
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else if (!emailTaken) {
      // Auth failed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isLogin ? 'Login failed.' : 'Sign up failed.')),
      );
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    retypePasswordController.dispose(); // dispose retype controller
    usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // For example, logo positioning
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: screenHeight * 0.10,
            left: screenWidth * 0.22,
            child: SvgPicture.asset(
              "lib/assets/images/Logo_Type.svg",
              width: screenWidth * 0.6,
            ),
          ),
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: screenHeight * 0.2), // Top Spacer
                // Change title based on mode
                Text(
                  isLogin ? "Welcome Back!" : "Let's Get Started!",
                  style: kH1.copyWith(fontSize: 28),
                ),
                Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (!isLogin) ...[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                              child: Text('Username:', style: kH3),
                            ),
                            const SizedBox(height: 10),
                            LabelInputField(
                              controller: usernameController,
                              hintText: "Enter your username",
                              maxLength: 50,
                              showCounter: false,
                            ),
                            if (usernameTaken)
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20.0, vertical: 5.0),
                                child: const Text(
                                  'This username is not available! Please choose a different one.',
                                  style: kErrorMessage,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                      ],

                      // Email input field

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Text('Email:', style: kH3),
                          ),
                          const SizedBox(height: 10),
                          LabelInputField(
                            controller: emailController,
                            hintText: "Enter your email",
                            maxLength: 50,
                            showCounter: false,
                          ),
                          if (emailTaken)
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 5.0),
                              child: Text(
                                'An account connected to this email address already exists.',
                                style: kErrorMessage,
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: isLogin ? 20 : 10),
                      // Password input field
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Text('Password:', style: kH3),
                          ),
                          const SizedBox(height: 10),
                          LabelInputField(
                            controller: passwordController,
                            hintText: "Enter your password",
                            maxLength: 50,
                            obscureText: true,
                            showCounter: false,
                          ),
                          if (!passwordValid &&
                              passwordController.text.isNotEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 5.0),
                              child: Text(
                                'Password must have:\n• Minimum 8 characters\n• At least one uppercase letter (A-Z)\n• At least one lowercase letter (a-z)\n• At least one digit (0-9)',
                                style: kErrorMessage,
                              ),
                            ),
                          if (!isLogin) ...[
                            const SizedBox(height: 20),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                              child: Text('Re-enter Password:', style: kH3),
                            ),
                            const SizedBox(height: 10),
                            LabelInputField(
                              controller: retypePasswordController,
                              hintText: "Re-enter your password",
                              maxLength: 50,
                              obscureText: true,
                              showCounter: false,
                            ),
                            const SizedBox(height: 10),

                            // Show password match error
                            if (!passwordsMatch &&
                                retypePasswordController.text.isNotEmpty)
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20.0, vertical: 5.0),
                                child: Text(
                                  'Passwords do not match. Please try again.',
                                  style: kErrorMessage,
                                ),
                              ),
                          ],
                        ],
                      ),

                      const SizedBox(height: 25),
                      // Button: Its text depends on the mode
                      CustomButton(
                        text: isLogin ? 'Login' : 'Create Account',
                        onPressed: isFormComplete ? handleAuth : null,
                      ),

                      const SizedBox(height: 10),
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
            ),
          )
        ],
      ),
    );
  }
}
