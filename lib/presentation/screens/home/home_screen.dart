import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:tesis/data/model/ger_turnos_usuario_model.dart';
import 'package:tesis/data/model/get_usuario_model.dart';
import 'package:tesis/data/services/ai_service.dart';
import 'package:tesis/data/services/turno_service.dart';
import 'package:tesis/data/services/usuario_services.dart';
import 'package:tesis/presentation/widgets/turno_card.dart';

class HomeScreen extends StatefulWidget {
  static const String name = 'home';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<UsuarioModel> _usuarioFuture;
  List<TurnoUsuarioModel> _turnos = [];
  bool mostrarProximos = true;
  String? _mensajeRecomendacion;

  final _usuarioService = UsuarioService();
  final _turnosService = TurnosService();

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser!;
    _usuarioFuture = _usuarioService.getUsuarioPorEmail(user.email!);
    _usuarioFuture.then((usuario) async {
      _loadTurnos(usuario.id);

      try {
        final mensaje = await ConsultaService.consultarIA(
            "historial_recomendacion", usuario.id);
        if (!mensaje.contains("No encontramos controles anteriores")) {
          setState(() {
            _mensajeRecomendacion = mensaje;
          });
        }
      } catch (e) {
        print('Error al consultar IA: $e');
      }
    });
  }

  Future<void> _loadTurnos(int usuarioId) async {
    try {
      final turnos = await _turnosService.getTurnosUsuario(usuarioId);
      setState(() {
        _turnos = turnos;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al cargar turnos')),
      );
    }
  }

  void _mostrarDialogoCancelarTurno(int turnoId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Cancelar turno?'),
        content: const Text('¿Estás seguro de que deseas cancelar este turno?'),
        actions: [
          TextButton(
            child: const Text('No'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.of(context).pop();
              _cancelarTurno(turnoId);
            },
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    );
  }

  void _cancelarTurno(int turnoId) async {
    try {
      await _turnosService.cancelarTurno(turnoId);
      setState(() {
        _turnos.removeWhere((t) => t.id == turnoId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Turno cancelado')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al cancelar turno')),
      );
    }
  }

  Widget _asistenteWidget(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF1b4a5a),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child:
                  FaIcon(FontAwesomeIcons.robot, color: Colors.white, size: 25),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Hola soy Stack',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  'Tu asistente disponible las 24 horas',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.paperPlane,
                color: Color(0xFF1b4a5a)),
            onPressed: () {
              context.go('/main/consultas');
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('No hay usuario logueado')),
      );
    }

    final now = DateTime.now();
    final turnosFuturos = _turnos.where((t) => t.fecha.isAfter(now)).toList();
    final turnosPasados = _turnos.where((t) => !t.fecha.isAfter(now)).toList();
    final turnosAMostrar = mostrarProximos ? turnosFuturos : turnosPasados;
    final noHayTurnosTexto =
        mostrarProximos ? 'No hay próximos turnos' : 'No hay turnos anteriores';

    return Scaffold(
      body: FutureBuilder<UsuarioModel>(
        future: _usuarioFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Error al cargar usuario'));
          }

          final usuario = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bienvenido, ${usuario.nombre}',
                  style: const TextStyle(fontSize: 22),
                ),
                const SizedBox(height: 12),
                _asistenteWidget(context),
                const SizedBox(height: 16),

                // Botones de filtro
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => mostrarProximos = true),
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: mostrarProximos
                                ? const Color(0xFF1b4a5a)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: mostrarProximos
                                  ? const Color(0xFF1b4a5a)
                                  : Colors.grey,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Próximos turnos',
                              style: TextStyle(
                                color: mostrarProximos
                                    ? Colors.white
                                    : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => mostrarProximos = false),
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: !mostrarProximos
                                ? const Color(0xFF1b4a5a)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: !mostrarProximos
                                  ? const Color(0xFF1b4a5a)
                                  : Colors.grey,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Historial',
                              style: TextStyle(
                                color: !mostrarProximos
                                    ? Colors.white
                                    : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Expanded(
                  child: turnosAMostrar.isEmpty
                      ? Center(child: Text(noHayTurnosTexto))
                      : ListView.builder(
                          itemCount: turnosAMostrar.length,
                          itemBuilder: (context, index) {
                            final turno = turnosAMostrar[index];
                            return turnoCard(
                              turno,
                              mostrarProximos
                                  ? () => _mostrarDialogoCancelarTurno(turno.id)
                                  : null,
                              showCancelar: mostrarProximos,
                            );
                          },
                        ),
                ),

                // ✅ Mensaje de IA con botón clickeable
                if (_mensajeRecomendacion != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: GestureDetector(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFe0f7fa),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF1b4a5a)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _mensajeRecomendacion!,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
