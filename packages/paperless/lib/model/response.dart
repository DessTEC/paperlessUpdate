class Response {
  const Response({
    required this.id,
    required this.required,
    required this.respuesta,
  });

  final String id;
  final bool? required;
  final Object? respuesta;

  toMap() => {'id': id, 'required': required, 'respuesta': respuesta};
}
