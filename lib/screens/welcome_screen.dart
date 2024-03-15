import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:rumah_sewa_app/screens/register_screen.dart';
import 'package:rumah_sewa_app/utils/auth_service.dart';
import '../utils/rounded_button.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

final _auth = FirebaseAuth.instance;

class _WelcomeScreenState extends State<WelcomeScreen> {
  late String email;
  late String password;
  bool showSpinner = false;
  bool isLogin = true;
  int _selectedIndex = 0; // 0 for register, 1 for login
  bool showLoginScreen = true; // State variable to toggle screens

  void toggleForm() {
    setState(() {
      showLoginScreen = !showLoginScreen;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _forms = [
      _registerForm(),
      _loginForm(),
    ];

    return Scaffold(
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Your logo here
              // Flexible(
              //   child: FlutterLogo(size: 200.0),
              // ),
              SizedBox(height: 48.0),
              showLoginScreen ? _loginForm() : _registerForm(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      showLoginScreen
                          ? 'Don\'t have an account? '
                          : 'Already have an account? ',
                      style: TextStyle(color: Colors.grey),
                    ),
                    GestureDetector(
                      onTap: toggleForm,
                      child: Text(
                        showLoginScreen ? 'Register here' : 'Login here',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.0),
              _dividerWithText(),
              SizedBox(height: 20.0),
              _googleSignInButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _roundedButton({
    required String title,
    required Color color,
    required Color textColor,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: textColor,
        backgroundColor: color,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        elevation: 5,
      ),
      onPressed: onPressed,
      child: Text(title, style: TextStyle(fontSize: 18)),
    );
  }

  // Widget _toggleButton() {
  //   return TextButton(
  //     onPressed: () => setState(() => isLogin = !isLogin),
  //     child: Text(
  //       isLogin
  //           ? 'Don\'t have an account? Register here'
  //           : 'Already have an account? Login here',
  //       style: TextStyle(color: Colors.white70, fontSize: 14),
  //     ),
  //   );
  // }

  Widget _dividerWithText() {
    return const Row(
      children: <Widget>[
        Expanded(
          child: Divider(
            color: Colors.grey,
            height: 20,
            thickness: 1,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            'Or',
            style:
                TextStyle(color: Colors.black54, fontWeight: FontWeight.w700),
          ),
        ),
        Expanded(
          child: Divider(
            color: Colors.grey,
            height: 20,
            thickness: 1,
          ),
        ),
      ],
    );
  }

  Widget _googleSignInButton() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: ElevatedButton.icon(
        icon: Padding(
          padding: EdgeInsets.only(right: 5),
          child: Image.asset('assets/icons/google.png', width: 24, height: 24),
        ),
        label: Text('Sign in with Google', style: TextStyle(fontSize: 16)),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black,
          backgroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 8),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
          elevation: 4,
          minimumSize: Size.zero,
        ),
        onPressed: () async => _signInWithGoogle(),
      ),
    );
  }

  Widget _registerForm() {
    // ... Your registration form fields and button here
    // Replace with your actual registration form widget
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TextField(
              keyboardType: TextInputType.emailAddress,
              textAlign: TextAlign.center,
              onChanged: (value) {
                email = value;
                //Do something with the user input.
              },
              decoration:
                  kTextFieldDecoration.copyWith(hintText: 'Enter your email')),
          SizedBox(
            height: 8.0,
          ),
          TextField(
              obscureText: true,
              textAlign: TextAlign.center,
              onChanged: (value) {
                password = value;
                //Do something with the user input.
              },
              decoration: kTextFieldDecoration.copyWith(
                  hintText: 'Enter your Password')),
          SizedBox(
            height: 24.0,
          ),
          RoundedButton(
            colour: Colors.blueAccent,
            title: 'Register',
            onPressed: () async {
              setState(() {
                showSpinner = true;
              });
              try {
                final newUser = await _auth.createUserWithEmailAndPassword(
                    email: email, password: password);
                if (newUser != null) {
                  Navigator.pushNamed(context, 'home_screen');
                }
              } catch (e) {
                print(e);
              }
              setState(() {
                showSpinner = false;
              });
            },
          )
        ],
      ),
    );
  }

  Widget _loginForm() {
    // ... Your login form fields and button here
    // Replace with your actual login form widget
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TextField(
              keyboardType: TextInputType.emailAddress,
              textAlign: TextAlign.center,
              onChanged: (value) {
                email = value;
                //Do something with the user input.
              },
              decoration: kTextFieldDecoration.copyWith(
                hintText: 'Enter your email',
              )),
          SizedBox(
            height: 8.0,
          ),
          TextField(
              obscureText: true,
              textAlign: TextAlign.center,
              onChanged: (value) {
                password = value;
                //Do something with the user input.
              },
              decoration: kTextFieldDecoration.copyWith(
                  hintText: 'Enter your password.')),
          SizedBox(
            height: 24.0,
          ),
          RoundedButton(
              colour: Colors.blueAccent,
              title: 'Log In',
              onPressed: () async {
                setState(() {
                  showSpinner = true;
                });
                try {
                  final user = await _auth.signInWithEmailAndPassword(
                      email: email, password: password);
                  if (user != null) {
                    Navigator.pushNamed(context, 'home_screen');
                  }
                } catch (e) {
                  print(e);
                }
                setState(() {
                  showSpinner = false;
                });
              }),
        ],
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      showSpinner = true;
    });
    var user = await AuthService().signInWithGoogle();
    if (user != null) {
      Navigator.pushNamed(context, 'home_screen');
    } else {
      // Handle sign in error
      print('Error signing in with Google');
    }
    setState(() {
      showSpinner = false;
    });
  }
}
