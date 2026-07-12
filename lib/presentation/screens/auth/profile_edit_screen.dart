import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/loading_overlay.dart';
import '../../../theme/app_colors.dart';

/// Pantalla aparte para editar los datos personales del usuario (antes
/// vivía inline en la pantalla de Perfil). Se accede desde "Editar perfil".
class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _emailCtrl = TextEditingController();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _paisCtrl = TextEditingController();
  final _numeroDocumentoCtrl = TextEditingController();
  String? _tipoDocumento;
  String? _genero;
  DateTime? _fechaNacimiento;
  bool _inicializado = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _telefonoCtrl.dispose();
    _paisCtrl.dispose();
    _numeroDocumentoCtrl.dispose();
    super.dispose();
  }

  InputDecoration _decoracionCompacta(String etiqueta) {
    return InputDecoration(
      labelText: etiqueta,
      isDense: true,
      labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.surfaceVariant)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.surfaceVariant)),
    );
  }

  Future<void> _guardar() async {
    final cambios = <String, dynamic>{
      'email': _emailCtrl.text.trim(),
      'first_name': _firstNameCtrl.text.trim(),
      'last_name': _lastNameCtrl.text.trim(),
      'telefono': _telefonoCtrl.text.trim(),
      'pais': _paisCtrl.text.trim(),
      'numero_documento': _numeroDocumentoCtrl.text.trim(),
      if (_tipoDocumento != null) 'tipo_documento': _tipoDocumento,
      if (_genero != null) 'genero': _genero,
      if (_fechaNacimiento != null)
        'fecha_nacimiento':
            '${_fechaNacimiento!.year.toString().padLeft(4, '0')}-${_fechaNacimiento!.month.toString().padLeft(2, '0')}-${_fechaNacimiento!.day.toString().padLeft(2, '0')}',
    };
    final ok = await context.read<AuthProvider>().actualizarPerfil(cambios);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Perfil actualizado' : 'No se pudo actualizar')),
    );
    if (ok) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final usuario = auth.usuario;

    if (!_inicializado && usuario != null) {
      _emailCtrl.text = usuario.email;
      _firstNameCtrl.text = usuario.firstName ?? '';
      _lastNameCtrl.text = usuario.lastName ?? '';
      _telefonoCtrl.text = usuario.telefono ?? '';
      _paisCtrl.text = usuario.pais ?? '';
      _numeroDocumentoCtrl.text = usuario.numeroDocumento ?? '';
      _tipoDocumento = (usuario.tipoDocumento?.isNotEmpty ?? false) ? usuario.tipoDocumento : null;
      _genero = (usuario.genero?.isNotEmpty ?? false) ? usuario.genero : null;
      _fechaNacimiento = usuario.fechaNacimiento;
      _inicializado = true;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Editar perfil')),
      body: LoadingOverlay(
        visible: auth.cargando,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.surfaceVariant),
                ),
                child: Column(
                  children: [
                    TextField(controller: _emailCtrl, decoration: _decoracionCompacta('Correo electrónico')),
                    const SizedBox(height: 14),
                    Row(children: [
                      Expanded(child: TextField(controller: _firstNameCtrl, decoration: _decoracionCompacta('Nombre'))),
                      const SizedBox(width: 12),
                      Expanded(child: TextField(controller: _lastNameCtrl, decoration: _decoracionCompacta('Apellido'))),
                    ]),
                    const SizedBox(height: 14),
                    TextField(controller: _telefonoCtrl, decoration: _decoracionCompacta('Teléfono')),
                    const SizedBox(height: 14),
                    TextField(controller: _paisCtrl, decoration: _decoracionCompacta('País')),
                    const SizedBox(height: 14),
                    Row(children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _tipoDocumento,
                          isExpanded: true,
                          dropdownColor: AppColors.surface,
                          decoration: _decoracionCompacta('Tipo de documento'),
                          items: const [
                            DropdownMenuItem(value: 'cedula', child: Text('Cédula')),
                            DropdownMenuItem(value: 'pasaporte', child: Text('Pasaporte')),
                            DropdownMenuItem(value: 'ruc', child: Text('RUC')),
                            DropdownMenuItem(value: 'dni', child: Text('DNI')),
                          ],
                          onChanged: (v) => setState(() => _tipoDocumento = v),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(controller: _numeroDocumentoCtrl, decoration: _decoracionCompacta('N.º documento')),
                      ),
                    ]),
                    const SizedBox(height: 14),
                    Row(children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _genero,
                          isExpanded: true,
                          dropdownColor: AppColors.surface,
                          decoration: _decoracionCompacta('Género'),
                          items: const [
                            DropdownMenuItem(value: 'femenino', child: Text('Femenino')),
                            DropdownMenuItem(value: 'masculino', child: Text('Masculino')),
                            DropdownMenuItem(value: 'prefiero_no_decirlo', child: Text('Prefiero no decirlo')),
                          ],
                          onChanged: (v) => setState(() => _genero = v),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final fecha = await showDatePicker(
                              context: context,
                              initialDate: _fechaNacimiento ?? DateTime(2000, 1, 1),
                              firstDate: DateTime(1920),
                              lastDate: DateTime.now(),
                            );
                            if (fecha != null) setState(() => _fechaNacimiento = fecha);
                          },
                          child: InputDecorator(
                            decoration: _decoracionCompacta('Nacimiento'),
                            child: Text(
                              _fechaNacimiento == null
                                  ? 'Elegir'
                                  : '${_fechaNacimiento!.day.toString().padLeft(2, '0')}/${_fechaNacimiento!.month.toString().padLeft(2, '0')}/${_fechaNacimiento!.year}',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _guardar,
                child: const Text('Guardar cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
