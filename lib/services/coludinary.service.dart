import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:file_picker/file_picker.dart';
import 'package:filestorage/services/firestore.services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:http/http.dart' as http;

Future<bool> uploadToCloudinary(FilePickerResult? fpr) async {
  if (fpr == null || fpr.files.isEmpty) {
    print("No file is Selected");
    return false;
  }
  File file = File(fpr.files.single.path!);

  String cloudName = dotenv.env["CLOUDINARY_NAME"] ?? '';

  var uri = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/raw/upload");
  var request = http.MultipartRequest("POST", uri);
  var fileBytes = await file.readAsBytes();

  var multipartFile = http.MultipartFile.fromBytes(
    'file',
    fileBytes,
    filename: file.path.split("/").last,
  );
  request.files.add(multipartFile);
  request.fields['upload_preset'] = dotenv.env['CLOUDINARY_PRESET_NAME'] ?? '';
  request.fields['resource_type'] = "raw";
  var response = await request.send();
  var responseBody = await response.stream.bytesToString();
  print(responseBody);
  if (response.statusCode == 200) {
    var jsonRes = jsonDecode(responseBody);
    Map<String, String> requiredData = {
      "id": jsonRes["public_id"],
      "name": fpr.files.first.name,
      "extension": fpr.files.first.extension!,
      "size": jsonRes["bytes"].toString(),
      "url": jsonRes["secure_url"],
      "created_at": jsonRes["created_at"],
    };
    await FirestoreServices().saveUploadedFileData(requiredData);
    print("Upload Successfully");
    return true;
  }
  print("Upload is failed and the statuscode is ${response.statusCode}");
  return false;
}

Future<bool> deleteToCloudinary(String publicId) async {
  String cloudName = dotenv.env["CLOUDINARY_NAME"] ?? '';
  String apikey = dotenv.env["CLOUDINARY_API_KEY"] ?? '';
  String apisecret = dotenv.env["CLOUDINARY_API_SECRET"] ?? '';

  int timestamp = DateTime.now().microsecondsSinceEpoch ~/ 1000;

  String toSign = 'public_id=$publicId&timestamp=$timestamp$apisecret';

  var bytes = utf8.encode(toSign);
  var digest = sha1.convert(bytes);
  String signature = digest.toString();

  var uri =
      Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/raw/destroy/");
  var response = await http.post(uri, body: {
    'public_id': publicId,
    'timestamp': timestamp.toString(),
    'api_key': apikey,
    'signature': signature
  });
  if (response.statusCode == 200) {
    var responseBody = jsonDecode(response.body);
    print(responseBody);
    if (responseBody['result'] == 'ok') {
      print("Delete successfully");
      return true;
    } else {
      print("Failed to delete the file");
      return false;
    }
  } else {
    print(
        "Failed to delete the file ,status : ${response.statusCode} : ${response.reasonPhrase}");
    return false;
  }
}

Future<bool?> DownloadFileFromCloudnary(String url, String extention) async {
  if (extention == 'png' || extention == "jpg" || extention == "jepg") {
    return GallerySaver.saveImage(url, albumName: "IR Cloud");
  } else {
    return GallerySaver.saveVideo(url, albumName: "IR Cloud");
  }
}
