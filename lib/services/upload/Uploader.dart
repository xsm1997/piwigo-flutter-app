import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:image_picker/image_picker.dart';
import 'package:piwigo_ng/api/API.dart';
import 'package:piwigo_ng/api/ImageAPI.dart';
import 'package:piwigo_ng/constants/SettingsConstants.dart';
import 'package:piwigo_ng/views/components/snackbars.dart';
import 'package:provider/provider.dart';

import '../UploadStatusProvider.dart';
import 'chunked_uploader.dart';

class Uploader {
  BuildContext mainContext;


  Uploader(this.mainContext);

  Future<void> _showUploadNotification(Map<String, dynamic> downloadStatus) async {
    final android = AndroidNotificationDetails(
        'channel id',
        'channel name',
        channelDescription: 'channel description',
        priority: Priority.high,
        importance: Importance.max
    );
    final platform = NotificationDetails(android: android);
    final isSuccess = downloadStatus['isSuccess'];

    await API.localNotification.show(
      1,
      isSuccess ? 'Success' : 'Failure',
      isSuccess ? appStrings(mainContext).imageUploadCompleted_message : appStrings(mainContext).uploadError_message,
      platform,
    );
  }

  Future<void> uploadPhotos(BuildContext context, List<XFile> photos, String category, Map<String, dynamic> info) async {
    Map<String, dynamic> result = {
      'isSuccess': true,
      'filePath': null,
      'error': null,
    };
    List<int> uploadedImages = [];
    final uploadStatusProvider = Provider.of<UploadStatusNotifier>(context, listen: false);

    uploadStatusProvider.status = true;
    uploadStatusProvider.max = photos.length;
    uploadStatusProvider.current = 1;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(appStrings(context).imageUploadTableCell_uploading),
        duration: Duration(seconds: 2),
      ),
    );

    try {
      for(var element in photos) {
        uploadStatusProvider.status = true;

        Response response = await uploadChunk(context, element, category, info,
            (progress) {
              print(progress);
              uploadStatusProvider.progress = progress;
            },
        );
        var data = json.decode(response.data);

        if(data["stat"] == "fail") {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(errorSnackBar(context, response.data));
        } else if(data["result"]["id"] != null) {
          uploadedImages.add(data["result"]["id"]);
        }
        uploadStatusProvider.current++;
      }
    } on DioError catch (e) {
      print(e.message);
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(errorSnackBar(context, appStrings(context).uploadError_title));
    }

    try {
      await uploadCompleted(uploadedImages, int.parse(category));
      await communityUploadCompleted(uploadedImages, int.parse(category));
    } on DioError catch (e) {
      print(e.message);
    }

    uploadStatusProvider.status = false;
    uploadStatusProvider.max = 0;
    uploadStatusProvider.current = 0;

    await _showUploadNotification(result);
  }

  void upload(XFile photo, String category) async {
    Map<String, String> queries = {"format":"json", "method": "pwg.images.upload"};
    List<int> imageData = await photo.readAsBytes();

    Dio dio = new Dio(
      BaseOptions(
        baseUrl: API.prefs.getString("base_url"),
      ),
    );

    FormData formData =  FormData.fromMap({
      "category": category,
      "pwg_token": API.prefs.getString("pwg_token"),
      "file": MultipartFile.fromBytes(
        imageData,
        filename: photo.path.split('/').last,
      ),
      "name": photo.path.split('/').last,
    });

    Response response = await dio.post("ws.php",
      data: formData,
      queryParameters: queries,
    );

    if (response.statusCode == 200) {
      print('Upload ${response.data}');
      if(json.decode(response.data)["stat"] == "ok") {}
    } else {
      print("Request failed: ${response.statusCode}");
    }
  }
  Future<Response> uploadChunk(BuildContext context, XFile photo,
    String category, Map<String, dynamic> info,
    Function(double) onProgress,
  ) async {
    Map<String, String> queries = {
      "format":"json",
      "method": "pwg.images.uploadAsync"
    };
    Map<String, dynamic> fields = {
      'username': API.prefs.getString("username"),
      'password': API.prefs.getString("password"),
      'filename': photo.path.split('/').last,
      'category': category,
    };
    if(info['name'] != '' && info['name'] != null) fields['name'] = info['name'];
    if(info['comment'] != '' && info['comment'] != null) fields['comment'] = info['comment'];
    if(info['tag_ids'].isNotEmpty) fields['tag_ids'] = info['tag_ids'];
    if(info['level'] != -1) fields['level'] = info['level'];

    ChunkedUploader chunkedUploader = ChunkedUploader(new Dio(
      BaseOptions(
        baseUrl: API.prefs.getString("base_url"),
      ),
    ));

    try {
      return await chunkedUploader.upload(
        context: context,
        path: "/ws.php",
        filePath: await FlutterAbsolutePath.getAbsolutePath(photo.path),
        maxChunkSize: API.prefs.getInt("upload_form_chunk_size")*1000,
        params: queries,
        method: 'POST',
        data: fields,
        contentType: Headers.formUrlEncodedContentType,
        onUploadProgress: (value) => onProgress(value),
      );
    } on DioError catch (e) {
      print('Dio upload chunk error $e');
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(errorSnackBar(context, appStrings(context).uploadError_title));
      return Future.value(null);
    }
  }
}


class FlutterAbsolutePath {
  static const MethodChannel _channel =
  const MethodChannel('flutter_absolute_path');

  /// Gets absolute path of the file from android URI or iOS PHAsset identifier
  /// The return of this method can be used directly with flutter [File] class
  static Future<String> getAbsolutePath(String uri) async {
    final Map<String, dynamic> params = <String, dynamic>{
      'uri': uri,
    };
    final String path = await _channel.invokeMethod('getAbsolutePath', params);
    return path;
  }
}