import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'userModel.dart';

class ImageServices {
  String threadId;
  UserModel selectedUser;
  String currentUserId;
  String currentUserName;
  // String currentUserPhoto;
  ImageServices({
    @required this.threadId,
    @required this.selectedUser,
    @required this.currentUserId,
    @required this.currentUserName,
    // @required this.currentUserPhoto
  });

  Future<List> getImages({bool cameraEnable}) async {
    // requestPermission();
    List<Asset> resultList;
    // String error;
    try {
      resultList = await MultiImagePicker.pickImages(
          maxImages: 1, enableCamera: cameraEnable ?? false);
    } on Exception catch (e) {
      print('error: ${e.toString()}');
      // error = e.toString();
    } catch (e) {
      print('error  one: ${e.toString()}');
      throw (e.toString());
      // error = e.toString();
    }

    return resultList;
  }

  Future<List> uploadFile(List resultList) async {
    List images = await uploadIamges(resultList);
    return images;
  }

  Future<List> uploadIamges(List resultList) async {
    List _images = List();

    for (var img in resultList) {
      ByteData byteData = await img.getByteData();
      List<int> imageData = byteData.buffer.asUint8List();
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference reference =
          FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = reference.putData(imageData);
      //MIGHT CAUSE AN ERROR
      String url = await (await uploadTask).ref.getDownloadURL();
      print('DownLoad url $url');
      _images.add(url);
    }
    return _images;
  }
}
