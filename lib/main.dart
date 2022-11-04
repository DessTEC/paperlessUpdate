import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:paperless/model/firebase_config.dart';
import 'package:paperless/model/paperles_request.dart';
import 'package:paperless/paperless.dart';
import 'package:test_app/firebase_options.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeDateFormatting('es');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  //runApp(const MyApp());

  runApp(const ProviderScope(
    overrides: [],
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Paperless',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(title: 'Paperless'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("All forms")),
      body: Column(
        children: [
          FlutterPaperless(
            paperlessConfig: PaperlessConfig(
              appName:
              'paperlessdemo', // firebase.getInstance('appname')  para hacer consultas a paperless
              options: DefaultFirebaseOptions.currentPlatform,
              password:
              "meow1234", // credenciales del proyecto de paperless y se guarda en la estructura original(es para identificar que aplicaion fue pero no al usuario)
              userName: 'eber25aglera@gmail.com',
            ),
            formId: "3JKoZbXEY6h9GFDU624s", // ID del formulario
            companyId: "eO9cxq1ySZXkfUMSr7or",
            requesterInfo: const RequesterInfo(
              userId:
              '1234567890', //son los datos de quien esta haciendo la solicitud. se guarda en el nodo paperlessPackage(identifica al usuario como tal)
              userName: 'Roberto Macías Montoya',
              userMail: 'roberto.macias@gmail.com',
            ),
            saveInPaperless:
            false, //si esta false lo guarda en el proyecto default y si esta en true se guarda en paperless
            submitted: () =>
            {}, // callback cuando se guardo correctamente (existe notify errors para errores, por ejemplo cuando )
            loadingWidget: const Center(
              child: Text("Cargando"),
            ),
          ),
          // todo
          // que se muestre todos los controles en una sola pantalla o individual
          // separar los usuarios al guardar en firebase para que conincidan los ids
          //
          /*FlutterPaperless.getWidget(
            formId: "6zXTYMIspXf5I8X1Tsul",
            requesterInfo: const RequesterInfo(
              userId: '1234567890',
              userName: 'Roberto Macías Montoya',
              userMail: 'roberto.macias@gmail.com',
            ),
            saveInPaperless: false,
            submitted: () => {},
          ),*/
          // 6zXTYMIspXf5I8X1Tsul // formulario propio
          // SR6RmhLwxiIts9iot3O9 // real
        ],
      ),
    );
  }
}