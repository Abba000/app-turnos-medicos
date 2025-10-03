import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tesis/data/model/get_usuario_model.dart';
import 'package:tesis/data/services/usuario_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PerfilScreen extends StatefulWidget {
  static const String name = 'perfil_screen';

  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final usuarioService = UsuarioService();

  Future<UsuarioModel>? usuarioFuture;
  final _nombreController = TextEditingController();
  final _mailController = TextEditingController();

  bool _isEditing = false;
  bool _isLoading = false;
  bool _comparteInformacion = false;
  bool _datosCargados = false; // 👈 nuevo

  File? _imagenSeleccionada;
  String? _imagenOriginal;

  final _focusNodeNombre = FocusNode();
  final _focusNodeMail = FocusNode();

  @override
  void initState() {
    super.initState();
    _cargarUsuario();
  }

  @override
  void dispose() {
    _focusNodeNombre.dispose();
    _focusNodeMail.dispose();
    _nombreController.dispose();
    _mailController.dispose();
    super.dispose();
  }

  Future<void> _cargarUsuario() async {
    try {
      final user = await FirebaseAuth.instance.authStateChanges().first;
      final email = user?.email;
      if (email != null) {
        setState(() {
          usuarioFuture = usuarioService.getUsuarioPorEmail(email);
        });
      } else {
        setState(() {
          usuarioFuture = Future.error('No hay usuario autenticado');
        });
      }
    } catch (e) {
      setState(() {
        usuarioFuture = Future.error('Error al cargar usuario: $e');
      });
    }
  }

  Future<void> _seleccionarImagen() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imagenSeleccionada = File(pickedFile.path);
      });
    }
  }

  Future<void> _actualizarUsuario() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await usuarioService.updateUsuario(
        mail: _mailController.text,
        nombre: _nombreController.text,
        img: _imagenSeleccionada != null
            ? _imagenSeleccionada!.path
            : _imagenOriginal,
        comparteInformacion: _comparteInformacion,
      );

      final email = FirebaseAuth.instance.currentUser?.email;

      if (success && email != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil actualizado correctamente')),
        );
        setState(() {
          _isEditing = false;
          _imagenSeleccionada = null;
          _datosCargados = false; // 👈 volver a cargar datos
          usuarioFuture = usuarioService.getUsuarioPorEmail(email);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo actualizar el perfil')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  ImageProvider getImageProvider(String? imgPath, File? localFile) {
    if (localFile != null) return FileImage(localFile);
    if (imgPath == null) return const AssetImage('assets/default_img.webp');
    if (imgPath.startsWith('http')) return NetworkImage(imgPath);
    return FileImage(File(imgPath));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: usuarioFuture == null
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<UsuarioModel>(
              future: usuarioFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting ||
                    _isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData) {
                  return const Center(child: Text('Usuario no encontrado'));
                }

                final usuario = snapshot.data!;

                if (!_datosCargados) {
                  _nombreController.text = usuario.nombre;
                  _mailController.text = usuario.mail;
                  _imagenOriginal = usuario.img;
                  _comparteInformacion = usuario.comparteInformacion;
                  _datosCargados = true;
                }

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SvgPicture.asset(
                            'assets/fondo.svg',
                            width: MediaQuery.of(context).size.width,
                            fit: BoxFit.cover,
                          ),
                          Column(
                            children: [
                              const SizedBox(height: 20),
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    width: 144,
                                    height: 144,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Colors.white, width: 2),
                                    ),
                                    child: CircleAvatar(
                                      radius: 70,
                                      backgroundImage: getImageProvider(
                                          usuario.img, _imagenSeleccionada),
                                    ),
                                  ),
                                  if (_isEditing)
                                    Positioned(
                                      bottom: -15,
                                      left: 0,
                                      right: 0,
                                      child: Center(
                                        child: GestureDetector(
                                          onTap: _seleccionarImagen,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF1B4A5A),
                                              shape: BoxShape.circle,
                                              boxShadow: const [
                                                BoxShadow(
                                                  color: Colors.black26,
                                                  blurRadius: 4,
                                                  offset: Offset(0, 2),
                                                )
                                              ],
                                            ),
                                            child: const FaIcon(
                                              FontAwesomeIcons.camera,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: Theme.of(context).colorScheme.copyWith(
                                  primary: const Color(0xFF1B4A5A),
                                ),
                          ),
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _nombreController,
                                focusNode: _focusNodeNombre,
                                decoration: InputDecoration(
                                  labelText: 'Nombre',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                enabled: _isEditing,
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: _mailController,
                                focusNode: _focusNodeMail,
                                readOnly: true,
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              SwitchListTile(
                                title: const Text(
                                    'Comparte tu Información con Stack'),
                                value: _comparteInformacion,
                                onChanged: _isEditing
                                    ? (value) {
                                        setState(() {
                                          _comparteInformacion = value;
                                        });
                                      }
                                    : null,
                                activeColor: const Color(0xFF1B4A5A),
                              ),
                              const SizedBox(height: 30),
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: _isEditing
                                      ? _actualizarUsuario
                                      : () {
                                          setState(() {
                                            _isEditing = true;
                                          });
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1B4A5A),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                  child: Text(
                                    _isEditing ? 'Guardar cambios' : 'Editar',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
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
