import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:imgly_sdk/imgly_sdk.dart';
import 'package:uuid/uuid.dart';
import 'package:video_editor_sdk/video_editor_sdk.dart';

class MyProvider with ChangeNotifier {
  List<Future<String>> downloads = [];
  List localPaths = [];
  List<AudioClip> audioClips2 = [];
  bool waiting_download_music = false;
  var pickimg_result;
  bool waiting_upload_video = false;
  int limit_video_size = 500;
  late Uint8List? _imageBytes;
  late Uint8List? _recordBytes;
  late Uint8List? _videoBytes;
  late String? _imageName;
  late String? _recordName;
  late String? _videoName;
  late Uint8List? _subimageBytes;
  late FilePickerResult? result; //檔案本檔
  Future pickvideo_camera() async {
    pickimg_result = null;
    try {
      final ImagePicker _picker = ImagePicker();

      final XFile? image = await _picker.pickVideo(source: ImageSource.camera);
      pickimg_result = image;
    } catch (e) {
      print('選檔案exception::$e');
    }
  }

  Future take_video_camara() async {
    print('load action video');

    await pickvideo_camera();
    if (pickimg_result == null) {
      print('選檔案 空的');
      return '失敗';
    } else {
      print('選檔案 有選到');
      int sizeInBytes = await File(pickimg_result.path).length();
      //限制檔案大小
      double sizeInMb = sizeInBytes / (1024 * 1024);
      if (sizeInMb > limit_video_size) {
        return '超過';
      } else {
        return '成功選到';
      }
    }
  }

  String getUid2() {
    return Uuid().v1().toString();
  }

  Future upload_action_video2(int type) async {
    print('點擊上傳action video');
    var filename = 'action_video/' + Uuid().v1().toString();
    _videoName = filename + '.mp4';

    try {
      var beautyvideo_path = await openVESDKediter(type, filename);
      if (beautyvideo_path != null) {
        return '成功';
      } else {
        print('上傳影片取消');
      }
    } catch (e) {
      print('上傳影片失敗  $e');
      waiting_upload_video = false;
      notifyListeners();
      return '失敗';
    }
  }

  //影片美化
  Future openVESDKediter(int type, String filename) async {
    // try {
    //   await VESDK.unlockWithLicense("assets/license/vesdk_license");
    // } catch (error) {
    //   print("Failed to unlock PE.SDK with: $error.");
    // }
    // type==1 相簿 =2 相機
    try {
      final videoresult = type == 1
          ? await VESDK.openEditor(
              Video(result!.files.single.path!),
            )
          : await VESDK.openEditor(
              Video(pickimg_result.path!),
            );
      if (videoresult != null) {
        print('videoresult.video:::${videoresult.video}');
        return videoresult.video;
      } else {
        print('videoresult.video:::==null');
        return;
      }
    } catch (error) {
      print('openVESDKediter error $error');
    }
  }

  Future load_video() async {
    print('load action video');

    await pickvideo();
    if (result == null) {
      print('選檔案 空的');
      return '失敗';
    } else {
      print('選檔案 有選到');
      int sizeInBytes = result!.files.single.size;
      //限制檔案大小
      double sizeInMb = sizeInBytes / (1024 * 1024);
      if (sizeInMb > limit_video_size) {
        return '超過';
      } else {
        return '成功選到';
      }
    }
  }

  Future pickvideo() async {
    result = null;
    try {
      result = (await FilePicker.platform.pickFiles(
        type: FileType.video,
      ))!;
    } catch (e) {
      print('選檔案exception::$e');
    }
  }
}
