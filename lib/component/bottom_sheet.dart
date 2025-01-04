import 'dart:convert';
import 'dart:io';

import 'package:filestorage/services/coludinary.service.dart';
import 'package:filestorage/services/firestore.services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
// import 'dart:typed_data';

class ShowBottomSheet extends StatefulWidget {
  final String url;
  final String ext;
  final String name;
  final String docId;
  final String id;
  const ShowBottomSheet(
      {super.key,
      required this.url,
      required this.ext,
      required this.name,
      required this.docId,
      required this.id});

  @override
  State<ShowBottomSheet> createState() => _ShowBottomSheetState();
}

class _ShowBottomSheetState extends State<ShowBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 700,
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: 15,
              ),
              Row(
                children: [
                  SizedBox(
                    width: 25,
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: widget.ext == 'png' ||
                            widget.ext == "jpg" ||
                            widget.ext == "jepg"
                        ? Image.network(
                            widget.url,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          )
                        : Icon(
                            Icons.movie,
                            size: 40,
                          ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    widget.name,
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 15,
              ),
              TextButton(
                  onPressed: () async {
                    final url = Uri.parse(widget.url);
                    final response = await http.get(url);
                    final bytes = response.bodyBytes;
                    final temp = await getTemporaryDirectory();
                    final Path = '${temp.path}/image.jpg';
                    File(Path).writeAsBytesSync(bytes);

                    await Share.shareXFiles([XFile(Path)]);
                    Navigator.pop(context);
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.mobile_screen_share_outlined,
                        color: Colors.black,
                        size: 20,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        "Share a copy",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w400),
                      )
                    ],
                  )),
              TextButton(
                  onPressed: () async {
                    final res =
                        await DownloadFileFromCloudnary(widget.url, widget.ext);
                    if (res == true) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("File download successfully!")));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                          "Error in file download",
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.red,
                      ));
                    }
                    Navigator.pop(context);
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.file_download_outlined,
                        color: Colors.black,
                        size: 20,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        "Make a copy",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w400),
                      )
                    ],
                  )),
              TextButton(
                  onPressed: () async {
                    final Uri uri = Uri.parse(widget.url);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri,
                          mode: LaunchMode.externalApplication);
                    }
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.file_open_outlined,
                        color: Colors.black,
                        size: 20,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        "open with",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w400),
                      )
                    ],
                  )),
              TextButton(
                  onPressed: () {
                    Share.share(widget.url);
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.share_outlined,
                        color: Colors.black,
                        size: 20,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        "Share a link",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w400),
                      )
                    ],
                  )),
              TextButton(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: widget.url));
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.link,
                        color: Colors.black,
                        size: 20,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        "Copy a link",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w400),
                      ),
                    ],
                  )),
              widget.ext == 'png' || widget.ext == "jpg" || widget.ext == "jepg"
                  ? TextButton(
                      onPressed: () async {
                        try {
                          // Fetch the image data
                          final response =
                              await http.get(Uri.parse(widget.url));
                          if (response.statusCode == 200) {
                            // Encode as Base64 string
                            final base64Image =
                                base64Encode(response.bodyBytes);

                            // Copy Base64 string to clipboard
                            await Clipboard.setData(
                                ClipboardData(text: base64Image));
                            print(
                                'Image copied to clipboard as Base64 string!');
                          } else {
                            throw Exception('Failed to fetch image');
                          }
                        } catch (e) {
                          print('Error copying image to clipboard: $e');
                        }
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.file_copy_outlined,
                            color: Colors.black,
                            size: 20,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            "Copy a image",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w400),
                          )
                        ],
                      ))
                  : SizedBox(
                      height: 0,
                    ),
              TextButton(
                  onPressed: () async {
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              title: Text("Delete file"),
                              content: Text("Are you sure you want to delete?"),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text("Cancel")),
                                TextButton(
                                    onPressed: () async {
                                      final bool res = await FirestoreServices()
                                          .deleteFile(widget.docId, widget.id);
                                      if (res) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                content: Text("File Delete")));
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          content: Text(
                                            "File not deleted",
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          backgroundColor: Colors.red,
                                        ));
                                      }
                                      Navigator.pop(context);
                                    },
                                    child: Text("Delete"))
                              ],
                            ));
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_outline_outlined,
                        color: Colors.black,
                        size: 20,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        "Delete a file",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w400),
                      )
                    ],
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
