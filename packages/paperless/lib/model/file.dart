import 'package:firebase_storage/firebase_storage.dart';

class FileUploaded {
  const FileUploaded({
    required this.url,
    required this.name,
    required this.task,
  });

  final String url;
  final String name;
  final UploadTask? task;

  toMap() => {url};
}
