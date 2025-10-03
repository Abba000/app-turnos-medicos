class MedicosModel {
  final int id;
  final int especialidadId;
  final String usuarioMail;
  final Especialidad especialidad;
  final Usuario usuario;

  MedicosModel({
    required this.id,
    required this.especialidadId,
    required this.usuarioMail,
    required this.especialidad,
    required this.usuario,
  });

  factory MedicosModel.fromJson(Map<String, dynamic> json) {
    return MedicosModel(
      id: json['id'],
      especialidadId: json['especialidad_id'],
      usuarioMail: json['usuario_mail'],
      especialidad: Especialidad.fromJson(json['especialidad']),
      usuario: Usuario.fromJson(json['usuario']),
    );
  }
}

class Especialidad {
  final int id;
  final String nombre;
  final String filePath;

  Especialidad({
    required this.id,
    required this.nombre,
    required this.filePath,
  });

  factory Especialidad.fromJson(Map<String, dynamic> json) {
    return Especialidad(
      id: json['id'],
      nombre: json['nombre'],
      filePath: json['file_path'],
    );
  }
}

class Usuario {
  final int id;
  final String nombre;
  final String mail;
  final int rolId;
  final String? img;

  Usuario({
    required this.id,
    required this.nombre,
    required this.mail,
    required this.rolId,
    this.img,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'],
      nombre: json['nombre'],
      mail: json['mail'],
      rolId: json['rol_id'],
      img: json['img'],
    );
  }
}
