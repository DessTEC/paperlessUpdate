import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paperless/model/firebase_config.dart';
import 'package:paperless/model/paperles_request.dart';
import 'package:paperless/paperless.dart';
import 'package:test_app/firebase_options.dart';
import 'package:test_app/firebase_paperless_options.dart';
import 'package:intl/date_symbol_data_local.dart';

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
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
    /*FlutterPaperless.initializeApp(
      password: "Pa\$\$Wordslb93",
      userName: 'betomaciasm.macias@gmail.com',
      appName: 'Paperles',
      options: PapelessFirebaseOptions.currentPlatform,
    );*/
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          FlutterPaperless(
            paperlessConfig: PaperlessConfig(
              appName:
                  'Paperless', // firebase.getInstance('appname')  para hacer consultas a paperless
              options: PapelessFirebaseOptions.currentPlatform,
              password:
                  "Pa\$\$Wordslb93", // credenciales del proyecto de paperless y se guarda en la estructura original(es para identificar que aplicaion fue pero no al usuario)
              userName: 'betomaciasm.macias@gmail.com',
            ),
            formId: "5uRP09rRimF2wZNwbz6T", // ID del formulario
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
          /*FlutterPaperless(
            paperlessConfig: PaperlessConfig(
              appName: 'Paperless',
              options: PapelessFirebaseOptions.currentPlatform,
              password: "Pa\$\$Wordslb93",
              userName: 'betomaciasm.macias@gmail.com',
            ),
            formId: "0H9qEjTySrIOl25PnK2j",
            requesterInfo: const RequesterInfo(
              userId: '1234567890',
              userName: 'Roberto Macías Montoya',
              userMail: 'roberto.macias@gmail.com',
            ),
            saveInPaperless: false,
            submitted: () => {},
            notifyErrors: (d, w) {
              final asd = 0;
              final sddd = asd;
            },
            loadingWidget: const Center(
              child: Text("Cargando"),
            ),
          ),*/
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
