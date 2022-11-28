import 'package:paperless/model/response.dart';

class Answer {
  const Answer({
    required this.componentes,
    required this.creator,
    required this.editado,
    required this.email,
    required this.fechaCreacion,
    required this.historial,
    required this.id,
    required this.solicitante,
    required this.status,
  });

  final List<Response> componentes;
  final String creator;
  final bool editado;
  final String email;
  final String fechaCreacion;
  final List<Object> historial;
  final String? id;
  final String solicitante;
  final String status;

  toMap() => {
    'Componentes': componentes.map((e) => e.toMap()),
    'creator': creator,
    'editado': editado,
    'email': email,
    'fechaCreacion': fechaCreacion,
    'historial': historial,
    'id': id,
    'solicitante': solicitante,
    'status': status,
    'paperlessPackage': true,
  };
}