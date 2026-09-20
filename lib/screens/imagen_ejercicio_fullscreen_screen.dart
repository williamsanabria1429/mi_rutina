import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ImagenEjercicioFullscreenScreen extends StatelessWidget {
  final String nombreEjercicio;
  final String rutaImagen;
  final Object heroTag;

  const ImagenEjercicioFullscreenScreen({
    super.key,
    required this.nombreEjercicio,
    required this.rutaImagen,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(nombreEjercicio),
      ),
      body: Center(
        child: Hero(
          tag: heroTag,
          child: InteractiveViewer(
            minScale: 1,
            maxScale: 4,
            child: Image.asset(
              rutaImagen,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
