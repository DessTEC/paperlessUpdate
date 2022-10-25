import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class StorageService {
  StorageService._();

  static final instance = StorageService._();
  static String appName = "";

  UploadTask uploadFile({
    required String path,
    required bool saveInPaperless,
    required SettableMetadata metadata,
    Uint8List? file,
    String? filePath,
  }) {
    UploadTask uploadTask;
    FirebaseStorage instance = saveInPaperless
        ? FirebaseStorage.instanceFor(app: Firebase.app(appName))
        : FirebaseStorage.instance;
    Reference ref = instance.ref().child(path);
    if (kIsWeb) {
      uploadTask = ref.putData(file!, metadata);
    } else {
      uploadTask = ref.putFile(File(filePath!), metadata);
    }
    return uploadTask;
  }

  removeFile({required String path, required bool saveInPaperless}) async {
    FirebaseStorage instance = saveInPaperless
        ? FirebaseStorage.instanceFor(app: Firebase.app(appName))
        : FirebaseStorage.instance;

    await instance.refFromURL(path).delete();
  }
}
