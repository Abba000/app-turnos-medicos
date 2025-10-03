import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tesis/data/model/get_turnos_medico_model.dart';
import 'package:tesis/data/services/turno_service.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ReservarTurnoScreen extends StatefulWidget {
  final TurnoMedicoModel turno;
  final int usuarioId;

  const ReservarTurnoScreen({
    super.key,
    required this.turno,
    required this.usuarioId,
  });

  @override
  State<ReservarTurnoScreen> createState() => _ReservarTurnoScreenState();
}

class _ReservarTurnoScreenState extends State<ReservarTurnoScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _mailController = TextEditingController();
  final TextEditingController _dniController =
      TextEditingController(); // ✅ Nuevo controlador
  final TurnosService turnosService = TurnosService();

  bool _loading = false;

  final Color focusColor = const Color(0xFF1B4A5A);

  Future<void> _reservarTurno() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
    });

    try {
      final success = await turnosService.reservarTurno(
        turnoId: widget.turno.id,
        nombre: _nombreController.text,
        mail: _mailController.text,
        usuarioId: widget.usuarioId,
        // 🧠 El DNI no se envía, solo es visible en pantalla
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Turno reservado correctamente")),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey[600]),
      floatingLabelStyle: TextStyle(
        color: focusColor,
        fontWeight: FontWeight.w500,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: BorderSide(color: focusColor, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fecha = widget.turno.fecha;
    final hora = DateFormat('HH:mm').format(fecha);
    final fechaTexto = DateFormat('dd/MM/yyyy').format(fecha);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: const Text(
          'Reservar Turno',
          style: TextStyle(fontSize: 18),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Row(
                            children: [
                              const FaIcon(
                                FontAwesomeIcons.calendar,
                                size: 18,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                fechaTexto,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              const FaIcon(
                                FontAwesomeIcons.clock,
                                size: 18,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                hora,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    TextFormField(
                      controller: _nombreController,
                      decoration: _inputDecoration('Nombre'),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Ingrese su nombre'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _dniController, // ✅ DNI input
                      decoration: _inputDecoration('DNI'),
                      keyboardType: TextInputType.number,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Ingrese su DNI'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _mailController,
                      decoration: _inputDecoration('Email'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Ingrese su email'
                          : null,
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _reservarTurno,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: focusColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        child: const Text(
                          'Confirmar Reserva',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
