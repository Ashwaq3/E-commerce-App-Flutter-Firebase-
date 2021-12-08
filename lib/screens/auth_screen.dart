import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/http_exception.dart';
import 'package:youcan/providers/auth.dart';

class AuthScreen extends StatelessWidget {
  static const routeName = '/auth';

  const AuthScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          //Gradient Background
          Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(
              colors: [
                Colors.pink,
                Colors.white,
                Colors.lightBlue,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )),
          ),
          SingleChildScrollView(
            child: SizedBox(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 94),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.pink,
                        boxShadow: const [
                          BoxShadow(
                              blurRadius: 8,
                              color: Colors.black26,
                              offset: Offset(0, 2))
                        ]),
                    child: const Text(
                      'Spring',
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Anton',
                          fontSize: 50),
                    ),
                  ),
                  //to change size based on screen size
                  Flexible(
                      flex: deviceSize.height > 600 ? 3 : 2,
                      child: const AuthCard())
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  const AuthCard({Key? key}) : super(key: key);

  @override
  State<AuthCard> createState() => _AuthCardState();
}

enum AuthMode { signUp, login }

//SingleTickerProviderStateMixin for animation
class _AuthCardState extends State<AuthCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.login; //Default value

  final Map<String, String> _authMap = {
    'email': '',
    'password': ''
  }; //To store entered values from user

  bool _isLoading = false; //to show circular Progress Indicator

  final _passwordController = TextEditingController();
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 50));
    _slideAnimation = Tween<Offset>(
            begin: const Offset(0, -0.15), end: const Offset(0, 0))
        .animate(
            CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn));

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  //Call when the button pressed
  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    //If user input meet the validation rules, call the save functions
    _formKey.currentState!.save();
    //Close the Keyboard
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    try {
      if (_authMode == AuthMode.login) {
        // Log user in

        await Provider.of<Auth>(context, listen: false).logIn(
          _authMap['email'],
          _authMap['password'],
        );
      } else {
        await Provider.of<Auth>(context, listen: false).signUp(
          _authMap['email'],
          _authMap['password'],
        );
      }
    } on HttpException catch (err) {
      var errorMessage = 'Authentication Failed';
      if (err.toString().contains('EMAIL_EXISTS')) {
        errorMessage = 'This email address is already in use';
      } else if (err.toString().contains('INVALID_EMAIL')) {
        errorMessage = 'This is not a valid email address';
      } else if (err.toString().contains('WEAK_PASSWORD')) {
        errorMessage = 'This password is too weak';
      } else if (err.toString().contains('EMAIL_NOT_FOUND')) {
        errorMessage = "Couldn't find a user with that email";
      } else if (err.toString().contains('INVALID_PASSWORD')) {
        errorMessage = 'Invalid password';
      }
      _showErrorDialog(errorMessage);
    } catch (err) {
      const errorMessage = 'Could not authenticate. Please try later.';
      _showErrorDialog(errorMessage);
    }

    setState(() {
      _isLoading = false;
    });
  }

// Show error msg
  void _showErrorDialog(String errMsg) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: const Text('ERROR!'),
              content: Text(errMsg),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                    child: const Text('Okay'))
              ],
            ));
  }

  //To switch between SignIn & SignUp
  void _switchAuthMode() {
    if (_authMode == AuthMode.login) {
      setState(() {
        _authMode = AuthMode.signUp;
      });
      _controller.forward();
    } else {
      setState(() {
        _authMode = AuthMode.login;
      });
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 8,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 50),
        curve: Curves.easeIn,
        height: deviceSize.height * 0.5,
        constraints: BoxConstraints(
          minHeight: _authMode == AuthMode.signUp ? 400 : 300,
        ),
        width: deviceSize.width * 0.75,
        padding: const EdgeInsets.all(50),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'E-mail'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) {
                    if (val!.isEmpty || !val.contains('@')) {
                      return 'Invalid E-mail';
                    }
                    return null;
                  },
                  onSaved: (val) {
                    _authMap['email'] = val!;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  controller: _passwordController,
                  validator: (val) {
                    if (val!.isEmpty || val.length < 5) {
                      return 'Password is too short!';
                    }
                    return null;
                  },
                  onSaved: (val) {
                    _authMap['password'] = val!;
                  },
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 50),
                  constraints: BoxConstraints(
                    minHeight: _authMode == AuthMode.signUp ? 60 : 0,
                    maxHeight: _authMode == AuthMode.signUp ? 120 : 0,
                  ),
                  curve: Curves.easeIn,
                  child: FadeTransition(
                    opacity: _opacityAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: TextFormField(
                        enabled: _authMode == AuthMode.signUp,
                        decoration: const InputDecoration(
                            labelText: 'Confirm Password'),
                        obscureText: true,
                        validator: _authMode == AuthMode.signUp
                            ? (val) {
                                if (val != _passwordController.text) {
                                  return 'Password do not match!';
                                }
                                return null;
                              }
                            : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                if (_isLoading) const CircularProgressIndicator(),
                ElevatedButton(
                  onPressed: submit,
                  child: Text(
                    _authMode == AuthMode.signUp ? 'signUp' : 'LOGIN',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                TextButton(
                  onPressed: _switchAuthMode,
                  child: Text(
                    '${_authMode == AuthMode.login ? 'signUp' : 'LOGIN'} INSTEAD',
                    style: const TextStyle(color: Colors.black45),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
