import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:mime/mime.dart';
import 'package:multiselect/multiselect.dart';
import 'package:paperless/model/answer.dart';
import 'package:paperless/model/file.dart';
import 'package:paperless/model/form.dart';
import 'package:paperless/model/paperles_request.dart';
import 'package:paperless/model/response.dart';
import 'package:paperless/services/firebase_service.dart';
import 'package:paperless/widgets/loading_widget.dart';
import 'package:paperless/widgets/message.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';

final formStreamProvider = StreamProvider.autoDispose
    .family<PaperlessForm, PaperlessRequest>((ref, baseRequest) {
  final firebase = ref.watch(firebaseProvider(baseRequest.appName));
  return firebase.getFormById(baseRequest.formId, baseRequest.companyId);
});

class FormWidgetPage extends ConsumerStatefulWidget {
  const FormWidgetPage({
    Key? key,
    required this.loadingWidget,
    required this.notifyErrors,
    required this.basicRequest,
    required this.submitted,
  }) : super(key: key);

  final Function(Object o, StackTrace? s)? notifyErrors;
  final PaperlessRequest basicRequest;
  final Widget? loadingWidget;
  final Function? submitted;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FormWidgetPageState();
}

class _FormWidgetPageState extends ConsumerState<FormWidgetPage> {
  bool _showDeleteImg = false;
  List<Widget> widgets = [];
  String? answerId;
  List item = [];

  @override
  Widget build(BuildContext context) {
    final formAsync = ref.watch(formStreamProvider(widget.basicRequest));
    return formAsync.when(
      data: (form) => createForm(form, context),
      error: (e, s) {
        if (widget.notifyErrors != null) widget.notifyErrors!(e, s);
        return const CustomMessageWidget(
          title: "Error",
          subTitle: "Error al cargar el formulario, contacte a soporte. -- Debugging this text",
          icon: Icon(Icons.error),
        );
      },
      loading: () => widget.loadingWidget ?? const CustomLoadingWidget(),
    );
  }

