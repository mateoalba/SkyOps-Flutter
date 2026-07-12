import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Botón "Continuar con Google" reutilizado en login y registro.
/// Usa el logo de Google dibujado con CustomPaint para no depender de
/// assets/imágenes externas.
class GoogleSignInButton extends StatelessWidget {
  final String etiqueta;
  final bool habilitado;
  final VoidCallback onPressed;

  const GoogleSignInButton({
    super.key,
    required this.etiqueta,
    required this.onPressed,
    this.habilitado = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: habilitado ? onPressed : null,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.surfaceVariant),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const _LogoGoogle(size: 18),
            const SizedBox(width: 10),
            Text(etiqueta, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _LogoGoogle extends StatelessWidget {
  final double size;
  const _LogoGoogle({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _GoogleGPainter()),
    );
  }
}

/// Dibuja la "G" de Google con los 4 colores de marca, sin necesitar un
/// asset .png/.svg (evita depender de un paquete de íconos de marcas).
class _GoogleGPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final center = Offset(r, r);
    final rect = Rect.fromCircle(center: center, radius: r);
    const start = -0.35;

    final azul = Paint()..color = const Color(0xFF4285F4);
    final verde = Paint()..color = const Color(0xFF34A853);
    final amarillo = Paint()..color = const Color(0xFFFBBC05);
    final rojo = Paint()..color = const Color(0xFFEA4335);

    canvas.drawArc(rect, start, 1.9, true, azul);
    canvas.drawArc(rect, start + 1.9, 1.6, true, verde);
    canvas.drawArc(rect, start + 3.5, 1.1, true, amarillo);
    canvas.drawArc(rect, start + 4.6, 1.67, true, rojo);

    canvas.drawCircle(center, r * 0.62, Paint()..color = Colors.white);
    canvas.drawRect(
      Rect.fromLTWH(center.dx, center.dy - r * 0.18, r * 0.95, r * 0.36),
      azul,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
