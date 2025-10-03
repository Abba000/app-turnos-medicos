class TurnoUsuarioModel {
  final int id;
  final DateTime fecha;
  final String nombre;
  final String? dni;
  final String mail;
  final String? quien;
  final int medicoId;
  final int usuarioId;
  final int turnoEstadoId;
  final String? nombreMedico;

  TurnoUsuarioModel({
    required this.id,
    required this.fecha,
    required this.nombre,
    required this.dni,
    required this.mail,
    required this.quien,
    required this.medicoId,
    required this.usuarioId,
    required this.turnoEstadoId,
    this.nombreMedico,
  });

  factory TurnoUsuarioModel.fromJson(Map<String, dynamic> json) {
    final medico = json['medico'];
    final usuarioMedico = medico != null ? medico['usuario'] : null;
    final nombreMedico = usuarioMedico != null ? usuarioMedico['nombre'] : null;

    return TurnoUsuarioModel(
      id: json['id'],
      // ✅ Asegura que la fecha se convierta a la hora local
      fecha: DateTime.parse(json['fecha']).toLocal(),
      nombre: json['nombre'],
      dni: json['dni'],
      mail: json['mail'],
      quien: json['quien'],
      medicoId: json['medico_id'],
      usuarioId: json['usuario_id'],
      turnoEstadoId: json['turno_estado_id'],
      nombreMedico: nombreMedico,
    );
  }
}
