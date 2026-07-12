import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/validators.dart';
import '../../../domain/model/perfil_usuario.dart';
import '../../providers/perfil_usuario_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/aeropuerto_provider.dart';
import '../../widgets/loading_overlay.dart';
import '../../../theme/app_colors.dart';

class PerfilUsuarioFormScreen extends StatefulWidget {
  final String? id;
  const PerfilUsuarioFormScreen({super.key, this.id});

  @override
  State<PerfilUsuarioFormScreen> createState() => _PerfilUsuarioFormScreenState();
}

class _PerfilUsuarioFormScreenState extends State<PerfilUsuarioFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _cargado = false;
  bool _guardando = false;

  final _usuarioCtrl = TextEditingController();
  String? _aeropuertoAsignado;
  final _paisCtrl = TextEditingController();
  String? _tipoDocumento = null;
  final _numeroDocumentoCtrl = TextEditingController();
  DateTime? _fechaNacimiento;
  String? _genero = null;
  final _telefonoCtrl = TextEditingController();
  String? _cargo = 'administrador';
  final _fotoUrlCtrl = TextEditingController();
  bool _activo = true;
  DateTime? _creadoEn;
  DateTime? _actualizadoEn;

  bool get _esEdicion => widget.id != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _inicializar());
  }

  Future<void> _inicializar() async {
    await context.read<AeropuertoProvider>().cargar();
    if (_esEdicion) {
      final provider = context.read<PerfilUsuarioProvider>();
      PerfilUsuario? e;
      try {
        e = provider.items.firstWhere((it) => it.id == widget.id);
      } catch (_) {
        e = null;
      }
      if (e != null) {
        setState(() {
          _usuarioCtrl.text = e!.usuario?.toString() ?? '';
          _aeropuertoAsignado = (e!.aeropuertoAsignado?.isNotEmpty ?? false) ? e!.aeropuertoAsignado : null;
          _paisCtrl.text = e!.pais?.toString() ?? '';
          // Si el backend no manda tipo_documento/genero/cargo (o vienen
          // vacíos), se deja el dropdown en null en vez de '' — un valor
          // '' no coincide con ninguna opción y hace crashear el Dropdown.
          _tipoDocumento = (e!.tipoDocumento?.isNotEmpty ?? false) ? e!.tipoDocumento : null;
          _numeroDocumentoCtrl.text = e!.numeroDocumento?.toString() ?? '';
          _fechaNacimiento = e!.fechaNacimiento;
          _genero = (e!.genero?.isNotEmpty ?? false) ? e!.genero : null;
          _telefonoCtrl.text = e!.telefono?.toString() ?? '';
          _cargo = (e!.cargo.isNotEmpty) ? e!.cargo : null;
          _fotoUrlCtrl.text = e!.fotoUrl?.toString() ?? '';
          _activo = e!.activo;
          _creadoEn = e!.creadoEn;
          _actualizadoEn = e!.actualizadoEn;
        });
      }
    }
    if (mounted) setState(() => _cargado = true);
  }

  Future<void> _seleccionarFecha(void Function(DateTime) onSeleccionado, DateTime? actual) async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: actual ?? DateTime.now(),
      // 1900 en vez de 2000: este selector también se usa para fecha de
      // nacimiento, que puede ser anterior al año 2000.
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (fecha == null || !mounted) return;
    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(actual ?? DateTime.now()),
    );
    if (hora == null) return;
    onSeleccionado(DateTime(fecha.year, fecha.month, fecha.day, hora.hour, hora.minute));
  }

  @override
  void dispose() {
    _usuarioCtrl.dispose();
    _paisCtrl.dispose();
    _numeroDocumentoCtrl.dispose();
    _telefonoCtrl.dispose();
    _fotoUrlCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _opcAeropuertoProvider = context.watch<AeropuertoProvider>().items;
    final esAdmin = context.watch<AuthProvider>().usuario?.esAdmin ?? false;
    final puedeEscribir = esAdmin;
    return Scaffold(
      appBar: AppBar(title: Text(_esEdicion ? 'Editar Perfil de Usuario' : 'Nuevo Perfil de Usuario')),
      body: LoadingOverlay(
        visible: !_cargado || _guardando,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.surfaceVariant),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                if (!puedeEscribir)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.lock_outline, color: Colors.amber, size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Solo un administrador puede crear o editar registros en este módulo.',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _usuarioCtrl,
                  enabled: puedeEscribir,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Usuario (ID)'),
                  validator: Validators.numero,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _aeropuertoAsignado,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Aeropuerto'),
                  items: _opcAeropuertoProvider.map((item) {
                    return DropdownMenuItem<String>(
                      value: item.id,
                      child: Text('${item.codigoIata} - ${item.nombre}', overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: !puedeEscribir ? null : (v) => setState(() => _aeropuertoAsignado = v),
                  validator: null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _paisCtrl,
                  enabled: puedeEscribir,
                  
                  decoration: const InputDecoration(labelText: 'Pais'),
                  validator: null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _tipoDocumento,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Tipo Documento'),
                  items: [
                    DropdownMenuItem(value: 'cedula', child: Text('Cédula')),
                    DropdownMenuItem(value: 'pasaporte', child: Text('Pasaporte')),
                    DropdownMenuItem(value: 'ruc', child: Text('RUC')),
                    DropdownMenuItem(value: 'dni', child: Text('DNI')),
                  ],
                  onChanged: !puedeEscribir ? null : (v) => setState(() => _tipoDocumento = v),
                  validator: null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _numeroDocumentoCtrl,
                  enabled: puedeEscribir,
                  
                  decoration: const InputDecoration(labelText: 'Numero Documento'),
                  validator: null,
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: !puedeEscribir ? null : () => _seleccionarFecha((d) => setState(() => _fechaNacimiento = d), _fechaNacimiento),
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Fecha Nacimiento'),
                    child: Text(_fechaNacimiento == null ? 'Seleccionar...' : _fechaNacimiento.toString()),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _genero,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Genero'),
                  items: [
                    DropdownMenuItem(value: 'femenino', child: Text('Femenino')),
                    DropdownMenuItem(value: 'masculino', child: Text('Masculino')),
                    DropdownMenuItem(value: 'prefiero_no_decirlo', child: Text('Prefiero no decirlo')),
                  ],
                  onChanged: !puedeEscribir ? null : (v) => setState(() => _genero = v),
                  validator: null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _telefonoCtrl,
                  enabled: puedeEscribir,
                  
                  decoration: const InputDecoration(labelText: 'Telefono'),
                  validator: null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _cargo,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Cargo'),
                  items: [
                    DropdownMenuItem(value: 'administrador', child: Text('Administrador')),
                    DropdownMenuItem(value: 'operador', child: Text('Operador')),
                    DropdownMenuItem(value: 'supervisor', child: Text('Supervisor')),
                    DropdownMenuItem(value: 'analista', child: Text('Analista')),
                    DropdownMenuItem(value: 'tecnico', child: Text('Técnico')),
                    DropdownMenuItem(value: 'usuario', child: Text('Usuario')),
                  ],
                  onChanged: !puedeEscribir ? null : (v) => setState(() => _cargo = v),
                  validator: (v) => v == null ? 'Selecciona cargo' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _fotoUrlCtrl,
                  enabled: puedeEscribir,
                  
                  decoration: const InputDecoration(labelText: 'Foto Url'),
                  validator: null,
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  value: _activo,
                  onChanged: !puedeEscribir ? null : (v) => setState(() => _activo = v),
                  title: const Text('Activo'),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: !puedeEscribir ? null : () => _seleccionarFecha((d) => setState(() => _creadoEn = d), _creadoEn),
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Creado En'),
                    child: Text(_creadoEn == null ? 'Seleccionar...' : _creadoEn.toString()),
                  ),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: !puedeEscribir ? null : () => _seleccionarFecha((d) => setState(() => _actualizadoEn = d), _actualizadoEn),
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Actualizado En'),
                    child: Text(_actualizadoEn == null ? 'Seleccionar...' : _actualizadoEn.toString()),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: (!puedeEscribir || _guardando) ? null : _guardar,
                  child: Text(_esEdicion ? 'Guardar cambios' : 'Crear registro'),
                ),
              ],
            ),
          ),
          ),
        ),
      ),
    );
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);
    final item = PerfilUsuario(
      id: widget.id,
      usuario: int.tryParse(_usuarioCtrl.text.trim())!,
      aeropuertoAsignado: _aeropuertoAsignado,
      pais: _paisCtrl.text.trim().isEmpty ? null : _paisCtrl.text.trim(),
      tipoDocumento: _tipoDocumento,
      numeroDocumento: _numeroDocumentoCtrl.text.trim().isEmpty ? null : _numeroDocumentoCtrl.text.trim(),
      fechaNacimiento: _fechaNacimiento,
      genero: _genero,
      telefono: _telefonoCtrl.text.trim().isEmpty ? null : _telefonoCtrl.text.trim(),
      cargo: _cargo!,
      fotoUrl: _fotoUrlCtrl.text.trim().isEmpty ? null : _fotoUrlCtrl.text.trim(),
      activo: _activo,
      creadoEn: _creadoEn,
      actualizadoEn: _actualizadoEn,
    );

    final provider = context.read<PerfilUsuarioProvider>();
    final ok = _esEdicion
        ? await provider.actualizar(widget.id!, item)
        : await provider.crear(item);

    if (!mounted) return;
    setState(() => _guardando = false);
    if (ok) {
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error ?? 'No se pudo guardar')),
      );
    }
  }
}
