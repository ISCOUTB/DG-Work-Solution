import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'upload_modal.dart';
import 'login_screen.dart';
import '../services/api_service.dart';
import '../widgets/file_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List files = [];
  String? user;

  @override
  void initState() {
    super.initState();
    fetchFiles();
    getUser();
  }

  Future<void> fetchFiles() async {
    var response = await ApiService.getFiles();
    if (response['status'] == 'success') {
      setState(() {
        files = response['files'];
      });
    }
  }

  Future<void> getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      user = prefs.getString('user');
    });
  }

  void logout() async {
    await ApiService.logout();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }

  void navigateToLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    ).then((value) => fetchFiles());
  }

  void openUploadModal() {
    showDialog(
      context: context,
      builder: (context) => UploadModal(),
    ).then((value) => fetchFiles());
  }

  @override
  Widget build(BuildContext context) {
    html.document.title = "Work Solution";
    final EdgeInsets gridPadding = MediaQuery.of(context).size.width > 1024
        ? EdgeInsets.symmetric(horizontal: 150, vertical: 20)
        : MediaQuery.of(context).size.width > 600
            ? EdgeInsets.symmetric(horizontal: 50, vertical: 20)
            : EdgeInsets.zero;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/logo.png',
              height: 20,
              width: 20,
            ),
            SizedBox(width: 10),
            Text('Work Solution'),
          ],
        ),
        actions: [
          if (user != null)
            IconButton(
              icon: Icon(Icons.upload_file),
              onPressed: openUploadModal,
            ),
          if (user != null)
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: logout,
            ),
          if (user == null)
            IconButton(
              icon: Icon(Icons.login),
              onPressed: navigateToLogin,
            ),
        ],
        elevation: 5.0,
      ),
      body: files.isEmpty
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.width > 600 ? 100 : 50, 
                horizontal: MediaQuery.of(context).size.width < 600 ? 10 : 0
                ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Busca el archivo que necesites',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  SizedBox(height: 0),
                  Padding(
                    padding: gridPadding,
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Buscar...',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.search),
                      ),
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  SizedBox(height: 50),
                  Padding(
                    padding: gridPadding,
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: files.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount:
                            MediaQuery.of(context).size.width < 600 ? 2 : 5,
                        crossAxisSpacing: 25,
                        mainAxisSpacing: 50,
                        childAspectRatio:
                            MediaQuery.of(context).size.width < 1025
                                ? 0.75
                                : 1.5,
                      ),
                      itemBuilder: (context, index) {
                        return FileCard(file: files[index]);
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
