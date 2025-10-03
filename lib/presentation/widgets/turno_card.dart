import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:tesis/data/model/ger_turnos_usuario_model.dart';

Widget turnoCard(TurnoUsuarioModel turno, VoidCallback? onCancel,
    {bool showCancelar = true}) {
  final hora = DateFormat.Hm().format(turno.fecha);
  final fecha = DateFormat('dd/MM/yyyy').format(turno.fecha);

  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: Colors.grey.shade300),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Fecha y hora
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const FaIcon(FontAwesomeIcons.calendar,
                    size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Text(fecha,
                    style: const TextStyle(fontSize: 18, color: Colors.black)),
              ],
            ),
            Row(
              children: [
                const FaIcon(FontAwesomeIcons.clock,
                    size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Text(hora,
                    style: const TextStyle(fontSize: 18, color: Colors.black)),
              ],
            ),
          ],
        ),

        const SizedBox(height: 2),

        const Divider(thickness: 1, color: Colors.grey),

        const SizedBox(height: 4),

        // Info + botón cancelar si corresponde
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _iconText(FontAwesomeIcons.user, turno.nombre),
                  const SizedBox(height: 8),
                  _iconText(FontAwesomeIcons.userDoctor,
                      turno.nombreMedico ?? 'Sin nombre'),
                ],
              ),
            ),
            if (showCancelar && onCancel != null)
              Container(
                margin: const EdgeInsets.only(left: 12),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: Colors.red.withOpacity(0.1),
                ),
                child: IconButton(
                  onPressed: onCancel,
                  icon: const Icon(Icons.cancel, color: Colors.red),
                  iconSize: 24,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Cancelar turno',
                ),
              ),
          ],
        ),
      ],
    ),
  );
}

Widget _iconText(IconData icon, String text) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      FaIcon(icon, size: 16, color: Colors.grey),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          text,
          style: const TextStyle(fontSize: 16),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );
}
