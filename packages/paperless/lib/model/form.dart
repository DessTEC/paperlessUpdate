class PaperlessForm {
  const PaperlessForm({
    required this.id,
    required this.name,
    required this.hidden,
    required this.status,
    required this.language,
    required this.components,

    /*required this.approvers,
    required this.approver,
    required this.comment,
    required this.creator,
    required this.company,
    required this.approveDate,
    required this.creationDate,
    required this.language,
    required this.message,
    required this.save,
    required this.size,
    required this.answers,
    required this.approverInfo,*/
  });

  final String id;
  final String name;
  final bool hidden;
  final bool status;
  final String? language;
  final List<ControlItem> components;

  /*final Map<String, dynamic> approvers;
  final String? approver;
  final String? comment;
  final String? creator;
  final String? company;
  final String? approveDate;
  final String? creationDate;
  final String message;
  final bool? save;
  final int size;
  final List<Map<String, dynamic>> answers;
  final Map<String, dynamic> approverInfo;*/

  factory PaperlessForm.fromMap(Map<String, dynamic> data) {
    final id = (data['id'] ?? "").toString();
    final name = (data['Nombre'] ?? "").toString();
    final hidden = (data['hidden'] ?? false) as bool;
    final status = (data['status'] ?? false) as bool;
    final language = data['idioma'];
    List<ControlItem> components = [];

    (data['componentes'] as Map<String, dynamic>).forEach((key, value) {
      components.add(ControlItem.fromMap(value));
    });

    return PaperlessForm(
      id: id,
      name: name,
      hidden: hidden,
      status: status,
      language: language,
      components: components,
    );
  }
}

class ControlItem {
  const ControlItem({
    required this.id,
    required this.propierties,
    required this.layout,
    required this.enabledControl,
  });

  final String id;
  final Map<String, dynamic> propierties;
  final Map<String, dynamic> layout;
  final bool enabledControl;

  factory ControlItem.fromMap(Map<String, dynamic> data) {
    final id = (data['id'] ?? "").toString();

    return ControlItem(
      layout: data['layout'],
      propierties: data['propiedades'],
      enabledControl: false,
      id: id,
    );
  }
}