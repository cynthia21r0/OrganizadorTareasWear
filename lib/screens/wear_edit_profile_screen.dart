import 'package:flutter/material.dart';
import '../services/auth_storage.dart';
import '../services/wear_api_client.dart';
import '../services/wear_auth_repository.dart';
import '../theme/wear_colors.dart';
import '../utils/screen_utils.dart';
import '../widgets/wear_error_tile.dart';

class WearEditProfileScreen extends StatefulWidget {
  const WearEditProfileScreen({super.key});

  @override
  State<WearEditProfileScreen> createState() => _WearEditProfileScreenState();
}

class _WearEditProfileScreenState extends State<WearEditProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _currentPassCtrl = TextEditingController();

  bool _saving = false;
  bool _success = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _prefill();
  }

  Future<void> _prefill() async {
    final account = await AuthStorage.loadActive();
    if (account == null) return;
    _nameCtrl.text = account.userName;
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final newPass = _newPassCtrl.text;
    final currentPass = _currentPassCtrl.text;

    if (name.isEmpty && email.isEmpty && newPass.isEmpty) {
      setState(() => _error = 'Modifica al menos un campo.');
      return;
    }
    if (newPass.isNotEmpty && currentPass.isEmpty) {
      setState(() => _error = 'Ingresa tu contraseña actual para cambiarla.');
      return;
    }

    setState(() { _saving = true; _error = null; _success = false; });
    try {
      await WearAuthRepository().updateProfile(
        name: name.isEmpty ? null : name,
        email: email.isEmpty ? null : email,
        password: newPass.isEmpty ? null : newPass,
        currentPassword: currentPass.isEmpty ? null : currentPass,
      );

      // Actualizar nombre en el storage si cambió
      if (name.isNotEmpty) {
        final account = await AuthStorage.loadActive();
        if (account != null) {
          await AuthStorage.saveAccount(SavedAccount(
            token: account.token,
            userId: account.userId,
            userName: name,
            role: account.role,
            profilePicture: account.profilePicture,
          ));
        }
      }

      _newPassCtrl.clear();
      _currentPassCtrl.clear();
      setState(() => _success = true);
    } catch (e) {
      setState(() => _error = friendlyError(e));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _newPassCtrl.dispose();
    _currentPassCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hPad = safeHorizontalPadding(context);

    return Scaffold(
      backgroundColor: WearColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'MI PERFIL',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: WearColors.textSecondary,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),

              _WearField(controller: _nameCtrl, hint: 'Nombre'),
              const SizedBox(height: 6),
              _WearField(controller: _emailCtrl, hint: 'Nuevo correo'),
              const SizedBox(height: 6),
              _WearField(
                  controller: _newPassCtrl,
                  hint: 'Nueva contraseña',
                  obscure: true),
              const SizedBox(height: 6),
              _WearField(
                  controller: _currentPassCtrl,
                  hint: 'Contraseña actual',
                  obscure: true),

              const SizedBox(height: 10),

              if (_error != null) ...[
                WearErrorTile(_error!),
                const SizedBox(height: 8),
              ],

              if (_success) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: Colors.green.withValues(alpha: 0.4)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle_outline,
                          color: Colors.green, size: 14),
                      SizedBox(width: 6),
                      Text(
                        'Perfil actualizado',
                        style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF2E7D32)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],

              // Guardar
              GestureDetector(
                onTap: _saving ? null : _save,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: WearColors.headerTeal,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: _saving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text(
                          'GUARDAR',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(height: 6),

              // Volver
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: WearColors.cardBackground,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                          color: WearColors.cardShadow,
                          blurRadius: 4,
                          offset: Offset(0, 2))
                    ],
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.keyboard_arrow_up,
                          color: WearColors.headerTeal, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'Volver',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: WearColors.textNavy),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WearField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;

  const _WearField({
    required this.controller,
    required this.hint,
    this.obscure = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(fontSize: 11, color: WearColors.textNavy),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            const TextStyle(fontSize: 11, color: WearColors.textSecondary),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
              color: WearColors.headerTeal.withValues(alpha: 0.4)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
              color: WearColors.headerTeal.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: WearColors.headerTeal),
        ),
      ),
    );
  }
}
