import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tesis/data/model/get_turnos_medico_model.dart';
import 'package:tesis/data/services/turno_service.dart';
import 'package:tesis/data/services/usuario_services.dart';
import 'package:tesis/presentation/screens/turnos/reservar_turno_screen.dart';

class AgendaTurnosScreen extends StatefulWidget {
  final int medicoId;
  final String medicoNombre;

  const AgendaTurnosScreen({
    super.key,
    required this.medicoId,
    required this.medicoNombre,
  });

  @override
  State<AgendaTurnosScreen> createState() => _AgendaTurnosScreenState();
}

class _AgendaTurnosScreenState extends State<AgendaTurnosScreen> {
  final TurnosService turnosService = TurnosService();
  final UsuarioService usuarioService = UsuarioService();

  late DateTime selectedDate;
  late DateTime monthShown;
  late Future<List<TurnoMedicoModel>> turnosFuture = Future.value([]);

  final ScrollController _scrollController = ScrollController();
  int? usuarioId;
  double? containerWidth;

  bool _primerScrollRealizado = false;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    monthShown = DateTime.now();
    _inicializarUsuarioYTurnos();
  }

  Future<void> _inicializarUsuarioYTurnos() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.email != null) {
      try {
        final usuario = await usuarioService.getUsuarioPorEmail(user.email!);
        setState(() {
          usuarioId = usuario.id;
        });
        _loadTurnos(usuario.id);
      } catch (e) {
        print("Error al obtener usuario: $e");
      }
    }
  }

  void _loadTurnos(int userId) {
    setState(() {
      turnosFuture = turnosService
          .getTurnosPorMedico(widget.medicoId, selectedDate)
          .then((turnos) {
        return turnos.where((turno) {
          return turno.turnoEstadoId == 1 || turno.usuarioId == userId;
        }).toList();
      });
    });
  }

  List<DateTime> getDiasDelMes(DateTime fecha) {
    final now = DateTime.now();
    final ultimoDia = DateTime(fecha.year, fecha.month + 1, 0);
    final desde =
        (fecha.year == now.year && fecha.month == now.month) ? now.day : 1;

    return List.generate(
      ultimoDia.day - desde + 1,
      (i) => DateTime(fecha.year, fecha.month, desde + i),
    );
  }

  Future<void> _seleccionarFechaDesdeCalendario() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.isBefore(now) ? now : selectedDate,
      firstDate: now,
      lastDate: DateTime(2026),
      locale: const Locale('es', ''),
    );

    if (picked != null && !DateUtils.isSameDay(selectedDate, picked)) {
      setState(() {
        selectedDate = picked;
        monthShown = DateTime(picked.year, picked.month);
      });

      if (usuarioId != null) {
        _loadTurnos(usuarioId!);
      }

      final dias = getDiasDelMes(DateTime(picked.year, picked.month));
      if (containerWidth != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToSelectedDay(
            containerWidth: containerWidth!,
            diasMes: dias,
          );
        });
      }
    }
  }

  void _scrollToSelectedDay({
    required double containerWidth,
    required List<DateTime> diasMes,
  }) {
    final index = diasMes.indexWhere(
      (d) => DateUtils.isSameDay(d, selectedDate),
    );

    if (index == -1) return;

    const itemWidth = 84.0;
    double position = index * itemWidth;

    if (_primerScrollRealizado) {
      // Después de la primera vez, sumamos 300 px
      position = (position + 20)
          .clamp(0.0, _scrollController.position.maxScrollExtent);
    } else {
      // Primera vez, no sumamos nada
      _primerScrollRealizado = true;
    }

    _scrollController.animateTo(
      position,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final diasMes = getDiasDelMes(monthShown);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Text(
          'Agenda de ${widget.medicoNombre}',
          style: const TextStyle(fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed:
                usuarioId == null ? null : _seleccionarFechaDesdeCalendario,
          ),
        ],
      ),
      body: usuarioId == null
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  containerWidth = constraints.maxWidth;

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _scrollToSelectedDay(
                      containerWidth: containerWidth!,
                      diasMes: diasMes,
                    );
                  });

                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: constraints.maxHeight),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 70,
                              child: SingleChildScrollView(
                                controller: _scrollController,
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                child: Row(
                                  children: diasMes.map((dia) {
                                    final isSelected =
                                        DateUtils.isSameDay(dia, selectedDate);
                                    String nombreDia =
                                        DateFormat.EEEE('es').format(dia);
                                    nombreDia = nombreDia[0].toUpperCase() +
                                        nombreDia.substring(1);
                                    String diaNumeroMes =
                                        DateFormat('d MMM', 'es').format(dia);

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6),
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            selectedDate = dia;
                                          });
                                          _loadTurnos(usuarioId!);
                                          _scrollToSelectedDay(
                                            containerWidth:
                                                constraints.maxWidth,
                                            diasMes: diasMes,
                                          );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 15, vertical: 5),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? const Color(0xFF1B4A5A)
                                                : Colors.transparent,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                              color: isSelected
                                                  ? Colors.transparent
                                                  : Colors.grey.shade400,
                                              width: 1.5,
                                            ),
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                nombreDia,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: isSelected
                                                      ? Colors.white
                                                      : Colors.grey.shade600,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                diaNumeroMes,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: isSelected
                                                      ? Colors.white
                                                      : Colors.grey.shade600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            FutureBuilder<List<TurnoMedicoModel>>(
                              future: turnosFuture,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }
                                if (snapshot.hasError) {
                                  return Center(
                                      child: Text(
                                          'Error al cargar los turnos: ${snapshot.error}'));
                                }

                                final turnos = snapshot.data!;
                                if (turnos.isEmpty) {
                                  return const Center(
                                      child: Text('No hay turnos disponibles'));
                                }

                                return ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: turnos.length,
                                  itemBuilder: (context, index) {
                                    final turno = turnos[index];
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.grey.shade400),
                                        borderRadius: BorderRadius.circular(10),
                                        color: Colors.white,
                                      ),
                                      child: ListTile(
                                        title: Text(
                                          DateFormat('HH:mm')
                                              .format(turno.fecha),
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16),
                                        ),
                                        subtitle: Text(
                                          turno.turnoEstadoId == 1
                                              ? 'Disponible'
                                              : 'Reservado',
                                        ),
                                        trailing: Icon(
                                          turno.turnoEstadoId == 1
                                              ? Icons.check_circle
                                              : Icons.cancel,
                                          color: turno.turnoEstadoId == 1
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                        onTap: turno.turnoEstadoId == 1
                                            ? () async {
                                                final result =
                                                    await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        ReservarTurnoScreen(
                                                      turno: turno,
                                                      usuarioId: usuarioId!,
                                                    ),
                                                  ),
                                                );

                                                // Si se reservó con éxito, recargar turnos
                                                if (result == true) {
                                                  _loadTurnos(usuarioId!);
                                                }
                                              }
                                            : null,
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
