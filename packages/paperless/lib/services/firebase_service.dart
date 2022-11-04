/* ---- @SOFTTEK
Paperless
version: 0.0.2
Non-public test version

Collaborators:
---@GupThePug
---@BetoMacias

* */
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paperless/model/answer.dart';
import 'package:paperless/model/form.dart';
import 'package:paperless/services/firestorage_service.dart';
import 'package:paperless/services/firestore_service.dart';

final firebaseProvider =
Provider.family<FirebaseService, String>((ref, appName) {
  return FirebaseService(appName: appName);
});

class FirebaseService {
  FirebaseService({required String appName}) {
    FirestoreService.appName = appName;
    StorageService.appName = appName;
  }

  final _firestoreService = FirestoreService.instance;
  final _storageService = StorageService.instance;

  //Updated this form path to get the right forms by company ID
  Stream<PaperlessForm> getFormById(String formId, String companyId) =>
      _firestoreService.documentStream(
        path: '/Empresas/$companyId/Formularios/',
        idDoc: formId,
        builder: (data, _) => PaperlessForm.fromMap(data),
      );

  UploadTask uploadFile(
      String path,
      Uint8List? file,
      String? filePath,
      SettableMetadata metadata,
      bool saveInPaperless,
      ) =>
      _storageService.uploadFile(
        path: path,
        metadata: metadata,
        file: file,
        filePath: filePath,
        saveInPaperless: saveInPaperless,
      );

  Future<void> removeFile({
    required String path,
    required bool saveInPaperless,
  }) =>
      _storageService.removeFile(
        path: path,
        saveInPaperless: saveInPaperless,
      );

  Future<String> getDocumentId({
    required String formId,
    required String companyId,
    required bool saveInPaperless,
  }) =>
      _firestoreService.getDocumentId(
        formId: formId,
        companyId: companyId,
        saveInPaperless: saveInPaperless,
      );

  Future<void> saveAnswer({
    required Answer answer,
    required String path,
    required bool saveInPaperless,
  }) =>
      _firestoreService.createData(
        path: path,
        docId: answer.id,
        data: answer,
        builder: (data) => (data as Answer).toMap(),
        saveInPaperless: saveInPaperless,
      );
}

/* ---- DEVELOPER COMMENTS
* @GupThePug: this file is responsible for querying and getting
* docs. It has been updated to work with a new version of the
* paperless database
* */