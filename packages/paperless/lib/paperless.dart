/* ---- @SOFTTEK
* ----- Paperless
* ----- version: 0.0.2
* ----- Non-public test version

* ----- Collaborators:
* ----- @GupThePug
* ----- @BetoMacias
* */
library paperless;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paperless/model/firebase_config.dart';
import 'package:paperless/model/paperles_request.dart';
import 'package:paperless/widgets/error_widget.dart';
import 'package:paperless/widgets/form_widget.dart';
import 'package:paperless/widgets/loading_widget.dart';
import 'package:paperless/widgets/message.dart';

final firebaseProvider = FutureProvider.autoDispose
    .family<FirebaseException?, PaperlessConfig>((ref, config) async {
  if (!Firebase.apps.any((element) => config.appName == element.name)) {
    await Firebase.initializeApp(name: config.appName, options: config.options);
  }

  try {
    await FirebaseAuth.instanceFor(app: Firebase.app(config.appName))
        .signInWithEmailAndPassword(
      email: config.userName,
      password: config.password,
    );
    return null;
  } on FirebaseException catch (e) {
    return e;
  }
});

class FlutterPaperless extends ConsumerWidget {
  /// Widget to get forms from Paperless firebase.
  ///
  /// [paperlessConfig] credentials to get acces to Paperless Firebase
  ///
  /// [saveInPaperless] save in Paperless firebase or custom Firebase
  ///
  /// [requesterInfo] requester info t save in the answer in this form
  ///
  /// [formId] form id to display
  ///
  /// [submitted] event to know when form is saved succesfully
  ///
  /// [loadingWidget] custom widget to chow while the form is loading, saving
  ///
  /// [notifyErrors] event to notify when exists errors
  const FlutterPaperless({
    Key? key,
    required this.paperlessConfig,
    required this.saveInPaperless,
    required this.requesterInfo,
    required this.formId,
    required this.companyId,
    this.submitted,
    this.loadingWidget,
    this.notifyErrors,
  }) : super(key: key);

  final Function(Object o, StackTrace? s)? notifyErrors;
  final PaperlessConfig paperlessConfig;
  final RequesterInfo requesterInfo;
  final Widget? loadingWidget;
  final bool saveInPaperless;
  final Function? submitted;
  final String formId;
  final String companyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseAsync = ref.watch(firebaseProvider(paperlessConfig));
    return firebaseAsync.when(
      data: (data) => _buildBody(data),
      error: (e, s) {
        if (notifyErrors != null) notifyErrors!(e, s);
        return const CustomMessageWidget(
          title: "Error",
          subTitle: "Error al cargar el formulario, contacte a soporte.",
          icon: Icon(Icons.error),
        );
      },
      loading: () => loadingWidget ?? const CustomLoadingWidget(),
    );
  }

  _buildBody(FirebaseException? data) {
    if (data != null) {
      if (notifyErrors != null) {
        notifyErrors!(
          data.message ?? 'Error al iniciar Paperless',
          data.stackTrace,
        );
      }
      return CustomErrorWidget(
        error: "Error al conectarse con Paperless",
        stackTrace: data.stackTrace,
      );
    }
    return FormWidgetPage(
      basicRequest: PaperlessRequest(
          saveInPaperless: saveInPaperless,
          requesterInfo: requesterInfo,
          appName: paperlessConfig.appName,
          formId: formId,
          companyId: companyId
      ),
      loadingWidget: loadingWidget,
      notifyErrors: notifyErrors,
      submitted: submitted,
    );
  }
}