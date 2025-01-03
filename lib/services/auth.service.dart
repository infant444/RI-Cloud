import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  Future<String> CreateAccountWithEmail(String email, String password) async {
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      return "Account created";
    } on FirebaseAuthException catch (c) {
      return c.message.toString();
    }
  }

  Future<String> LoginAccountWithEmail(String email, String password) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      return "Login Succesfully";
    } on FirebaseAuthException catch (c) {
      return c.message.toString();
    }
  }

  Future LogOut() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<String> ResetMail(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      return "Mail Send";
    } on FirebaseAuthException catch (e) {
      return e.message.toString();
    }
  }

  Future<bool> isLogin() async {
    var user = await FirebaseAuth.instance.currentUser;
    return user != null;
  }
}
