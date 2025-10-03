import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tesis/data/model/get_medicos_model.dart';

class MedicosService {
  static const String baseUrl = 'http://192.168.110.69:3000';
  //static const String baseUrl = 'http://192.168.1.16:3000';

  Future<List<MedicosModel>> getMedicos() async {
    final url = Uri.parse('$baseUrl/medicos');
    print('Llamando a $url');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => MedicosModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener médicos: ${response.statusCode}');
    }
  }
}
