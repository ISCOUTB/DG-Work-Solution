import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class FileCard extends StatefulWidget {
  final Map file;

  const FileCard({required this.file});

  @override
  _FileCardState createState() => _FileCardState();
}

class _FileCardState extends State<FileCard> {
  double _scale = 1.0;

  void _onHover(bool hovering) {
    setState(() {
      _scale = hovering ? 1.1 : 1.0;
    });
  }

  void downloadFile(BuildContext context) async {
    final url = 'http://localhost:5000/api/download/${widget.file['name']}';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo descargar el archivo')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => downloadFile(context),
      child: MouseRegion(
        onEnter: (_) => _onHover(true),
        onExit: (_) => _onHover(false),
        child: AnimatedScale(
          scale: _scale,
          duration: Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: Card(
            child: Column(
              children: [
                Expanded(
                  child: Image.network(
                    'http://localhost:5000/static/images/${widget.file['icon']}',
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    widget.file['name'],
                    overflow: TextOverflow.ellipsis,
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
