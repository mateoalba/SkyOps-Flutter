import 'package:flutter/material.dart';

/// Overlay de carga que se superpone sobre una pantalla mientras
/// una operación (guardar, eliminar, etc.) está en curso.
class LoadingOverlay extends StatelessWidget {
  final bool visible;
  final Widget child;

  const LoadingOverlay({super.key, required this.visible, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (visible)
          Container(
            color: Colors.black.withValues(alpha: 0.25),
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}
