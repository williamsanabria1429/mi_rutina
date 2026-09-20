import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../db/database_helper.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmarController = TextEditingController();
  final _respuestaSeguridadController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _generoSeleccionado;
  String? _preguntaSeguridadSeleccionada;

  static const List<String> _preguntasSeguridad = [
    'Nombre de la mascota que mas amaste',
    'Nombre de tu mejor amigo de infancia',
    '¿En qué ciudad naciste?',
    '¿Cuál es el segundo nombre de tu madre?',
    '¿Cuál es tu comida favorita?',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text('Crear Cuenta'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Regístrate para empezar tu rutina',
                style: TextStyle(color: AppColors.textLight, fontSize: 15),
              ),
              const SizedBox(height: 32),
              _buildTextField(
                controller: _nombreController,
                label: 'Nombre completo',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),
              _buildGeneroSelector(),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _emailController,
                label: 'Correo electrónico',
                icon: Icons.email_outlined,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _passwordController,
                label: 'Contraseña',
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
              const SizedBox(height: 16),
              _buildPreguntaSeguridadSelector(),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _respuestaSeguridadController,
                label: 'Respuesta de seguridad',
                icon: Icons.shield_outlined,
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _crearCuenta,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Crear cuenta',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
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

  Widget _buildGeneroSelector() {
    return Row(
      children: [
        Expanded(
          child: _buildGeneroCard(
            label: 'Hombre',
            icon: Icons.male,
            value: 'Hombre',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildGeneroCard(
            label: 'Mujer',
            icon: Icons.female,
            value: 'Mujer',
          ),
        ),
      ],
    );
  }

  Widget _buildGeneroCard({
    required String label,
    required IconData icon,
    required String value,
  }) {
    final seleccionado = _generoSeleccionado == value;
    return GestureDetector(
      onTap: () => setState(() => _generoSeleccionado = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: seleccionado ? AppColors.accent.withValues(alpha: 0.15) : AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: seleccionado ? AppColors.accent : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: seleccionado ? AppColors.accent : AppColors.textLight,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: seleccionado ? AppColors.accent : AppColors.textDark,
                fontWeight: seleccionado ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreguntaSeguridadSelector() {
    return DropdownButtonFormField<String>(
      initialValue: _preguntaSeguridadSeleccionada,
      isExpanded: true,
      dropdownColor: AppColors.card,
      style: const TextStyle(color: AppColors.textDark),
      icon: const Icon(Icons.arrow_drop_down, color: AppColors.textLight),
      decoration: InputDecoration(
        labelText: 'Pregunta de seguridad',
        labelStyle: const TextStyle(color: AppColors.textLight),
        prefixIcon: const Icon(Icons.help_outline, color: AppColors.textLight),
        filled: true,
        fillColor: AppColors.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      items: _preguntasSeguridad
          .map((pregunta) => DropdownMenuItem(
                value: pregunta,
                child: Text(
                  pregunta,
                  overflow: TextOverflow.ellipsis,
                ),
              ))
          .toList(),
      onChanged: (valor) {
        setState(() => _preguntaSeguridadSeleccionada = valor);
      },
    );
  }

  Future<void> _crearCuenta() async {
    final nombre = _nombreController.text.trim();
    final correo = _emailController.text.trim();
    final contrasena = _passwordController.text;
    final confirmar = _confirmarController.text;
    final respuestaSeguridad = _respuestaSeguridadController.text.trim();

    if (nombre.isEmpty ||
        correo.isEmpty ||
        contrasena.isEmpty ||
        confirmar.isEmpty ||
        respuestaSeguridad.isEmpty) {
      _mostrarMensaje('Completa todos los campos');
      return;
    }

    if (contrasena != confirmar) {
      _mostrarMensaje('Las contraseñas no coinciden');
      return;
    }

    if (_generoSeleccionado == null) {
      _mostrarMensaje('Selecciona tu género para continuar');
      return;
    }

    if (_preguntaSeguridadSeleccionada == null) {
      _mostrarMensaje('Selecciona una pregunta de seguridad');
      return;
    }

    await DatabaseHelper().insertarUsuario(
      nombre,
      correo,
      contrasena,
      _generoSeleccionado!,
      preguntaSeguridad: _preguntaSeguridadSeleccionada,
      respuestaSeguridad: respuestaSeguridad,
    );

    if (!mounted) return;

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