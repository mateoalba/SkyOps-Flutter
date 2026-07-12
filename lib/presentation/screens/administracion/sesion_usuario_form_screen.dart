import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/validators.dart';
import '../../../domain/model/sesion_usuario.dart';
import '../../providers/sesion_usuario_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/perfil_usuario_provider.dart';
import '../../widgets/loading_overlay.dart';
import '../../../theme/app_colors.dart';

class SesionUsuarioFormScreen extends StatefulWidget {
  final String? id;
  const SesionUsuarioFormScreen({super.key, this.id});

  @override
  State<SesionUsuarioFormScreen> createState() => _SesionUsuarioFormScreenState();
}

class _SesionUsuarioFormScreenState extends State<SesionUsuarioFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _cargado = false;
  bool _guardando = false;

  int? _usuarioId;
  final _ipAddressCtrl = TextEditingController();
  final _userAgentCtrl = TextEditingController();
  String? _resultado = 'exitoso';
  final _tokenJtiCtrl = TextEditingController();
  DateTime? _fechaHora;
  DateTime? _fechaCierre;

  bool get _esEdicion => widget.id != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _inicializar());
  }

  Future<void> _inicializar() async {
    await context.read<PerfilUsuarioProvider>().cargar();

    if (_esEdicion) {
      final provider = context.read<SesionUsuarioProvider>();
      SesionUsuario? e;
      try {
        e = provider.items.firstWhere((it) => it.id == widget.id);
      } catch (_) {
        e = null;
      }
      if (e != null) {
        setState(() {
          _usuarioId = e!.usuario;
          _ipAddressCtrl.text = e!.ipAddress?.toString() ?? '';
          _userAgentCtrl.text = e!.userAgent?.toString() ?? '';
          _resultado = e!.resultado;
          _tokenJtiCtrl.text = e!.tokenJti?.toString() ?? '';
          _fechaHora = e!.fechaHora;
          _fechaCierre = e!.fechaCierre;
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
    _ipAddressCtrl.dispose();
    _userAgentCtrl.dispose();
    _tokenJtiCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final esAdmin = context.watch<AuthProvider>().usuario?.esAdmin ?? false;
    final puedeEscribir = esAdmin;
    final perfiles = context.watch<PerfilUsuarioProvider>().items;
    // Un usuario puede tener más de un perfil histórico con el mismo id de
    // Usuario (auth.User); nos quedamos con uno por cada 'usuario' para no
    // duplicar valores en el dropdown.
    final opcionesUsuario = <int, String>{};
    for (final p in perfiles) {
      final nombre = (p.nombreCompleto?.trim().isNotEmpty ?? false)
          ? p.nombreCompleto!.trim()
          : (p.username ?? 'Usuario #${p.usuario}');
      opcionesUsuario[p.usuario] = nombre;
    }
    return Scaffold(
      appBar: AppBar(title: Text(_esEdicion ? 'Editar Sesión de Usuario' : 'Nueva Sesión de Usuario')),
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
                DropdownButtonFormField<int>(
                  value: opcionesUsuario.containsKey(_usuarioId) ? _usuarioId : null,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Usuario'),
                  items: opcionesUsuario.entries
                      .map((e) => DropdownMenuItem<int>(
                            value: e.key,
                            child: Text(e.value, overflow: TextOverflow.ellipsis),
                          ))
                      .toList(),
                  onChanged: !puedeEscribir ? null : (v) => setState(() => _usuarioId = v),
                  validator: (v) => v == null ? 'Selecciona un usuario' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ipAddressCtrl,
                  enabled: puedeEscribir,
                  
                  decoration: const InputDecoration(labelText: 'Ip Address'),
                  validator: Validators.requerido,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _userAgentCtrl,
                  enabled: puedeEscribir,
                  
                  decoration: const InputDecoration(labelText: 'User Agent'),
                  validator: null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _resultado,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Resultado'),
                  items: [
                    DropdownMenuItem(value: 'exitoso', child: Text('Exitoso')),
                    DropdownMenuItem(value: 'fallido', child: Text('Fallido')),
                    DropdownMenuItem(value: 'expirado', child: Text('Expirado')),
                    DropdownMenuItem(value: 'cerrado', child: Text('Cerrado')),
                  ],
                  onChanged: !puedeEscribir ? null : (v) => setState(() => _resultado = v),
                  validator: (v) => v == null ? 'Selecciona resultado' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _tokenJtiCtrl,
                  enabled: puedeEscribir,
                  
                  decoration: const InputDecoration(labelText: 'Token Jti'),
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
                const SizedBox(height: 16),
                InkWell(
                  onTap: !puedeEscribir ? null : () => _seleccionarFecha((d) => setState(() => _fechaCierre = d), _fechaCierre),
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Fecha Cierre'),
                    child: Text(_fechaCierre == null ? 'Seleccionar...' : _fechaCierre.toString()),
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
    final item = SesionUsuario(
      id: widget.id,
      usuario: _usuarioId,
      ipAddress: _ipAddressCtrl.text.trim(),
      userAgent: _userAgentCtrl.text.trim().isEmpty ? null : _userAgentCtrl.text.trim(),
      resultado: _resultado!,
      tokenJti: _tokenJtiCtrl.text.trim().isEmpty ? null : _tokenJtiCtrl.text.trim(),
      fechaHora: _fechaHora,
      fechaCierre: _fechaCierre,
    );

    final provider = context.read<SesionUsuarioProvider>();
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
