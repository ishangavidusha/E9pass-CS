import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/drive',
    ],
  );
  GoogleSignInAccount googleSignInAccount;
  FirebaseUser currentUser;
  String name;
  String email;
  String imageUrl;

  Future<FirebaseUser> get myuser async {
    currentUser = await _auth.currentUser();
    notifyListeners();
    return currentUser;
  }

  Stream<FirebaseUser> getLoginState() {
    return _auth.onAuthStateChanged;
  }

  void signInWithGoogle() async {
    GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    final AuthResult authResult = await _auth.signInWithCredential(credential);
    final FirebaseUser user = authResult.user;
    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);

    notifyListeners();
  }

  void signOutGoogle() async{
    try {
      await _auth.signOut();
      await googleSignIn.disconnect();
      await googleSignIn.signOut();
      currentUser = await _auth.currentUser();
      notifyListeners();
    } catch (error) {
      print(error);
      notifyListeners();
    }
  }
}