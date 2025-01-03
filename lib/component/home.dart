import 'package:file_picker/file_picker.dart';
import 'package:filestorage/component/preview_image.component.dart';
import 'package:filestorage/component/preview_video.component.dart';
import 'package:filestorage/services/auth.service.dart';
import 'package:filestorage/services/coludinary.service.dart';
import 'package:filestorage/services/firestore.services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FilePickerResult? _filePickerResult;

  void _openFilePicker() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        allowedExtensions: ["jpg", "jpeg", "png", "mp4"],
        type: FileType.custom);
    setState(() {
      _filePickerResult = result;
    });
    if (_filePickerResult != null) {
      Navigator.pushNamed(context, "/upload", arguments: _filePickerResult);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Your storage"),
        actions: [
          IconButton(
              onPressed: () {
                AuthService().LogOut();
                Navigator.pushReplacementNamed(context, "/login");
              },
              icon: Icon(Icons.logout))
        ],
      ),
      body: StreamBuilder(
        stream: FirestoreServices().readUploadFiles(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List userUploadedFiles = snapshot.data!.docs;
            if (userUploadedFiles.isEmpty) {
              return Center(
                child: Text("No files uploaded"),
              );
            } else {
              return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, //Number of Columns in the grid
                    childAspectRatio: 1, //Aspect ration for each grid
                    crossAxisSpacing: 8, //spacing between columns
                    mainAxisSpacing: 8, //Spacing between rows
                  ),
                  itemCount: userUploadedFiles.length,
                  itemBuilder: (context, index) {
                    String name = userUploadedFiles[index]['name'];
                    String extention = userUploadedFiles[index]['extension'];
                    String id = userUploadedFiles[index]['id'];
                    String url = userUploadedFiles[index]['url'];

                    return GestureDetector(
                      onLongPress: () {
                        showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                                  title: Text("Delete file"),
                                  content:
                                      Text("Are you sure you want to delete?"),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text("Cancel")),
                                    TextButton(
                                        onPressed: () async {
                                          final bool res =
                                              await FirestoreServices()
                                                  .deleteFile(
                                                      snapshot
                                                          .data!.docs[index].id,
                                                      id);
                                          if (res) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                                    content:
                                                        Text("File Delete")));
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                              content: Text(
                                                "File not deleted",
                                                style: TextStyle(
                                                    color: Colors.white),
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
                      onTap: () {
                        if (extention == 'png' ||
                            extention == "jpg" ||
                            extention == "jepg") {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      PreviewImage(url: url)));
                        } else {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      PreviewVideo(url: url)));
                        }
                      },
                      child: Container(
                        color: Colors.blueGrey[100],
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              child: extention == 'png' ||
                                      extention == "jpg" ||
                                      extention == "jepg"
                                  ? Image.network(
                                      url,
                                      width: double.infinity,
                                      height: double.infinity,
                                      fit: BoxFit.cover,
                                    )
                                  : Icon(
                                      Icons.movie,
                                      size: 48,
                                    ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Icon(extention == 'png' ||
                                          extention == "jpg" ||
                                          extention == "jepg"
                                      ? Icons.image
                                      : Icons.movie),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: Text(
                                      name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  IconButton(
                                      onPressed: () async {
                                        final res =
                                            await DownloadFileFromCloudnary(
                                                url, extention);
                                        if (res) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  content: Text(
                                                      "File download successfully!")));
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                            content: Text(
                                              "Error in file download",
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            backgroundColor: Colors.red,
                                          ));
                                        }
                                      },
                                      icon: Icon(Icons.download))
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  });
            }
          } else if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          } else {
            return SpinKitFadingCircle(
              itemBuilder: (BuildContext context, int index) {
                return DecoratedBox(
                  decoration: BoxDecoration(
                    color: index.isEven ? Colors.red : Colors.green,
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _openFilePicker();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
