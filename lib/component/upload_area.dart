import 'package:file_picker/file_picker.dart';
import 'package:filestorage/services/coludinary.service.dart';
import 'package:flutter/material.dart';

class UploadArea extends StatefulWidget {
  const UploadArea({super.key});

  @override
  State<UploadArea> createState() => _UploadAreaState();
}

class _UploadAreaState extends State<UploadArea> {
  @override
  Widget build(BuildContext context) {
    final selectedFile =
        ModalRoute.of(context)!.settings.arguments as FilePickerResult;

    return Scaffold(
      appBar: AppBar(
        title: Text("Upload Area"),
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextFormField(
              readOnly: true,
              initialValue: selectedFile.files.first.name,
              decoration: InputDecoration(label: Text("Name")),
            ),
            TextFormField(
              readOnly: true,
              initialValue: selectedFile.files.first.extension,
              decoration: InputDecoration(label: Text("Extension")),
            ),
            TextFormField(
              readOnly: true,
              initialValue: selectedFile.files.first.size.toString(),
              decoration: InputDecoration(label: Text("Size")),
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("Cancel")),
                ),
                SizedBox(
                  width: 30,
                ),
                Expanded(
                  child: OutlinedButton(
                      onPressed: () async {
                        final result = await uploadToCloudinary(selectedFile);
                        if (result) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Upload Successfully")));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Cannot Upload a File.")));
                        }
                        Navigator.pop(context);
                      },
                      child: Text("Upload")),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
