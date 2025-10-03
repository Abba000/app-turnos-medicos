class TurnoMedicoModel {
  final int id;
  final DateTime fecha;
  final String? nombre;
  final String? dni;
  final String? mail;
  final String? quien;
  final int medicoId;
  final int? usuarioId;
  final int turnoEstadoId;

  TurnoMedicoModel({
    required this.id,
    required this.fecha,
    this.nombre,
    this.dni,
    this.mail,
    this.quien,
    required this.medicoId,
    this.usuarioId,
    required this.turnoEstadoId,
  });

  factory TurnoMedicoModel.fromJson(Map<String, dynamic> json) {
    return TurnoMedicoModel(
      id: json['id'],
      fecha: DateTime.parse(json['fecha']).toLocal(),
      nombre: json['nombre'],
      dni: json['dni'],
      mail: json['mail'],
      quien: json['quien'],
      medicoId: json['medico_id'],
      usuarioId: json['usuario_id'],
      turnoEstadoId: json['turno_estado_id'],
    );
  }
}
