import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:tesis/data/model/mensaje_model.dart';
import 'package:tesis/data/model/get_usuario_model.dart';
import 'package:tesis/data/services/ai_service.dart';
import 'package:tesis/data/services/usuario_services.dart';
import 'package:tesis/presentation/widgets/side_menu.dart';

class ConsultasScreen extends StatefulWidget {
  static const String name = 'consultas_screen';

  final String? mensajeInicial;

  const ConsultasScreen({super.key, this.mensajeInicial});

  @override
  State<ConsultasScreen> createState() => _ConsultasScreenState();
}

class _ConsultasScreenState extends State<ConsultasScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Mensaje> mensajes = [];

  int? usuarioId;
  bool cargandoUsuario = true;

  @override
  void initState() {
    super.initState();
    obtenerUsuarioDesdeFirebase();
  }

  void obtenerUsuarioDesdeFirebase() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null && user.email != null) {
        final email = user.email!;
        final usuario = await UsuarioService().getUsuarioPorEmail(email);
        if (!mounted) return;
        setState(() {
          usuarioId = usuario.id;
          cargandoUsuario = false;
        });

        cargarMensajeInicial();
      } else {
        if (!mounted) return;
        setState(() => cargandoUsuario = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => cargandoUsuario = false);
    }
  }

  void cargarMensajeInicial() async {
    if (usuarioId == null) return;

    final mensajeInicial = widget.mensajeInicial;

    if (mensajeInicial != null && mensajeInicial.isNotEmpty) {
      setState(() {
        mensajes.add(Mensaje(texto: mensajeInicial, esUsuario: true));
      });
      _scrollToBottom();

      try {
        final respuesta =
            await ConsultaService.consultarIA(mensajeInicial, usuarioId!);

        setState(() {
          mensajes.add(Mensaje(texto: respuesta, esUsuario: false));
        });
        _scrollToBottom();

        try {
          final parsed = json.decode(respuesta);
          if (parsed is Map &&
              parsed["tipo"] == "repetir_turno" &&
              parsed["sugerencia_repetir_medico_id"] != null) {
            final medicoId = parsed["sugerencia_repetir_medico_id"];
            context.push('/main/turnos', extra: {"medico_id": medicoId});
          }
        } catch (_) {
          // No hacemos nada si la respuesta no es un JSON válido
        }
      } catch (e) {
        setState(() {
          mensajes.add(Mensaje(
            texto: 'Error al procesar la respuesta de IA.',
            esUsuario: false,
          ));
        });
      }

      return;
    }

    // Si no se pasó un mensajeInicial, cargamos la bienvenida
    try {
      final mensajeApi = await ConsultaService.consultarIA('', usuarioId!);
      if (!mounted) return;
      setState(() {
        mensajes.add(Mensaje(texto: mensajeApi, esUsuario: false));
      });
    } catch (e) {
      setState(() {
        mensajes.add(Mensaje(
          texto: '👋 ¡Hola! Soy Stack. Podés consultarme para:\n\n'
              '🏥 Recomendarte médicos según tus síntomas\n'
              '📅 Ver la agenda de un médico\n'
              '📌 Reservar un turno con un médico en particular',
          esUsuario: false,
        ));
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void enviarMensaje() async {
    final texto = _controller.text.trim();
    if (texto.isEmpty || usuarioId == null) return;

    setState(() {
      mensajes.add(Mensaje(texto: texto, esUsuario: true));
      _controller.clear();
    });
    _scrollToBottom();

    try {
      final respuesta = await ConsultaService.consultarIA(texto, usuarioId!);

      setState(() {
        mensajes.add(Mensaje(texto: respuesta, esUsuario: false));
      });
      _scrollToBottom();

      try {
        final parsed = json.decode(respuesta);
        if (parsed is Map &&
            parsed["tipo"] == "repetir_turno" &&
            parsed["sugerencia_repetir_medico_id"] != null) {
          final medicoId = parsed["sugerencia_repetir_medico_id"];
          context.push('/main/turnos', extra: {"medico_id": medicoId});
        }
      } catch (_) {
        // No hacemos nada si la respuesta no es un JSON válido
      }
    } catch (e) {
      setState(() {
        mensajes.add(
          Mensaje(texto: 'Error al obtener respuesta.', esUsuario: false),
        );
      });
      _scrollToBottom();
    }
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        children: const [
          CircleAvatar(
            radius: 20,
            backgroundColor: Color(0xFF1b4a5a),
            child:
                FaIcon(FontAwesomeIcons.robot, color: Colors.white, size: 18),
          ),
          SizedBox(width: 10),
          Text(
            'Stack',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMensaje(Mensaje mensaje) {
    final isUser = mensaje.esUsuario;
    final bubbleColor = isUser ? const Color(0xFFd3f8fa) : Colors.grey[300];
    final alignment = isUser ? Alignment.centerRight : Alignment.centerLeft;

    final borderRadius = BorderRadius.only(
      topLeft: const Radius.circular(15),
      topRight: const Radius.circular(15),
      bottomLeft: isUser ? const Radius.circular(15) : const Radius.circular(0),
      bottomRight:
          isUser ? const Radius.circular(0) : const Radius.circular(15),
    );

    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: borderRadius,
        ),
        child: Text(
          mensaje.texto,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildInputField() {
    if (cargandoUsuario) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: CircularProgressIndicator(),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: 'Escribe un mensaje...',
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
              ),
            ),
            IconButton(
              icon: const FaIcon(FontAwesomeIcons.paperPlane,
                  color: Color(0xFF1b4a5a)),
              onPressed: enviarMensaje,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      drawer: SideMenu(scaffoldKey: scaffoldKey),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(10),
                itemCount: mensajes.length,
                itemBuilder: (context, index) => _buildMensaje(mensajes[index]),
              ),
            ),
            _buildInputField(),
          ],
        ),
      ),
    );
  }
}
