import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/api_service.dart';
import 'dart:typed_data';

class UploadModal extends StatefulWidget {
  @override
  _UploadModalState createState() => _UploadModalState();
}

class _UploadModalState extends State<UploadModal> {
  Uint8List? fileBytes;
  String? fileName;
  TextEditingController nameController = TextEditingController();
  bool _loading = false;

  void pickFile() async {
    var result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        fileBytes = result.files.first.bytes; // Usamos bytes en lugar de path
        fileName = result.files.first.name;
      });
    }
  }

  void uploadFile() async {
    if (fileBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Seleccione un archivo')),
      );
      return;
    }
    setState(() => _loading = true);
    var response = await ApiService.uploadFileWeb(
      fileBytes!,
      fileName!,
      nameController.text.isNotEmpty ? nameController.text : null,
    );
    setState(() => _loading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(response['message'])),
    );
    if (response['status'] == 'success') {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Subir Archivo'),
      content: _loading
          ? Center(child: CircularProgressIndicator())
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: pickFile,
                  child: Text('Seleccionar Archivo'),
                ),
                if (fileName != null) Text('Archivo: $fileName'),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Guardar como...'),
                ),
              ],
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: uploadFile,
          child: Text('Subir'),
        ),
      ],
    );
  }
}
