import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../db/database_helper.dart';
import 'login_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _correoController = TextEditingController();
  final _respuestaController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmarController = TextEditingController();

  int _paso = 1;
  Map<String, dynamic>? _usuario;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text('Recuperar contraseña'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildPaso(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaso() {
    switch (_paso) {
      case 1:
        return _buildPasoCorreo();
      case 2:
        return _buildPasoRespuesta();
      default:
        return _buildPasoNuevaContrasena();
    }
  }

  Widget _buildPasoCorreo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ingresa tu correo para buscar tu cuenta',
          style: TextStyle(color: AppColors.textLight, fontSize: 15),
        ),
        const SizedBox(height: 32),
        _buildTextField(
          controller: _correoController,
          label: 'Correo electrónico',
          icon: Icons.email_outlined,
        ),
        const SizedBox(height: 28),
        _buildBotonPrincipal('Continuar', _buscarUsuario),
      ],
    );
  }

  Widget _buildPasoRespuesta() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Responde tu pregunta de seguridad',
          style: TextStyle(color: AppColors.textLight, fontSize: 15),
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _usuario?['pregunta_seguridad'] as String? ?? '',
            style: const TextStyle(color: AppColors.textDark, fontSize: 15),
          ),
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _respuestaController,
          label: 'Tu respuesta',
          icon: Icons.shield_outlined,
        ),
        const SizedBox(height: 28),
        _buildBotonPrincipal('Validar respuesta', _validarRespuesta),
      ],
    );
  }

  Widget _buildPasoNuevaContrasena() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Crea tu nueva contraseña',
          style: TextStyle(color: AppColors.textLight, fontSize: 15),
        ),
        const SizedBox(height: 32),
        _buildTextField(
          controller: _passwordController,
          label: 'Nueva contraseña',
          icon: Icons.lock_outline,
          obscure: _obscurePassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: AppColors.textLight,
            ),
            onPressed: () {
              setState(() => _obscurePassword = !_obscurePassword);
            },
          ),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _confirmarController,
          label: 'Confirmar contraseña',
          icon: Icons.lock_outline,
          obscure: _obscureConfirm,
          suffixIcon: IconButton(
            icon: Icon(
              _obscureConfirm ? Icons.visibility_off : Icons.visibility,
              color: AppColors.textLight,
            ),
            onPressed: () {
              setState(() => _obscureConfirm = !_obscureConfirm);
            },
          ),
        ),
        const SizedBox(height: 28),
        _buildBotonPrincipal('Actualizar contraseña', _actualizarContrasena),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.textLight),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColors.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildBotonPrincipal(String texto, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          texto,
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }

  Future<void> _buscarUsuario() async {
    final correo = _correoController.text.trim();

    if (correo.isEmpty) {
      _mostrarMensaje('Ingresa tu correo electrónico');
      return;
    }

    final usuario = await DatabaseHelper().obtenerUsuarioPorCorreo(correo);

    if (!mounted) return;

    if (usuario == null) {
      _mostrarMensaje('No se encontró una cuenta con ese correo');
      return;
    }

    final pregunta = usuario['pregunta_seguridad'] as String?;
    if (pregunta == null || pregunta.isEmpty) {
      _mostrarMensaje('Esta cuenta no tiene una pregunta de seguridad configurada');
      return;
    }

    setState(() {
      _usuario = usuario;
      _paso = 2;
    });
  }

  void _validarRespuesta() {
    final respuesta = _respuestaController.text.trim();

    if (respuesta.isEmpty) {
      _mostrarMensaje('Ingresa tu respuesta');
      return;
    }

    final respuestaGuardada = _usuario?['respuesta_seguridad'] as String? ?? '';

    if (respuesta.toLowerCase() != respuestaGuardada.trim().toLowerCase()) {
      _mostrarMensaje('La respuesta no es correcta');
      return;
    }

    setState(() => _paso = 3);
  }

  Future<void> _actualizarContrasena() async {
    final contrasena = _passwordController.text;
    final confirmar = _confirmarController.text;

    if (contrasena.isEmpty || confirmar.isEmpty) {
      _mostrarMensaje('Completa todos los campos');
      return;
    }

    if (contrasena != confirmar) {
      _mostrarMensaje('Las contraseñas no coinciden');
      return;
    }

    final usuarioId = _usuario?['id'] as int?;
    if (usuarioId == null) return;

    await DatabaseHelper().actualizarContrasena(usuarioId, contrasena);

    if (!mounted) return;

    _mostrarMensaje('Contraseña actualizada correctamente');

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }
}
