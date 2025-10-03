import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tesis/data/model/get_medicos_model.dart';
import 'package:tesis/data/services/medico_service.dart';
import 'package:tesis/presentation/screens/turnos/agenda_turnos_screen.dart';

class TurnosScreen extends StatefulWidget {
  static const String name = 'turnos_screen';

  const TurnosScreen({super.key});

  @override
  State<TurnosScreen> createState() => _TurnosScreenState();
}

class _TurnosScreenState extends State<TurnosScreen> {
  final MedicosService medicosService = MedicosService();

  late Future<List<MedicosModel>> medicosFuture;
  String filtro = '';
  String filtroEspecialidad = '';

  final FocusNode _focusNode = FocusNode();
  bool isFocused = false;

  @override
  void initState() {
    super.initState();
    medicosFuture = medicosService.getMedicos();

    _focusNode.addListener(() {
      setState(() {
        isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Widget buildUserImage(String? imageUrl, double borderRadius) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: imageUrl != null && imageUrl.isNotEmpty
          ? Image.network(
              imageUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  'assets/images/default_img.webp',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                );
              },
            )
          : Image.asset(
              'assets/images/default_img.webp',
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
    );
  }

  Widget _buildChip(String label, bool selected, VoidCallback onTap) {
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.white : Colors.grey,
          fontSize: 14,
        ),
      ),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: const Color(0xFF1B4A5A),
      backgroundColor: Colors.white,
      side: BorderSide(
        color: selected ? const Color(0xFF1B4A5A) : Colors.grey.shade400,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      showCheckmark: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    const double borderRadiusValue = 10;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            TextField(
              focusNode: _focusNode,
              decoration: InputDecoration(
                labelText: 'Buscar médico...',
                labelStyle: TextStyle(
                  color: isFocused ? const Color(0xFF1B4A5A) : Colors.grey,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: isFocused ? const Color(0xFF1B4A5A) : Colors.grey,
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide:
                      const BorderSide(color: Color(0xFF1B4A5A), width: 2),
                  borderRadius: BorderRadius.circular(borderRadiusValue),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(borderRadiusValue),
                ),
              ),
              cursorColor: const Color(0xFF1B4A5A),
              onChanged: (value) {
                setState(() {
                  filtro = value.toLowerCase();
                });
              },
            ),
            const SizedBox(height: 14),
            FutureBuilder<List<MedicosModel>>(
              future: medicosFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasError) {
                  return Expanded(
                    child: Center(child: Text('Error: ${snapshot.error}')),
                  );
                }

                if (!snapshot.hasData || snapshot.data == null) {
                  return const Expanded(
                    child: Center(child: Text('No hay datos disponibles')),
                  );
                }

                final medicos = snapshot.data!;
                final especialidades =
                    medicos.map((e) => e.especialidad.nombre).toSet().toList();

                final filtrados = medicos.where((medico) {
                  final nombreMatch =
                      medico.usuario.nombre.toLowerCase().contains(filtro);
                  final especialidadMatch =
                      medico.especialidad.nombre.toLowerCase().contains(filtro);

                  final filtroTexto = nombreMatch || especialidadMatch;
                  final filtroTag = filtroEspecialidad.isEmpty ||
                      medico.especialidad.nombre.toLowerCase() ==
                          filtroEspecialidad.toLowerCase();

                  return filtroTexto && filtroTag;
                }).toList();

                // Ordenar por nombre
                filtrados.sort((a, b) => a.usuario.nombre
                    .toLowerCase()
                    .compareTo(b.usuario.nombre.toLowerCase()));

                return Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            const SizedBox(width: 4),
                            _buildChip("Todos", filtroEspecialidad == '', () {
                              setState(() {
                                filtroEspecialidad = '';
                              });
                            }),
                            const SizedBox(width: 6),
                            ...especialidades.map((esp) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 6.0),
                                child: _buildChip(
                                  esp,
                                  filtroEspecialidad.toLowerCase() ==
                                      esp.toLowerCase(),
                                  () {
                                    setState(() {
                                      filtroEspecialidad =
                                          filtroEspecialidad.toLowerCase() ==
                                                  esp.toLowerCase()
                                              ? ''
                                              : esp;
                                    });
                                  },
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: filtrados.isEmpty
                            ? const Center(
                                child: Text('No se encontraron médicos'))
                            : ListView.builder(
                                itemCount: filtrados.length,
                                itemBuilder: (context, index) {
                                  final medico = filtrados[index];
                                  return Container(
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    padding: const EdgeInsets.all(8.0),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(
                                          borderRadiusValue),
                                      border: Border.all(
                                          color: Colors.grey.shade400),
                                    ),
                                    child: Row(
                                      children: [
                                        buildUserImage(medico.usuario.img,
                                            borderRadiusValue),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                medico.usuario.nombre,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                medico.especialidad.nombre,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  color: Colors.black54,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          icon: const FaIcon(
                                            FontAwesomeIcons.calendar,
                                            color: Color(0xFF1B4A5A),
                                          ),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    AgendaTurnosScreen(
                                                  medicoId: medico.id,
                                                  medicoNombre:
                                                      medico.usuario.nombre,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
