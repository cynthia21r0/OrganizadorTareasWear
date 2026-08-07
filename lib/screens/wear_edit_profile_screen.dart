import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../services/auth_storage.dart';
import '../theme/wear_colors.dart';
import '../utils/screen_utils.dart';

class WearEditProfileScreen extends StatefulWidget {
  const WearEditProfileScreen({super.key});

  @override
  State<WearEditProfileScreen> createState() => _WearEditProfileScreenState();
}

class _WearEditProfileScreenState extends State<WearEditProfileScreen> {
  SavedAccount? _account;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final account = await AuthStorage.loadActive();
    setState(() {
      _account = account;
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
    final avatarBytes = _account?.profilePicture != null
        ? _decodeAvatar(_account!.profilePicture!)
        : null;

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

                    if (_account == null)
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
                                  _account!.userName.isNotEmpty
                                      ? _account!.userName[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: WearColors.headerTealDark),
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _InfoRow(label: 'Nombre', value: _account!.userName),
                      const SizedBox(height: 8),
                      _InfoRow(label: 'Correo', value: _account!.email),
                      const SizedBox(height: 8),
                      _InfoRow(
                        label: 'Rol',
                        value: _roleLabels[_account!.role] ?? _account!.role,
                      ),
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