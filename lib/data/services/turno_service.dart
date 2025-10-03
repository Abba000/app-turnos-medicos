import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tesis/data/model/ger_turnos_usuario_model.dart';
import 'package:tesis/data/model/get_turnos_medico_model.dart';

class TurnosService {
  static const String baseUrl = 'http://192.168.110.69:3000';
  //static const String baseUrl = 'http://192.168.1.16:3000';

  Future<List<TurnoMedicoModel>> getTurnosPorMedico(
      int medicoId, DateTime fecha) async {
    final fechaFormatted = "${fecha.toIso8601String().substring(0, 10)}";
    final url =
        Uri.parse('$baseUrl/turnos/medico/$medicoId?fecha=$fechaFormatted');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => TurnoMedicoModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener turnos: ${response.statusCode}');
    }
  }

  // 🔹 Reservar un turno
  Future<bool> reservarTurno({
    required int turnoId,
    required String nombre,
    required String mail,
    required int usuarioId,
    int turnoEstadoId = 2, // 2 = reservado
  }) async {
    final url = Uri.parse('$baseUrl/turnos/reserva/$turnoId');

    final body = jsonEncode({
      "nombre": nombre,
      "mail": mail,
      "usuario_id": usuarioId,
      "turno_estado_id": turnoEstadoId,
    });

    final response = await http.patch(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Error al reservar turno: ${response.statusCode}');
    }
  }

  Future<List<TurnoUsuarioModel>> getTurnosUsuario(int usuarioId) async {
    final url = Uri.parse('$baseUrl/turnos/usuario/$usuarioId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => TurnoUsuarioModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener turnos');
    }
  }

  Future<void> cancelarTurno(int turnoId) async {
    final url = Uri.parse('$baseUrl/turnos/cancel/$turnoId');
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Error al cancelar turno');
    }
  }
}
