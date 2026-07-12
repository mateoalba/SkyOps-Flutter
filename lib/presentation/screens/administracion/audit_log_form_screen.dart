import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/validators.dart';
import '../../../domain/model/audit_log.dart';
import '../../providers/audit_log_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/loading_overlay.dart';
import '../../../theme/app_colors.dart';

class AuditLogFormScreen extends StatefulWidget {
  final String? id;
  const AuditLogFormScreen({super.key, this.id});

  @override
  State<AuditLogFormScreen> createState() => _AuditLogFormScreenState();
}

class _AuditLogFormScreenState extends State<AuditLogFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _cargado = false;
  bool _guardando = false;

  final _usuarioCtrl = TextEditingController();
  String? _accion = 'crear';
  final _contentTypeCtrl = TextEditingController();
  final _objectIdCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();
  final _ipAddressCtrl = TextEditingController();
  DateTime? _fechaHora;

  bool get _esEdicion => widget.id != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _inicializar());
  }

  Future<void> _inicializar() async {

    if (_esEdicion) {
      final provider = context.read<AuditLogProvider>();
      AuditLog? e;
      try {
        e = provider.items.firstWhere((it) => it.id == widget.id);
      } catch (_) {
        e = null;
      }
      if (e != null) {
        setState(() {
          _usuarioCtrl.text = e!.usuario?.toString() ?? '';
          _accion = e!.accion;
          _contentTypeCtrl.text = e!.contentType?.toString() ?? '';
          _objectIdCtrl.text = e!.objectId?.toString() ?? '';
          _descripcionCtrl.text = e!.descripcion?.toString() ?? '';
          _ipAddressCtrl.text = e!.ipAddress?.toString() ?? '';
          _fechaHora = e!.fechaHora;
        });
      }
    }
    if (mounted) setState(() => _cargado = true);
  }

  Future<void> _seleccionarFecha(void Function(DateTime) onSeleccionado, DateTime? actual) async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: actual ?? DateTime.now(),
      firstDate: DateTime(2000),
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
    _contentTypeCtrl.dispose();
    _objectIdCtrl.dispose();
    _descripcionCtrl.dispose();
    _ipAddressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final esAdmin = context.watch<AuthProvider>().usuario?.esAdmin ?? false;
    final puedeEscribir = esAdmin;
    return Scaffold(
      appBar: AppBar(title: Text(_esEdicion ? 'Editar Registro de Auditoría' : 'Nuevo Registro de Auditoría')),
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
                  validator: null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _accion,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Accion'),
                  items: [
                    DropdownMenuItem(value: 'crear', child: Text('Crear')),
                    DropdownMenuItem(value: 'editar', child: Text('Editar')),
                    DropdownMenuItem(value: 'eliminar', child: Text('Eliminar')),
                    DropdownMenuItem(value: 'ver', child: Text('Ver')),
                    DropdownMenuItem(value: 'login', child: Text('Login')),
                    DropdownMenuItem(value: 'logout', child: Text('Logout')),
                    DropdownMenuItem(value: 'cambio_estado', child: Text('Cambio de estado')),
                    DropdownMenuItem(value: 'exportar', child: Text('Exportar')),
                  ],
                  onChanged: !puedeEscribir ? null : (v) => setState(() => _accion = v),
                  validator: (v) => v == null ? 'Selecciona accion' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contentTypeCtrl,
                  enabled: puedeEscribir,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Content Type (ID)'),
                  validator: null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _objectIdCtrl,
                  enabled: puedeEscribir,
                  
                  decoration: const InputDecoration(labelText: 'Object Id'),
                  validator: null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descripcionCtrl,
                  enabled: puedeEscribir,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Descripcion'),
                  validator: null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ipAddressCtrl,
                  enabled: puedeEscribir,
                  
                  decoration: const InputDecoration(labelText: 'Ip Address'),
                  validator: null,
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: !puedeEscribir ? null : () => _seleccionarFecha((d) => setState(() => _fechaHora = d), _fechaHora),
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Fecha Hora'),
                    child: Text(_fechaHora == null ? 'Seleccionar...' : _fechaHora.toString()),
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
    final item = AuditLog(
      id: widget.id,
      usuario: int.tryParse(_usuarioCtrl.text.trim()),
      accion: _accion!,
      contentType: int.tryParse(_contentTypeCtrl.text.trim()),
      objectId: _objectIdCtrl.text.trim().isEmpty ? null : _objectIdCtrl.text.trim(),
      descripcion: _descripcionCtrl.text.trim().isEmpty ? null : _descripcionCtrl.text.trim(),
      ipAddress: _ipAddressCtrl.text.trim().isEmpty ? null : _ipAddressCtrl.text.trim(),
      fechaHora: _fechaHora,
    );

    final provider = context.read<AuditLogProvider>();
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
