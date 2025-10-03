import 'dart:convert';
import 'package:http/http.dart' as http;

class ConsultaService {
  static const String baseUrl = 'http://192.168.110.69:3000';
  //static const String baseUrl = 'http://192.168.1.16:3000';

  static Future<String> consultarIA(String prompt, int usuarioId) async {
    final url = Uri.parse('$baseUrl/ai/consulta');
    print('Llamando a $url con body: ${jsonEncode({
          "prompt": prompt,
          "usuario_id": usuarioId,
        })}');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "prompt": prompt,
        "usuario_id": usuarioId,
      }),
    );

    print('Status code: ${response.statusCode}');
    print('Body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data["mensaje"] ?? "Respuesta no entendida.";
    } else {
      throw Exception('Error en la consulta: ${response.statusCode}');
    }
  }
}
