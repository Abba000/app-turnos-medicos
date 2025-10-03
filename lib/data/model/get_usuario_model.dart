class UsuarioModel {
  final int id;
  final String nombre;
  final String mail;
  final int rolId;
  final dynamic img;
  final dynamic medico;
  final dynamic paciente;
  final bool comparteInformacion;

  UsuarioModel({
    required this.id,
    required this.nombre,
    required this.mail,
    required this.rolId,
    this.img,
    this.medico,
    this.paciente,
    required this.comparteInformacion,
  });

  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    return UsuarioModel(
      id: json['id'],
      nombre: json['nombre'],
      mail: json['mail'],
      rolId: json['rol_id'],
      img: json['img'],
      medico: json['medico'],
      paciente: json['paciente'],
      comparteInformacion: json.containsKey('comparte_informacion')
          ? json['comparte_informacion'] == true
          : false,
    );
  }
}
