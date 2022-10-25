import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class FirestoreService {
  FirestoreService._();

  static final instance = FirestoreService._();
  static String appName = "";

  Stream<List<T>> collectionStream<T>({
    required String path,
    required T Function(Map<String, dynamic> data, String documentID) builder,
    Query<Map<String, dynamic>> Function(Query<Map<String, dynamic>> query)?
        queryBuilder,
    int Function(T lhs, T rhs)? sort,
  }) {
    Query<Map<String, dynamic>> query = FirebaseFirestore.instanceFor(
      app: Firebase.app(appName),
    ).collection(path);
    if (queryBuilder != null) query = queryBuilder(query);
    final snapshots = query.snapshots();
    return snapshots.map((snapshot) {
      final result = snapshot.docs
          .map((snapshot) => builder(snapshot.data(), snapshot.id))
          .where((value) => value != null)
          .toList();
      if (sort != null) result.sort(sort);
      return result;
    });
  }

  Stream<T> documentStream<T>({
    required String path,
    required String idDoc,
    required T Function(Map<String, dynamic> data, String documentID) builder,
  }) {
    return FirebaseFirestore.instanceFor(app: Firebase.app(appName))
        .collection(path)
        .doc(idDoc)
        .snapshots()
        .map((snapshot) => builder(
              snapshot.data() as Map<String, dynamic>,
              snapshot.id,
            ));
  }

  Future<String> getDocumentId({
    required String formId,
    required bool saveInPaperless,
  }) async {
    FirebaseFirestore instance = saveInPaperless
        ? FirebaseFirestore.instanceFor(app: Firebase.app(appName))
        : FirebaseFirestore.instance;

    final formCollection =
        instance.collection('Formularios').doc(formId).collection("Respuestas");
    return formCollection.doc().id;
  }

  Future<void> createData<T>({
    required Map<String, dynamic> Function(T object) builder,
    required T data,
    required String path,
    required String? docId,
    required bool saveInPaperless,
  }) async {
    FirebaseFirestore instance = saveInPaperless
        ? FirebaseFirestore.instanceFor(app: Firebase.app(appName))
        : FirebaseFirestore.instance;

    docId ??= instance.collection(path).doc().id;
    return instance.collection(path).doc(docId).set(builder(data));
  }
}
