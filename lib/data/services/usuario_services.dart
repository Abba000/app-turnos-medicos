import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tesis/data/model/get_usuario_model.dart';

class UsuarioService {
  static const String baseUrl = 'http://192.168.110.69:3000';
  //static const String baseUrl = 'http://192.168.1.16:3000';

  Future<UsuarioModel> getUsuarioPorEmail(String email) async {
    final url = Uri.parse('$baseUrl/usuarios/${Uri.encodeComponent(email)}');
    print('Consultando usuario en: $url');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return UsuarioModel.fromJson(data); // Ya es un JSON directo
    } else {
      throw Exception('Error al obtener usuario: ${response.statusCode}');
    }
  }

  Future<bool> updateUsuario({
    required String mail,
    required String nombre,
    String? img,
    bool? comparteInformacion,
  }) async {
    final url = Uri.parse('$baseUrl/usuarios/$mail');
    final body = {
      'nombre': nombre,
      'comparte_informacion': comparteInformacion,
    };

    if (img != null) {
      body['img'] = img;
    }

    final response = await http.patch(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    return response.statusCode == 200;
  }

  Future<void> loginOCrearUsuario({
    required String nombre,
    required String email,
    String? img,
  }) async {
    final encodedEmail = Uri.encodeComponent(email);
    final getUrl = Uri.parse('$baseUrl/usuarios/$encodedEmail');

    print("Consultando usuario en: $getUrl");

    final response = await http.get(getUrl);
    print("Respuesta statusCode: ${response.statusCode}");
    print("Respuesta body: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Verificar si backend devuelve un error dentro de body
      if (data is Map<String, dynamic> && data['status'] == 404) {
        print("🆕 Usuario no encontrado, creando nuevo...");

        final postUrl = Uri.parse('$baseUrl/usuarios');
        final body = {
          'nombre': nombre,
          'mail': email,
          'img': img,
          'rol_id': 2,
        };

        final createResponse = await http.post(
          postUrl,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        );

        if (createResponse.statusCode == 201 ||
            createResponse.statusCode == 200) {
          print("✅ Usuario creado correctamente");
        } else {
          throw Exception('❌ No se pudo crear el usuario');
        }
      } else {
        print("✅ Usuario ya existe");
        return;
      }
    } else if (response.statusCode == 404) {
      // Caso ideal si backend usara 404 para no encontrado
      print("🆕 Usuario no encontrado, creando nuevo...");

      final postUrl = Uri.parse('$baseUrl/usuarios');
      final body = {
        'nombre': nombre,
        'mail': email,
        'img': img,
        'rol_id': 2,
      };

      final createResponse = await http.post(
        postUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (createResponse.statusCode == 201 ||
          createResponse.statusCode == 200) {
        print("✅ Usuario creado correctamente");
      } else {
        throw Exception('❌ No se pudo crear el usuario');
      }
    } else {
      throw Exception(
          '❌ Error inesperado al verificar usuario: ${response.statusCode}');
    }
  }
}
