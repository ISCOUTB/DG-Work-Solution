import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'login_screen.dart';
import 'password_recovery_screen.dart';
import 'home_screen.dart';
import '../services/api_service.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String email = '';
  String password = '';
  String repassword = '';
  bool _loading = false;

  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _repasswordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_nameFocusNode);
    });
  }

  @override
  void dispose() {
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _repasswordFocusNode.dispose();
    super.dispose();
  }

  void signup() async {
    if (_formKey.currentState!.validate()) {
      if (password != repassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Las contraseñas no coinciden')),
        );
        return;
      }
      setState(() => _loading = true);
      var response =
          await ApiService.register(name, email, password, repassword);
      setState(() => _loading = false);
      if (response['status'] == 'success') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'])),
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

  void navigateToPasswordRecovery() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PasswordRecoveryScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    html.document.title = "Registro";
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
                      'Registro',
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
                            focusNode: _nameFocusNode,
                            decoration: InputDecoration(labelText: 'Nombre'),
                            validator: (value) => value!.isEmpty
                                ? 'Este campo es obligatorio'
                                : null,
                            onChanged: (value) => name = value,
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) {
                              FocusScope.of(context)
                                  .requestFocus(_emailFocusNode);
                            },
                          ),
                          TextFormField(
                            focusNode: _emailFocusNode,
                            decoration: InputDecoration(labelText: 'Correo'),
                            validator: (value) => value!.isEmpty
                                ? 'Este campo es obligatorio'
                                : null,
                            onChanged: (value) => email = value,
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
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) {
                              FocusScope.of(context)
                                  .requestFocus(_repasswordFocusNode);
                            },
                          ),
                          TextFormField(
                            focusNode: _repasswordFocusNode,
                            decoration:
                                InputDecoration(labelText: 'Contraseña ×2'),
                            obscureText: true,
                            validator: (value) => value!.isEmpty
                                ? 'Este campo es obligatorio'
                                : null,
                            onChanged: (value) => repassword = value,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) {
                              signup();
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
                                onPressed: navigateToPasswordRecovery,
                                child: Text('Recuperar contraseña'),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: signup,
                            child: Text('Registrarse'),
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
