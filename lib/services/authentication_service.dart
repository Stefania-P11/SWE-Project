import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dressify_app/constants.dart';
import 'package:dressify_app/services/firebase_service.dart';
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
  Future<User?> signUp(String email, String password, String username) async {
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

    // Set the username as the displayName on the user object
    await createAccount.user!.updateDisplayName(username);
    await createAccount.user!.reload(); 

       // Save username in Firestore under a "usernames" collection
    await FirebaseFirestore.instance
        .collection('usernames')
        .doc(username)  // the username is the document ID
        .set({
          'uid': createAccount.user!.uid,
          'email': createAccount.user!.email,
        });

      //return  createAccount.user;
        // Return the reloaded user
    return _firebaseAuth.currentUser;
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
   // 🔑 Fetch username from Firestore and set global kUsername
    final snapshot = await FirebaseFirestore.instance
        .collection('usernames')
        .where('uid', isEqualTo: signIN.user!.uid)
        .limit(1)
        .get();
        

    if (snapshot.docs.isNotEmpty) {
      kUsername = snapshot.docs.first.id; // The doc ID is the username
      print("Username loaded: $kUsername");
    } else {
      print("Username not found for UID: ${signIN.user!.uid}");
    }

    return signIN.user;
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

  ///Sets a new password for the current user 
  Future<void> setNewPassword(String password) async {
    try {
      //gets the current user
      User? user = getCurrentUser();
      if (user != null) {
        //password gets updated if the user is signed-in
        await user.updatePassword(password);
        print("The new password has been set.");
      } else {
        //user is not signed in
        print("User is not signed in.");
      }
    } catch (e) {
      print("The new has failed to update: $e");
    }
  }
}

Future<bool> isUsernameAvailable(String username) async {
    try {
      final result = await FirebaseService.db
          .collection('usernames')
          .doc(username)
          .get();
      return !result.exists; // true = available
    } catch (e) {
      print("Username check failed: $e");
      return false;
    }
  }

  Future<String?> getUsernameForCurrentUser() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return null;

 
  final doc = await FirebaseFirestore.instance
      .collection('usernames')
      .where('uid', isEqualTo: user.uid)
      .limit(1)
      .get();

  if (doc.docs.isEmpty) return null;
  return doc.docs.first.id; // The document ID is the username
}

