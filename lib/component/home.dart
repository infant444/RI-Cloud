import 'package:file_picker/file_picker.dart';
import 'package:filestorage/component/bottom_sheet.dart';
import 'package:filestorage/component/preview_image.component.dart';
import 'package:filestorage/component/preview_video.component.dart';
import 'package:filestorage/services/auth.service.dart';
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
                      onTap: () {
                        if (extention == 'png' ||
                            extention == "jpg" ||
                            extention == "jepg") {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PreviewImage(
                                        url: url,
                                        name: name,
                                      )));
                        } else {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PreviewVideo(
                                        url: url,
                                        name: name,
                                      )));
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
                                        showModalBottomSheet(
                                            context: context,
                                            barrierColor:
                                                Colors.black38.withOpacity(0.5),
                                            backgroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.vertical(
                                                        top: Radius.circular(
                                                            15))),
                                            builder: (context) =>
                                                ShowBottomSheet(
                                                  url: url,
                                                  name: name,
                                                  ext: extention,
                                                  docId: snapshot
                                                      .data!.docs[index].id,
                                                  id: id,
                                                ));
                                        //
                                      },
                                      icon: Icon(Icons.more_vert))
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

  // Future<void> _BottomSheetShow(BuildContext context) async {
  //   return showModalBottomSheet(
  //       context: context,
  //       barrierColor: Colors.black38.withOpacity(0.5),
  //       backgroundColor: Colors.blueGrey[100],
  //       shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
  //       builder: (context) => Container(
  //             height: 500,
  //           ));
  // }
}
