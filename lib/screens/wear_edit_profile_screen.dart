import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../services/auth_storage.dart';
import '../services/wear_auth_repository.dart';
import '../theme/wear_colors.dart';
import '../utils/screen_utils.dart';

class WearEditProfileScreen extends StatefulWidget {
  const WearEditProfileScreen({super.key});

  @override
  State<WearEditProfileScreen> createState() => _WearEditProfileScreenState();
}

class _WearEditProfileScreenState extends State<WearEditProfileScreen> {
  SavedAccount? _account;
  WearFamilyMember? _me;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final account = await AuthStorage.loadActive();
    WearFamilyMember? me;
    try {
      me = await WearAuthRepository().getMe();
    } catch (_) {
      // Sin conexión o error del servidor: seguimos con los datos locales
      me = null;
    }
    if (!mounted) return;
    setState(() {
      _account = account;
      _me = me;
      _loading = false;
    });
  }

  static const _roleLabels = {
    'padre': 'Padre',
    'madre': 'Madre',
    'hijo': 'Hijo',
    'hija': 'Hija',
    'abuelo': 'Abuelo',
    'abuela': 'Abuela',
    'tio': 'Tío',
    'tia': 'Tía',
    'otro': 'Otro',
  };

  Uint8List? _decodeAvatar(String base64Str) {
    try {
      final clean = base64Str.contains(',')
          ? base64Str.split(',').last
          : base64Str;
      return base64Decode(clean);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hPad = safeHorizontalPadding(context);

    // Preferimos los datos frescos del backend; si no hay, caemos al local.
    final name = _me?.name ?? _account?.userName ?? '';
    final role = _me?.role ?? _account?.role ?? 'otro';
    final email = _me?.email;
    final rawPicture = _me?.profilePicture ?? _account?.profilePicture;
    final avatarBytes = rawPicture != null ? _decodeAvatar(rawPicture) : null;
    final hasData = _account != null || _me != null;

    return Scaffold(
      backgroundColor: WearColors.background,
      body: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: WearColors.headerTeal),
              )
            : SingleChildScrollView(
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
                    const SizedBox(height: 16),

                    if (!hasData)
                      const Center(
                        child: Text(
                          'No hay sesión activa',
                          style: TextStyle(
                              fontSize: 11, color: WearColors.textSecondary),
                        ),
                      )
                    else ...[
                      Center(
                        child: CircleAvatar(
                          radius: 28,
                          backgroundColor:
                              WearColors.headerTeal.withOpacity(0.2),
                          backgroundImage: avatarBytes != null
                              ? MemoryImage(avatarBytes)
                              : null,
                          child: avatarBytes == null
                              ? Text(
                                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: WearColors.headerTealDark),
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _InfoRow(label: 'Nombre', value: name),
                      const SizedBox(height: 8),
                      if (email != null && email.isNotEmpty) ...[
                        _InfoRow(label: 'Correo', value: email),
                        const SizedBox(height: 8),
                      ],
                      _InfoRow(
                        label: 'Rol',
                        value: _roleLabels[role] ?? role,
                      ),
                      if (email == null || email.isEmpty) ...[
                        const SizedBox(height: 8),
                        const Text(
                          'No se pudo cargar el correo. Verifica tu conexión.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 9.5, color: WearColors.textSecondary),
                        ),
                      ],
                    ],

                    const SizedBox(height: 14),
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

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: WearColors.headerTeal.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 8.5,
              fontWeight: FontWeight.bold,
              color: WearColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: WearColors.textNavy,
            ),
          ),
        ],
      ),
    );
  }
}