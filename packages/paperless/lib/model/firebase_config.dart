import 'package:firebase_core/firebase_core.dart';

class PaperlessConfig {
  const PaperlessConfig({
    required this.appName,
    required this.userName,
    required this.password,
    required this.options,
  });

  final String appName;
  final String userName;
  final String password;
  final FirebaseOptions? options;
}
