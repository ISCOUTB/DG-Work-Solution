import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:html' as html;
import 'signup_screen.dart';
import 'password_recovery_screen.dart';
import 'home_screen.dart';
import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String username = '';
  String password = '';
  bool _loading = false;

  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_emailFocusNode);
    });
  }

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _loading = true);
      var response = await ApiService.login(username, password);
      setState(() => _loading = false);
      if (response['status'] == 'success') {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', response['user']);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'])),
        );
      }
    }
  }

  void navigateToSignup() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignupScreen()),
    );
  }

  void navigateToPasswordRecovery() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PasswordRecoveryScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    html.document.title = "Iniciar sesion";
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
              (Route<dynamic> route) => false,
            );
          },
        ),
        title: Text('Inicio'),
      ),
      body: Center(
        child: Container(
          width:
              MediaQuery.of(context).size.width > 600 ? 400 : double.infinity,
          padding: EdgeInsets.all(16),
          child: _loading
              ? Center(child: CircularProgressIndicator())
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Iniciar sesión',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    SizedBox(height: 20),
                    Form(
                      key: _formKey,
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          SizedBox(height: 50),
                          TextFormField(
                            focusNode: _emailFocusNode,
                            decoration: InputDecoration(labelText: 'Correo'),
                            validator: (value) => value!.isEmpty
                                ? 'Este campo es obligatorio'
                                : null,
                            onChanged: (value) => username = value,
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) {
                              FocusScope.of(context)
                                  .requestFocus(_passwordFocusNode);
                            },
                          ),
                          TextFormField(
                            focusNode: _passwordFocusNode,
                            decoration:
                                InputDecoration(labelText: 'Contraseña'),
                            obscureText: true,
                            validator: (value) => value!.isEmpty
                                ? 'Este campo es obligatorio'
                                : null,
                            onChanged: (value) => password = value,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) {
                              login();
                            },
                          ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                onPressed: navigateToSignup,
                                child: Text('Registrarse'),
                              ),
                              TextButton(
                                onPressed: navigateToPasswordRecovery,
                                child: Text('Recuperar contraseña'),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: login,
                            child: Text('Entrar'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
