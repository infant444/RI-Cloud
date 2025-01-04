import 'package:flutter/material.dart';

import '../services/auth.service.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _conformPasswordController = TextEditingController();
  final _key = GlobalKey<FormState>();
  bool _PasswordVisible = true;
  bool _ConfromPasswordVisible = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
            key: _key,
            child: Center(
              child: Column(
                children: [
                  SizedBox(
                    height: 120,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * .9,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Sign Up",
                          style: TextStyle(
                              fontSize: 40, fontWeight: FontWeight.w600),
                        ),
                        Text("Create a new account and get started"),
                        SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * .9,
                    child: TextFormField(
                      controller: _emailController,
                      validator: (value) =>
                          value!.isEmpty ? "Email cannot be empty" : null,
                      decoration: InputDecoration(
                          label: Text("Email"),
                          hintText: "Email",
                          border: OutlineInputBorder()),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * .9,
                    child: TextFormField(
                      obscureText: _PasswordVisible,
                      controller: _passwordController,
                      validator: (value) => value!.length < 6
                          ? "Password can be atleast 8 character"
                          : null,
                      decoration: InputDecoration(
                          label: Text("Password"),
                          hintText: "Password",
                          border: OutlineInputBorder(),
                          suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _PasswordVisible = !_PasswordVisible;
                                });
                              },
                              icon: Icon(_PasswordVisible
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined))),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * .9,
                    child: TextFormField(
                      obscureText: _ConfromPasswordVisible,
                      controller: _conformPasswordController,
                      validator: (value) => value.toString() !=
                              _passwordController.text.toString()
                          ? "Confirm password should match!"
                          : null,
                      decoration: InputDecoration(
                          label: Text("Confirm Password"),
                          hintText: "Confirm Password",
                          border: OutlineInputBorder(),
                          suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _ConfromPasswordVisible =
                                      !_ConfromPasswordVisible;
                                });
                              },
                              icon: Icon(_ConfromPasswordVisible
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined))),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    height: 60,
                    width: MediaQuery.of(context).size.width * .8,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_key.currentState!.validate()) {
                          AuthService()
                              .CreateAccountWithEmail(_emailController.text,
                                  _passwordController.text)
                              .then((value) {
                            if (value == "Account created") {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text("Login successfully")));
                              Navigator.restorablePushNamedAndRemoveUntil(
                                  context, "/home", (route) => false);
                            }
                          });
                        }
                      },
                      child: Text(
                        "Sign Up",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Already have and account?"),
                      TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/login');
                          },
                          child: Text("Login")),
                    ],
                  )
                ],
              ),
            )),
      ),
    );
  }
}
