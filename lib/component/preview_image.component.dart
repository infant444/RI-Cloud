import 'package:flutter/material.dart';

class PreviewImage extends StatefulWidget {
  final String url;
  final String name;
  const PreviewImage({super.key, required this.url, required this.name});

  @override
  State<PreviewImage> createState() => _PreviewImageState();
}

class _PreviewImageState extends State<PreviewImage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black26,
      appBar: AppBar(
        title: Text(
          widget.name,
          style: TextStyle(color: Colors.grey),
        ),
        backgroundColor: Colors.black26,
        foregroundColor: Colors.grey,
      ),
      body: Center(
        child: Image.network(
          widget.url,
          fit: BoxFit.fitWidth,
        ),
      ),
    );
  }
}
