import 'package:firebase_auth/firebase_auth.dart';

///The authentication service class deals with all the authentication functions for the user
///Sign-ups, sign-ins, sign-out, password validation are all required to for the user to log-in and use the app
class AuthenticationService{

  //instance to access authentication from firebase
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  //gets the current signed-in user locally
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  //notifies when the user signed-in or signed-out
  Stream<User?> onAuthStateChanged() {
    return _firebaseAuth.authStateChanges();
  }

  ///Creates a new account for the user based on the email and password the user has entered
  ///The user must have a valid password if they want to make an account
  Future<User?> signUp(String email, String password) async {
    //validates the password before signing up
    if (!validatePassword(password)) {print("Invalid password. Please try again.");return null;}

    //creates the user with email and password
    try {
      //sign-up is sucessful here
      UserCredential createAccount = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print("Sign up successful");
      return  createAccount.user;
    //sign-up has an error here
    } catch (e) {
      print("Sign Up Error: $e");
      return null;
    }
  }

  ///Tries to Sign-in the user based on their original email and password
  Future<User?> signIn(String email, String password) async {
    //
    try {
      //sign-in is sucessful here
      UserCredential signIN = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print("Sign In successful");
      return  signIN.user;
    //sign-in has an error here
    } catch (e) {
      print("Sign In Error: $e");
      return null;
    }
  }


  ///Makes sure that current sign-in user is signed-out
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      print("Sign Out Error: $e");
    }
  }

  ///Resets the password by resetting it to the email
  Future<void> passwordRecovery(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e){
      print("Password recovery has failed: $e");
    }
  }

  ///Makes the sure the password has AT-LEAST 8 characters
  bool passwordLength(String password) {
    return password.length >= 8;
  }

  ///Makes the sure the password has AT-LEAST 1 uppercase (A-Z)
  bool passwordUpperCase(String password) {
    return password.contains(RegExp(r'[A-Z]'));
  }

  ///Makes the sure the password has AT-LEAST 1 digit (0-9)
  bool passwordDigit(String password) {
    return password.contains(RegExp(r'\d'));
  }

  ///Validates the password based on the following rules:
  /// 1.) password has AT-LEAST 8 characters
  /// 2.) password has AT-LEAST 1 uppercase (A-Z)
  /// 3.) password has AT-LEAST 1 digit (0-9)
  bool validatePassword(String password) {
    return passwordLength(password) && passwordUpperCase(password) && passwordDigit(password);
  }
}