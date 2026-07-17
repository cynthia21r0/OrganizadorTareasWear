import 'package:flutter/material.dart';
import '../services/auth_storage.dart';
import '../services/wear_api_client.dart';
import '../services/wear_auth_repository.dart';
import '../services/wear_task_repository.dart';
import '../theme/wear_colors.dart';
import '../utils/screen_utils.dart';
import '../widgets/wear_error_tile.dart';
import 'task_list_screen.dart';

class WearAccountScreen extends StatefulWidget {
  const WearAccountScreen({super.key});

  @override
  State<WearAccountScreen> createState() => _WearAccountScreenState();
}

class _WearAccountScreenState extends State<WearAccountScreen> {
  List<SavedAccount> _accounts = [];
  String? _activeUserId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    final accounts = await AuthStorage.loadAll();
    final active = await AuthStorage.loadActive();
    setState(() {
      _accounts = accounts;
      _activeUserId = active?.userId;
      _loading = false;
    });
  }

  Future<void> _switchTo(SavedAccount account) async {
    await AuthStorage.setActive(account.userId);
    WearApiClient.instance.token = account.token;
    WearApiClient.instance.userId = account.userId;
    WearApiClient.instance.userRole = account.role;

    final tasks = await WearTaskRepository().getMyTasks(account.userId);
    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => TaskListScreen(
          userName: account.userName,
          profilePicture: account.profilePicture,
          initialTasks: tasks,
        ),
      ),
      (route) => false,
    );
  }

  Future<void> _removeAccount(SavedAccount account) async {
    await AuthStorage.removeAccount(account.userId);
    await _loadAccounts();
  }

  void _openLogin() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const _WearLoginForm()),
    ).then((_) => _loadAccounts());
  }

  void _openRegister() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const _WearRegisterForm()),
    ).then((_) => _loadAccounts());
  }

  @override
  Widget build(BuildContext context) {
    final hPad = safeHorizontalPadding(context);

    return Scaffold(
      backgroundColor: WearColors.background,
      body: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: WearColors.headerTeal),
              )
            : CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 4),
                      child: const Text(
                        'CUENTAS',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: WearColors.textSecondary,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(hPad, 10, hPad, 4),
                    sliver: SliverList.separated(
                      itemCount: _accounts.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 6),
                      itemBuilder: (_, i) {
                        final acc = _accounts[i];
                        final isActive = acc.userId == _activeUserId;
                        return _AccountTile(
                          account: acc,
                          isActive: isActive,
                          onTap: isActive ? null : () => _switchTo(acc),
                          onRemove: () => _removeAccount(acc),
                        );
                      },
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(hPad, 10, hPad, 20),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _ActionButton(
                          icon: Icons.login,
                          label: 'Iniciar sesión',
                          onTap: _openLogin,
                        ),
                        const SizedBox(height: 6),
                        _ActionButton(
                          icon: Icons.person_add_outlined,
                          label: 'Registrar usuario',
                          onTap: _openRegister,
                        ),
                        const SizedBox(height: 6),
                        _ActionButton(
                          icon: Icons.keyboard_arrow_up,
                          label: 'Volver',
                          onTap: () => Navigator.of(context).pop(),
                        ),
                      ]),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  final SavedAccount account;
  final bool isActive;
  final VoidCallback? onTap;
  final VoidCallback onRemove;

  const _AccountTile({
    required this.account,
    required this.isActive,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? WearColors.headerTeal.withOpacity(0.15)
              : WearColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: isActive
              ? Border.all(color: WearColors.headerTeal, width: 1.5)
              : null,
          boxShadow: const [
            BoxShadow(
                color: WearColors.cardShadow, blurRadius: 4, offset: Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: WearColors.headerTeal.withOpacity(0.2),
              child: Text(
                account.userName.isNotEmpty
                    ? account.userName[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: WearColors.headerTealDark),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                account.userName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isActive ? WearColors.headerTealDark : WearColors.textNavy,
                ),
              ),
            ),
            if (isActive)
              const Icon(Icons.check_circle, color: WearColors.headerTeal, size: 14)
            else
              GestureDetector(
                onTap: onRemove,
                child: const Icon(Icons.close,
                    color: WearColors.textSecondary, size: 14),
              ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: WearColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
                color: WearColors.cardShadow, blurRadius: 4, offset: Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: WearColors.headerTeal, size: 16),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: WearColors.textNavy),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Login form ────────────────────────────────────────────────────────────────

class _WearLoginForm extends StatefulWidget {
  const _WearLoginForm();

  @override
  State<_WearLoginForm> createState() => _WearLoginFormState();
}

class _WearLoginFormState extends State<_WearLoginForm> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await WearAuthRepository()
          .login(_emailCtrl.text.trim(), _passCtrl.text);

      final account = SavedAccount(
        token: result.token,
        userId: result.userId,
        userName: result.userName,
        role: result.role,
        profilePicture: result.profilePicture,
      );
      await AuthStorage.saveAccount(account);

      WearApiClient.instance.token = result.token;
      WearApiClient.instance.userId = result.userId;
      WearApiClient.instance.userRole = result.role;

      final tasks = await WearTaskRepository().getMyTasks(result.userId);
      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => TaskListScreen(
            userName: result.userName,
            profilePicture: result.profilePicture,
            initialTasks: tasks,
          ),
        ),
        (route) => false,
      );
    } catch (e) {
      setState(() => _error = friendlyError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _AuthFormScaffold(
        title: 'INICIAR SESIÓN',
        loading: _loading,
        error: _error,
        onSubmit: _submit,
        submitLabel: 'ENTRAR',
        fields: [
          _WearTextField(controller: _emailCtrl, hint: 'Correo', obscure: false),
          const SizedBox(height: 6),
          _WearTextField(
              controller: _passCtrl, hint: 'Contraseña', obscure: true),
        ],
      );
}

// ── Register form ─────────────────────────────────────────────────────────────

class _WearRegisterForm extends StatefulWidget {
  const _WearRegisterForm();

  @override
  State<_WearRegisterForm> createState() => _WearRegisterFormState();
}

class _WearRegisterFormState extends State<_WearRegisterForm> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _inviteCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  static const _roles = [
    'padre', 'madre', 'hijo', 'hija',
    'abuelo', 'abuela', 'tio', 'tia', 'otro'
  ];
  String _role = 'otro';

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await WearAuthRepository().register(
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
        role: _role,
        inviteCode: _inviteCtrl.text.trim().isEmpty
            ? null
            : _inviteCtrl.text.trim(),
      );

      final account = SavedAccount(
        token: result.token,
        userId: result.userId,
        userName: result.userName,
        role: result.role,
        profilePicture: result.profilePicture,
      );
      await AuthStorage.saveAccount(account);

      WearApiClient.instance.token = result.token;
      WearApiClient.instance.userId = result.userId;
      WearApiClient.instance.userRole = result.role;

      final tasks = await WearTaskRepository().getMyTasks(result.userId);
      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => TaskListScreen(
            userName: result.userName,
            profilePicture: result.profilePicture,
            initialTasks: tasks,
          ),
        ),
        (route) => false,
      );
    } catch (e) {
      setState(() => _error = friendlyError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _inviteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _AuthFormScaffold(
        title: 'REGISTRAR',
        loading: _loading,
        error: _error,
        onSubmit: _submit,
        submitLabel: 'CREAR',
        fields: [
          _WearTextField(controller: _nameCtrl, hint: 'Nombre', obscure: false),
          const SizedBox(height: 6),
          _WearTextField(controller: _emailCtrl, hint: 'Correo', obscure: false),
          const SizedBox(height: 6),
          _WearTextField(
              controller: _passCtrl, hint: 'Contraseña', obscure: true),
          const SizedBox(height: 6),
          _WearTextField(
              controller: _inviteCtrl,
              hint: 'Código de familia',
              obscure: false),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: WearColors.headerTeal.withOpacity(0.4)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _role,
                isExpanded: true,
                style: const TextStyle(
                    fontSize: 11, color: WearColors.textNavy),
                items: _roles
                    .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                    .toList(),
                onChanged: (v) => setState(() => _role = v!),
              ),
            ),
          ),
        ],
      );
}

// ── Shared widgets ────────────────────────────────────────────────────────────

class _AuthFormScaffold extends StatelessWidget {
  final String title;
  final bool loading;
  final String? error;
  final VoidCallback onSubmit;
  final String submitLabel;
  final List<Widget> fields;

  const _AuthFormScaffold({
    required this.title,
    required this.loading,
    required this.error,
    required this.onSubmit,
    required this.submitLabel,
    required this.fields,
  });

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
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: WearColors.textSecondary,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 14),
              ...fields,
              const SizedBox(height: 10),
              if (error != null) ...[
                WearErrorTile(error!),
                const SizedBox(height: 8),
              ],
              GestureDetector(
                onTap: loading ? null : onSubmit,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: WearColors.headerTeal,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: loading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          submitLabel,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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

class _WearTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;

  const _WearTextField(
      {required this.controller, required this.hint, required this.obscure});

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
          borderSide:
              BorderSide(color: WearColors.headerTeal.withOpacity(0.4)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              BorderSide(color: WearColors.headerTeal.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: WearColors.headerTeal),
        ),
      ),
    );
  }
}
