import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Diálogo simple para que un admin pegue la URL de una imagen (mismo
/// patrón que "Foto Url" en Perfil de usuario / Aeropuerto: sin subida de
/// archivo, solo un link). Devuelve:
/// - el texto nuevo (puede ser vacío) si el admin le da "Guardar" o "Quitar
///   imagen",
/// - null si cancela.
Future<String?> mostrarEditorImagen(
  BuildContext context, {
  required String titulo,
  String? actual,
}) async {
  final ctrl = TextEditingController(text: actual ?? '');
  final tieneActual = (actual ?? '').trim().isNotEmpty;
  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text(titulo),
      content: TextField(
        controller: ctrl,
        autofocus: true,
        decoration: const InputDecoration(
          labelText: 'URL de la imagen',
          hintText: 'https://...',
        ),
      ),
      actions: [
        if (tieneActual)
          TextButton(
            onPressed: () => Navigator.pop(context, ''),
            child: const Text('Quitar imagen'),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, ctrl.text.trim()),
          child: const Text('Guardar'),
        ),
      ],
    ),
  );
}

/// Resultado del editor de contenido: null si canceló, o los 3 valores
/// (ya trimeados) listos para mandar al backend.
class ContenidoEditado {
  final String titulo;
  final String texto;
  final String imagenUrl;
  const ContenidoEditado({required this.titulo, required this.texto, required this.imagenUrl});
}

/// Diálogo para editar el contenido público (tarjetas del carrusel de
/// bienvenida, encabezado del login): título, texto e imagen, cada uno
/// mostrable/ocultable según lo que use esa pantalla. Los campos que no se
/// muestran se devuelven vacíos (el llamador solo debe mandar al backend
/// los campos que sí mostró).
Future<ContenidoEditado?> mostrarEditorContenido(
  BuildContext context, {
  required String dialogoTitulo,
  bool mostrarTitulo = true,
  bool mostrarTexto = true,
  bool mostrarImagen = true,
  String? actualTitulo,
  String? actualTexto,
  String? actualImagenUrl,
}) async {
  final tituloCtrl = TextEditingController(text: actualTitulo ?? '');
  final textoCtrl = TextEditingController(text: actualTexto ?? '');
  final imagenCtrl = TextEditingController(text: actualImagenUrl ?? '');
  return showDialog<ContenidoEditado>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text(dialogoTitulo),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (mostrarTitulo) ...[
              TextField(
                controller: tituloCtrl,
                autofocus: true,
                maxLength: 60,
                decoration: const InputDecoration(labelText: 'Título'),
              ),
              const SizedBox(height: 4),
            ],
            if (mostrarTexto) ...[
              TextField(
                controller: textoCtrl,
                maxLines: 3,
                maxLength: 200,
                decoration: const InputDecoration(labelText: 'Texto'),
              ),
              const SizedBox(height: 4),
            ],
            if (mostrarImagen)
              TextField(
                controller: imagenCtrl,
                decoration: const InputDecoration(
                  labelText: 'URL de la imagen',
                  hintText: 'https://...',
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(
            context,
            ContenidoEditado(
              titulo: tituloCtrl.text.trim(),
              texto: textoCtrl.text.trim(),
              imagenUrl: imagenCtrl.text.trim(),
            ),
          ),
          child: const Text('Guardar'),
        ),
      ],
    ),
  );
}
