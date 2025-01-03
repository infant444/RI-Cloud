import 'package:filestorage/component/home.dart';
import 'package:filestorage/component/login.component.dart';
import 'package:filestorage/component/signup.component.dart';
import 'package:filestorage/component/upload_area.dart';
import 'package:filestorage/firebase_options.dart';
import 'package:filestorage/services/auth.service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const storage());
}

class storage extends StatelessWidget {
  const storage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Online Drive",
      debugShowCheckedModeBanner: false,
      routes: {
        "/": (context) => CheckUser(),
        "/upload": (context) => UploadArea(),
        "/login": (context) => Login(),
        "/signup": (context) => Signup(),
        "/home": (context) => HomePage(),
      },
    );
  }
}

class CheckUser extends StatefulWidget {
  const CheckUser({super.key});

  @override
  State<CheckUser> createState() => _CheckUserState();
}

class _CheckUserState extends State<CheckUser> {
  @override
  void initState() {
    AuthService().isLogin().then((value) {
      if (value) {
        Navigator.pushReplacementNamed(context, "/home");
      } else {
        Navigator.pushReplacementNamed(context, "/login");
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SpinKitFadingCircle(
        itemBuilder: (BuildContext context, int index) {
          return DecoratedBox(
            decoration: BoxDecoration(
              color: index.isEven ? Colors.red : Colors.green,
            ),
          );
        },
      ),
    );
  }
}