  createForm(PaperlessForm form, BuildContext context) {
    if (form.hidden || !form.status && false) {
      return const CustomMessageWidget(
        title: "Error",
        subTitle: "Formulario no disponible.",
        icon: Icon(Icons.warning),
      );
    }
    //Ordenar componentes por su posición en el eje y
    form.components.sort(
      (a, b) => (a.layout["y"] as int).compareTo((b.layout["y"] as int)),
    );

    List<Widget> controls = [];
    List<String> controlsUsed = [];

    for (var item in form.components) {
      if (controlsUsed.contains(item.id)) continue;
      //Agregar a una row todos los componentes con el mismo valor de y
      //que el componente actual
      final horizontal = form.components
          .where((e) => e.layout["y"] == item.layout["y"])
          .toList();

      //Si hay más de un componente en la misma row
      if (horizontal.length > 1) {
        //Marcar todos los componentes de la row como usados
        controlsUsed.addAll(horizontal.map((e) => e.id));
        //Ordenar componentes en el eje x
        horizontal.sort(
          (a, b) => (a.layout["x"] as int).compareTo((b.layout["x"] as int)),
        );

        //Operaciones para agregar Expanded y SizedBox entre componentes horizontales
        List<Widget> controlH = [const SizedBox(width: 10), Container(width: 10, decoration: BoxDecoration(color: Colors.blue))];
        int auxTemp = 0;
        int auxIndex = 0;
        for (var element in horizontal) {
          auxTemp += element.layout['w'] as int;
          if (element.layout['x'] != (auxIndex * 2)) {
            auxTemp += ((element.layout['x'] as int) - (auxIndex * 2));
          }
          controlH.addAll([
            if (element.layout['x'] != (auxIndex * 2))
              Expanded(
                flex: element.layout['x'] - (auxIndex * 2),
                child: Container(),
              ),
            Expanded(
              flex: element.layout['w'],
              child: control(element, form.language, context),
            ),
            const SizedBox(width: 10),
          ]);
          auxIndex++;
        }
        controlH.add(Expanded(flex: 6 - auxTemp, child: Container()));
        //Envolver widgets en padding y row y añadir a la lista de campos del form
        controls.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: controlH,
            ),
          ),
        );
        //Cuando la row tiene un solo campo
      } else {
        // Size 6 es lo máximo que puede tener un campo
        int size = 6 - item.layout['w'] as int;
        //Mover según la posición en x
        int startPosition = item.layout['x'] as int;
        if (startPosition > 0) size -= startPosition;
        //Marcar el componente como usado
        controlsUsed.add(item.id);
        //Añadir el campo envuelto en una row con Expanded y SizedBox para empujar
        //al componente a la posición en x deseada
        controls.add(Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(width: 10),
            if (startPosition > 0)
              Expanded(flex: startPosition, child: Container()),
            if (startPosition > 0) const SizedBox(width: 10),
            Expanded(
              flex: item.layout['w'],
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: control(item, form.language, context),
              ),
            ),
            if (size > 0) const SizedBox(width: 10),
            Expanded(flex: size, child: Container())
          ],
        ));
      }
    }

    //Si el form tiene campos
    if (controls.isNotEmpty) {
      //Añadir a la lista de componentes el botón para subirlo
      controls.add(
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: ElevatedButton(
              child: const Text("Submit"),
              onPressed: () async {
                if (_validateAndSaveForm(form.components)) {
                  await _saveForm(form);
                  if (widget.submitted != null) widget.submitted!();
                } else {
                  return showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext contextDialog) {
                      return AlertDialog(
                        title: const Text('Warning!'),
                        content: const Text(
                          'Please, verify the complete form is answered',
                          softWrap: true,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        actions: [
                          TextButton(
                            child: const Text('Ok'),
                            onPressed: () async =>
                                Navigator.of(contextDialog).pop(),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
            ),
          ),
        ),
      );
    }

    //El form es un expanded con un scroll y todos los componentes adentro
    return Expanded(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(right: 15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: controls,
        ),
      ),
    );
  }

  // Checar si hay algún campo requiered que no haya sido contestado
  _validateAndSaveForm(List<ControlItem> components) => !components.any((e) =>
      (e.propierties["required"] ?? false) && e.propierties["answer"] == null);


  _saveForm(PaperlessForm form) async {
    List<Response> answers = [];
    for (var element in form.components
        .where((e) => e.propierties["answer"] != null)
        .toList()) {
      answers.add(Response(
        id: element.id,
        required: element.propierties['required'],
        respuesta: element.propierties["answer"],
      ));
    }
    final firebase = ref.read(firebaseProvider(widget.basicRequest.appName));
    final requesterInfo = widget.basicRequest.requesterInfo;
    final request = Answer(
      componentes: answers,
      creator: requesterInfo.userName,
      editado: false,
      email: requesterInfo.userMail,
      fechaCreacion: DateFormat(
        'dd/MM/yyyy, HH:mm:ss',
        'es',
      ).format(DateTime.now()),
      historial: [],
      id: answerId,
      solicitante: requesterInfo.userId,
      status: 'waiting',
    );

    await firebase.saveAnswer(
      answer: request,
      path: "/Formularios/${widget.basicRequest.formId}/Respuestas",
      saveInPaperless: widget.basicRequest.saveInPaperless,
    );

    // todo validar el folio, cuando tiene folio manda una alerta mostrando el folio
    // todo incrementar el folio primero en caso de tenerlo.
  }

  Widget getLabel(bool isRequired, String? label) => label == null
      ? Container()
      : Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            children: [
              if (isRequired)
                const Text("*", style: TextStyle(color: Colors.red)),
              Text(label),
            ],
          ),
        );

  TextInputType getTextInputType(String? type) {
    switch (type) {
      case 'text':
        return TextInputType.text;
      case 'folio':
      case 'number':
        return TextInputType.phone;
      case 'email':
        return TextInputType.emailAddress;
      default:
        return TextInputType.text;
    }
  }

  Widget control(
    ControlItem item,
    String? languageDisplay,
    BuildContext context,
  ) {
    // todo agregar validación para los campos que van inhabilitados
    languageDisplay ??= item.propierties.values.first;
    final language = item.propierties[languageDisplay] ?? {};
    Widget control = Container();
    switch (item.propierties["tipo"]) {
      case 'input':
        if (item.propierties['folio'] != null) {
          item.propierties["answer"] = item.propierties['folio']?.toString();
        }
        control = TextFormField(
          enabled: item.propierties['folio'] == null,
          initialValue: item.propierties['folio']?.toString(),
          textInputAction: TextInputAction.next,
          onChanged: (value) => item.propierties["answer"] = value,
          keyboardType: getTextInputType(item.propierties['type']),
          inputFormatters: (item.propierties['type'] ?? 'text') == 'number' ||
                  (item.propierties['type'] ?? 'text') == 'folio'
              ? [FilteringTextInputFormatter.digitsOnly]
              : null,
          decoration: InputDecoration(
            fillColor: Colors.purple,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            hintText: language?['placeholder'] ?? '',
          ),
        );
        break;
      case 'radio':
      case 'checkbox':
        List<Widget> listChild = [];
        if (language?['options'] != null) {
          listChild.addAll(
            (language?['options'] as List<dynamic>).map(
              (e) => Row(
                children: [
                  if (item.propierties["tipo"] == 'radio')
                    Radio(
                      value: e.toString(),
                      groupValue: item.propierties["answer"] ?? '',
                      onChanged: (value) {
                        item.propierties["answer"] = e.toString();
                        setState(() {});
                      },
                    ),
                  if (item.propierties["tipo"] == 'checkbox')
                    Checkbox(
                      value: ((item.propierties["answer"] ?? []) as List)
                          .contains(e.toString()),
                      onChanged: (value) {
                        if (item.propierties["answer"] == null) {
                          item.propierties["answer"] = [];
                        }
                        if (value as bool) {
                          (item.propierties["answer"] as List)
                              .add(e.toString());
                        } else {
                          (item.propierties["answer"] as List)
                              .remove(e.toString());
                        }
                        setState(() {});
                      },
                    ),
                  Text(e.toString()),
                ],
              ),
            ),
          );
        }
        control = SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: listChild),
        );
        break;
      case 'divider':
        return Row(children: [
          if (item.propierties['orientation'] == 'center' ||
              item.propierties['orientation'] == 'right')
            const Expanded(child: Divider()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              language?['title'],
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: (item.propierties['size'] ?? 0) == 2
                    ? 20
                    : ((item.propierties['size'] ?? 0) == 3
                        ? 18
                        : (item.propierties['size'] ?? 0) == 4
                            ? 16
                            : 14),
              ),
            ),
          ),
          if (item.propierties['orientation'] == 'center' ||
              item.propierties['orientation'] == 'left')
            const Expanded(child: Divider()),
        ]);
      case 'select':
        if (item.propierties['mode'] == 'default') {
          control = DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: const Color(0xFF9b9b9b)),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: DropdownButton(
                hint: Text(language?['placeholder'] ?? ''),
                value: item.propierties["answer"],
                items: (language?['options'] as List<dynamic>)
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) {
                  item.propierties["answer"] = value;
                  setState(() {});
                },
                isExpanded: true,
                underline: Container(),
              ),
            ),
          );
        } else {
          control = DropDownMultiSelect(
            onChanged: (x) => setState(() => item.propierties["answer"] = x),
            options: (language?['options'] as List<dynamic>)
                .map((e) => e.toString())
                .toList(),
            selectedValues: item.propierties["answer"] ?? [],
            whenEmpty: 'Select Something',
          );
        }
        break;
      case 'calendar':
        if (item.propierties['currentDate'] ?? false) {
          if (item.propierties["answer"] == null) {
            item.propierties["answer"] =
                DateFormat('dd/MM/yyyy', 'es').format(DateTime.now());
          }
          control = TextFormField(
            enabled: false,
            // todo revisar porque no se gurda
            initialValue: item.propierties["answer"],
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
              hintText: language?['placeholder'] ?? '',
            ),
          );
        } else {
          control = GestureDetector(
            onTap: () async {
              final date = await showDatePicker(
                initialDate: item.propierties["answer"] != null
                    ? DateFormat('dd/MM/yyyy').parse(item.propierties["answer"])
                    : DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime(2100),
                context: context,
              );
              if (date != null) {
                item.propierties["answer"] =
                    DateFormat('dd/MM/yyyy', 'es').format(date);
                setState(() {});
              }
            },
            child: TextFormField(
              key: UniqueKey(),
              enabled: false,
              initialValue: item.propierties["answer"],
              decoration: InputDecoration(
                suffixIcon: const Icon(Icons.calendar_month),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
                hintText: language?['placeholder'] ?? '',
              ),
            ),
          );
        }
        break;
      case 'datepicker':
        control = GestureDetector(
          onTap: () async {
            final date = await showDateRangePicker(
              initialDateRange: item.propierties["answer"] == null
                  ? DateTimeRange(start: DateTime.now(), end: DateTime.now())
                  : _getDateTimeRange(item.propierties["answer"]),
              firstDate: DateTime(1900),
              lastDate: DateTime(2100),
              context: context,
            );
            if (date != null) {
              item.propierties["answer"] = [
                DateFormat('dd/MM/yyyy', 'es').format(date.start),
                DateFormat('dd/MM/yyyy', 'es').format(date.end),
              ];
              setState(() {});
            }
          },
          child: TextFormField(
            key: UniqueKey(),
            enabled: false,
            initialValue: item.propierties["answer"] == null
                ? null
                : "${item.propierties["answer"][0]} - ${item.propierties["answer"][1]}",
            decoration: InputDecoration(
              suffixIcon: const Icon(Icons.calendar_month),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
              hintText: language?['placeholder'] ?? 'Start date - End date',
            ),
          ),
        );
        break;
      case 'time':
        control = GestureDetector(
          onTap: () async {
            final date = await showTimePicker(
              initialTime: item.propierties["answer"] == null
                  ? TimeOfDay(
                      hour: DateTime.now().hour,
                      minute: DateTime.now().minute,
                    )
                  : _getTime(item.propierties["answer"]),
              context: context,
            );
            if (date != null) {
              item.propierties["answer"] = "${date.hour}:${date.minute}:00";
              setState(() {});
            }
          },
          child: TextFormField(
            key: UniqueKey(),
            enabled: false,
            initialValue: item.propierties["answer"],
            decoration: InputDecoration(
              suffixIcon: const Icon(Icons.watch_later_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
              hintText: language?['placeholder'] ?? 'Start date - End date',
            ),
          ),
        );
        break;
      case 'rate':
        control = RatingBar.builder(
          initialRating: item.propierties["answer"] ?? 0,
          minRating: 1,
          direction: Axis.horizontal,
          allowHalfRating: true,
          itemCount: 5,
          itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
          itemBuilder: (context, _) => const Icon(
            Icons.star,
            color: Colors.amber,
          ),
          onRatingUpdate: (rating) => item.propierties["answer"] = rating,
        );
        break;
      case 'upComponent':
        List<Widget> list = [
          OutlinedButton(
            onPressed: () async {
              item.propierties["answer"] = await _uploadFile(
                context,
                item.propierties["answer"] as List<dynamic>?,
                true,
                widget.basicRequest.formId,
                widget.basicRequest.companyId,
                item.id,
              );
              setState(() {});
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.file_upload_outlined),
                Text(language['file']),
              ],
            ),
          ),
        ];
        if (item.propierties["answer"] != null) {
          final answer = (item.propierties["answer"] as List<dynamic>);
          for (var element in answer) {
            if (element is! FileUploaded) {
              final filename = basename(File(element).path)
                  .toString()
                  .split('?')[0]
                  .split('%2F');
              list.add(
                GestureDetector(
                  onTap: () async {
                    await _deleteFile(element);
                    (item.propierties["answer"] as List<dynamic>)
                        .remove(element);
                    setState(() {});
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Icon(Icons.highlight_remove, size: 15),
                        const SizedBox(width: 10),
                        Text(filename[filename.length - 1]),
                      ],
                    ),
                  ),
                ),
              );
            } else {
              list.add(Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const SizedBox(
                          width: 10,
                          height: 10,
                          child: CircularProgressIndicator(),
                        ),
                        const SizedBox(width: 10),
                        Text(element.name),
                      ],
                    ),
                    const SizedBox(height: 5),
                    StreamBuilder<TaskSnapshot>(
                      stream: element.task!.snapshotEvents,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final data = snapshot.data!;
                          double? progress;
                          if (data.totalBytes == 0) {
                            progress = 1;
                          } else {
                            progress = data.bytesTransferred / data.totalBytes;
                          }
                          if (progress == 1) {
                            data.ref.getDownloadURL().then(
                              (value) {
                                final index = (item.propierties["answer"]
                                        as List<dynamic>)
                                    .indexOf(element);
                                (item.propierties["answer"] as List<dynamic>)
                                    .removeAt(index);
                                (item.propierties["answer"] as List<dynamic>)
                                    .insert(index, value);
                                setState(() {});
                              },
                            ).whenComplete(() {});
                          }
                          return LinearProgressIndicator(value: progress);
                        }
                        return Container();
                      },
                    ),
                  ],
                ),
              ));
            }
          }
        }
        control = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: list,
        );
        break;
      case 'photo':
        List<Widget> list = [
          SizedBox(
            height: 100,
            width: 100,
            child: OutlinedButton(
              onPressed: () async {
                item.propierties["answer"] = await _uploadFile(
                  context,
                  item.propierties["answer"] as List<dynamic>?,
                  false,
                  widget.basicRequest.formId,
                  widget.basicRequest.companyId,
                  item.id,
                );
                setState(() {});
              },
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add_a_photo_outlined),
                    Text(language['title']),
                  ],
                ),
              ),
            ),
          ),
        ];
        if (item.propierties["answer"] != null) {
          final answer = (item.propierties["answer"] as List<dynamic>);
          for (var element in answer) {
            if (element is! FileUploaded) {
              list.add(
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: SizedBox(
                    height: 100,
                    width: 100,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      onEnter: (_) => setState(() => _showDeleteImg = true),
                      onExit: (_) => setState(() => _showDeleteImg = false),
                      child: Stack(
                        children: [
                          OutlinedButton(
                            onPressed: () {},
                            child: Center(
                              child: CachedNetworkImage(
                                imageUrl: element,
                                width: 80,
                                height: 80,
                                fit: BoxFit.fill,
                                errorWidget: (w, ww, er) {
                                  return const SizedBox(
                                    width: 80,
                                    height: 80,
                                    child: Center(child: Text("NA")),
                                  );
                                },
                                placeholder: (context, url) {
                                  return const SizedBox(
                                    height: 80,
                                    width: 80,
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          if (_showDeleteImg)
                            Expanded(
                              child: GestureDetector(
                                onTap: () async {
                                  await _deleteFile(element);
                                  (item.propierties["answer"] as List<dynamic>)
                                      .remove(element);
                                  setState(() {});
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(4.0),
                                  ),
                                  child:
                                      const Center(child: Icon(Icons.delete)),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            } else {
              list.add(Padding(
                padding: const EdgeInsets.only(left: 10),
                child: StreamBuilder<TaskSnapshot>(
                  stream: element.task!.snapshotEvents,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final data = snapshot.data!;
                      double? progress;
                      if (data.totalBytes == 0) {
                        progress = 1;
                      } else {
                        progress = data.bytesTransferred / data.totalBytes;
                      }
                      if (progress == 1) {
                        data.ref.getDownloadURL().then((value) {
                          final index =
                              (item.propierties["answer"] as List<dynamic>)
                                  .indexOf(element);
                          (item.propierties["answer"] as List<dynamic>)
                              .removeAt(index);
                          (item.propierties["answer"] as List<dynamic>)
                              .insert(index, value);
                          setState(() {});
                        });
                      }
                      return SizedBox(
                        height: 100,
                        width: 100,
                        child: OutlinedButton(
                          onPressed: () => {},
                          child: Center(
                            child: SizedBox(
                              height: 80,
                              width: 80,
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: progress,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    return Container();
                  },
                ),
              ));
            }
          }
        }
        control = Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: list,
        );
        break;
      case 'textarea':
        final HtmlEditorController controller = HtmlEditorController();
        control = Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: HtmlEditor(
            controller: controller, //required
            htmlEditorOptions: HtmlEditorOptions(
              hint: item.propierties['Spanish']['placeholder'],
            ),
            otherOptions: const OtherOptions(height: 400),
          ),
        );
        break;

      case 'multipleselect':
        print("wowza");
        break;

      // todo hacer el multi-Select
      /* if (item.propierties['mode'] == 'default') {
          return DropdownButton(
            items: (language?['options'] as List<dynamic>)
                .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
                .toList(),
            onChanged: (value) => item.propierties["answer"] = value,
          );
        }
        
        */
      default:
        control = Text("${item.id} ${item.layout["y"]}-${item.layout["x"]} ");
        break;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        getLabel(item.propierties['required'] ?? false, language?['title']),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Tooltip(message: language?['popover1'] ?? '', child: control),
        ),
      ],
    );
  }

  _getDateTimeRange(List<String> answer) {
    return DateTimeRange(
      start: DateFormat('dd/MM/yyyy').parse(answer[0].toString()),
      end: DateFormat('dd/MM/yyyy').parse(answer[1].toString()),
    );
  }

  _getTime(String time) {
    final timeSplit = time.split(":");
    return TimeOfDay(
      hour: int.parse(timeSplit[0]),
      minute: int.parse(timeSplit[1]),
    );
  }

  _uploadFile(
    context,
    List<dynamic>? answer,
    bool isMultiFile,
    String formId,
      String companyId,
    String controlId,
  ) async {
    final firebase = ref.read(firebaseProvider(widget.basicRequest.appName));
    answerId ??= await firebase.getDocumentId(
      companyId: companyId,
      formId: formId,
      saveInPaperless: widget.basicRequest.saveInPaperless,
    );

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: isMultiFile,
    );

    if (result != null) {
      if (kIsWeb) {
        answer ??= [];
        for (var element in result.files) {
          final metadata = SettableMetadata(
              contentType: lookupMimeType(
            element.name,
            headerBytes: element.bytes,
          ));
          answer.add(
            FileUploaded(
              url: "",
              name: element.name,
              task: firebase.uploadFile(
                'Formulario/$formId/$answerId/$controlId/${element.name}',
                element.bytes,
                null,
                metadata,
                widget.basicRequest.saveInPaperless,
              ),
            ),
          );
        }
        return answer;
      } else {
        // todo - este es para el celular
        var path2 = result.files.single.path;
        if (!item.contains(path2)) {
          item.add(path2);
          File file = File(path2 ?? "");
          setState(() {
            widgets.add(
              SizedBox(height: 100, width: 100, child: Image.file(file)),
            );
          });
        }
        return answer;
      }
    }
    return answer;
  }

  _deleteFile(String path) async {
    final firebase = ref.read(firebaseProvider(widget.basicRequest.appName));
    await firebase.removeFile(
      path: path,
      saveInPaperless: widget.basicRequest.saveInPaperless,
    );
  }
}
