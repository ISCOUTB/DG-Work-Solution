import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'login_screen.dart';
import 'signup_screen.dart';
import 'home_screen.dart';
import '../services/api_service.dart';

class PasswordRecoveryScreen extends StatefulWidget {
  @override
  _PasswordRecoveryScreenState createState() => _PasswordRecoveryScreenState();
}

class _PasswordRecoveryScreenState extends State<PasswordRecoveryScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  bool _loading = false;

  final FocusNode _emailFocusNode = FocusNode();

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
    super.dispose();
  }

  void recoverPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _loading = true);
      var response = await ApiService.passwordRecovery(email);
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'])),
      );
      if (response['status'] == 'success') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
    }
  }

  void navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  void navigateToSignup() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignupScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    html.document.title = "Recuperar contraseña";
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
                      'Recuperar contraseña',
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
                            onChanged: (value) => email = value,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) {
                              recoverPassword();
                            },
                          ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                onPressed: navigateToLogin,
                                child: Text('Iniciar sesión'),
                              ),
                              TextButton(
                                onPressed: navigateToSignup,
                                child: Text('Registrarse'),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: recoverPassword,
                            child: Text('Recuperar'),
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
