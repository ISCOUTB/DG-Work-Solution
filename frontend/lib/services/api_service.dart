import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';


class ApiService {
  static const String baseUrl = 'http://localhost:5000/api';

  static Future<Map<String, dynamic>> getFiles() async {
    final response = await http.get(Uri.parse('$baseUrl/files'));
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> logout() async {
    final response = await http.post(Uri.parse('$baseUrl/logout'));
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> register(String name, String email, String password, String repassword) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'repassword': repassword,
      }),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> passwordRecovery(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/password-recovery'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> uploadFileWeb(
      Uint8List fileBytes, String fileName, String? name) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/upload'));
    
    // Agregamos el archivo desde los bytes
    request.files.add(http.MultipartFile.fromBytes('file', fileBytes, filename: fileName));
    
    if (name != null) {
      request.fields['name'] = name;
    }

    var res = await request.send();
    final response = await http.Response.fromStream(res);
    return jsonDecode(response.body);
  }
}
