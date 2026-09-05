import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/admin_user.dart';
import '../services/admin_users_service.dart';
import '../state/auth_store.dart';
import '../theme/app_text_color.dart';
import '../widgets/app_background.dart';
import '../widgets/glass_panel.dart';

class AdminUsersScreen extends StatefulWidget {
  final AuthStore authStore;
  // null (по умолчанию) - экран открыт отдельным маршрутом, кнопка
  // "назад" делает обычный pop(). Задан - экран встроен содержимым в
  // AdminShellScreen, кнопка "назад" должна вернуть на раздел "Обзор"
  // внутри той же оболочки, а не вытолкнуть из всей админки через pop()
  final VoidCallback? onBack;
  const AdminUsersScreen({super.key, required this.authStore, this.onBack});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final _service = AdminUsersService();
  List<AdminUser> _users = [];
  bool _isLoading = true;
  String? _error;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final token = widget.authStore.token;
    if (token == null) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final users = await _service.listUsers(baseUrl: widget.authStore.baseUrl, token: token);
      if (!mounted) return;
      setState(() => _users = users);
    } on AdminUsersException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<AdminUser> get _filtered {
    if (_search.trim().isEmpty) return _users;
    final q = _search.trim().toLowerCase();
    return _users.where((u) => u.email.toLowerCase().contains(q)).toList();
  }

  int get _onlineCount => _users.where((u) => u.isOnlineNow).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // сайдбар в AdminShellScreen уже даёт навигацию - кнопка "назад" была
                    // бы бессмысленной, когда экран встроен содержимым (onBack задан).
                    // Показываем её только при обычном отдельном маршруте (onBack == null).
                    if (widget.onBack == null)
                      IconButton(
                        icon: Icon(Icons.arrow_back_rounded, color: context.onSurface),
                        onPressed: () => Navigator.of(context).pop(),
                      )
                    else
                      const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Пользователи',
                        style: TextStyle(color: context.onSurface, fontSize: 17, fontWeight: FontWeight.w600),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Добавить пользователя',
                      icon: Icon(Icons.person_add_alt_1_rounded, color: context.onSurface),
                      onPressed: _showCreateUserSheet,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 680),
                    child: RefreshIndicator(
                      onRefresh: _load,
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          _buildSummary(),
                          const SizedBox(height: 12),
                          _buildSearch(),
                          if (_error != null) ...[
                            const SizedBox(height: 12),
                            Text(_error!, style: const TextStyle(color: Color(0xFFFFB4B4))),
                          ],
                          const SizedBox(height: 16),
                          if (_isLoading)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 60),
                              child: Center(child: CircularProgressIndicator(color: Color(0xFF6C5CE7))),
                            )
                          else if (_filtered.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 40),
                              child: Center(
                                child: Text('Никого не найдено', style: TextStyle(color: context.onSurfaceFaded(0.4))),
                              ),
                            )
                          else
                            ..._filtered.map(_buildUserTile),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummary() {
    return Row(
      children: [
        Expanded(
          child: GlassPanel(
            opacity: 0.08,
            borderRadius: BorderRadius.circular(16),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${_users.length}', style: TextStyle(color: context.onSurface, fontSize: 22, fontWeight: FontWeight.w700)),
                Text('всего', style: TextStyle(color: context.onSurfaceFaded(0.5), fontSize: 12)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GlassPanel(
            opacity: 0.08,
            borderRadius: BorderRadius.circular(16),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(right: 6, bottom: 2),
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF00E6A0)),
                    ),
                    Text('$_onlineCount', style: TextStyle(color: context.onSurface, fontSize: 22, fontWeight: FontWeight.w700)),
                  ],
                ),
                Text('в сети сейчас', style: TextStyle(color: context.onSurfaceFaded(0.5), fontSize: 12)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearch() {
    return TextField(
      onChanged: (v) => setState(() => _search = v),
      style: TextStyle(color: context.onSurface),
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.search_rounded, color: context.onSurfaceFaded(0.4)),
        hintText: 'Поиск по email…',
        hintStyle: TextStyle(color: context.onSurfaceFaded(0.3)),
        filled: true,
        fillColor: context.onSurfaceFaded(0.06),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  Widget _buildUserTile(AdminUser user) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassPanel(
        opacity: 0.07,
        blurred: false, // список из многих пользователей — см. message_bubble.dart
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _showEditSheet(user),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: user.isOnlineNow ? const Color(0xFF00E6A0) : Colors.white24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                user.email,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: context.onSurface, fontWeight: FontWeight.w600, fontSize: 13.5),
                              ),
                            ),
                            if (user.isAdmin) ...[
                              const SizedBox(width: 6),
                              _badge('admin', const Color(0xFF6C5CE7)),
                            ],
                            if (user.isOperator) ...[
                              const SizedBox(width: 6),
                              _badge('оператор', const Color(0xFF00E6A0)),
                            ],
                            if (!user.isActive) ...[
                              const SizedBox(width: 6),
                              _badge('деактивирован', const Color(0xFFFF6B6B)),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _subtitleFor(user),
                          style: TextStyle(color: context.onSurfaceFaded(0.45), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _badge(user.tariff, const Color(0xFF00B4D8)),
                      const SizedBox(height: 4),
                      Text(
                        _expiryLabel(user),
                        style: TextStyle(
                          color: user.isTariffExpired ? const Color(0xFFFFB4B4) : context.onSurfaceFaded(0.4),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _subtitleFor(AdminUser user) {
    if (user.isOnlineNow) return 'В сети сейчас';
    if (user.lastActiveAt == null) return 'Ещё не заходил(а)';
    return 'Был(а) в сети ${DateFormat.yMMMd().add_Hm().format(user.lastActiveAt!)}';
  }

  String _expiryLabel(AdminUser user) {
    final days = user.daysUntilExpiry;
    if (days == null) return 'бессрочно';
    if (days < 0) return 'истёк ${-days} дн. назад';
    if (days == 0) return 'истекает сегодня';
    return 'осталось $days дн.';
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: color.withValues(alpha: 0.18)),
      child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }

  Future<void> _showEditSheet(AdminUser user) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EditUserSheet(
        user: user,
        authStore: widget.authStore,
        service: _service,
        onChanged: (updated) {
          setState(() {
            final idx = _users.indexWhere((u) => u.id == updated.id);
            if (idx != -1) _users[idx] = updated;
          });
        },
        onDeleted: () {
          setState(() => _users.removeWhere((u) => u.id == user.id));
        },
      ),
    );
  }

  Future<void> _showCreateUserSheet() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CreateUserSheet(
        authStore: widget.authStore,
        service: _service,
        onCreated: (created) {
          setState(() => _users = [created, ..._users]);
        },
      ),
    );
  }
}

class _EditUserSheet extends StatefulWidget {
  final AdminUser user;
  final AuthStore authStore;
  final AdminUsersService service;
  final ValueChanged<AdminUser> onChanged;
  final VoidCallback onDeleted;

  const _EditUserSheet({
    required this.user,
    required this.authStore,
    required this.service,
    required this.onDeleted,
    required this.onChanged,
  });

  @override
  State<_EditUserSheet> createState() => _EditUserSheetState();
}

class _EditUserSheetState extends State<_EditUserSheet> {
  late final TextEditingController _tariffController;
  bool _isBusy = false;
  String? _error;

  bool get _isSelf => widget.user.id == widget.authStore.user?.id;

  @override
  void initState() {
    super.initState();
    _tariffController = TextEditingController(text: widget.user.tariff);
  }

  @override
  void dispose() {
    _tariffController.dispose();
    super.dispose();
  }

  Future<void> _apply({
    String? tariff,
    String? role,
    bool? isActive,
    int? tariffDays,
    bool? clearTariffExpiry,
    bool? isOperator,
  }) async {
    final token = widget.authStore.token;
    if (token == null) return;
    setState(() {
      _isBusy = true;
      _error = null;
    });
    try {
      final updated = await widget.service.updateUser(
        baseUrl: widget.authStore.baseUrl,
        token: token,
        userId: widget.user.id,
        tariff: tariff,
        role: role,
        isActive: isActive,
        tariffDays: tariffDays,
        clearTariffExpiry: clearTariffExpiry,
        isOperator: isOperator,
      );
      widget.onChanged(updated);
      if (mounted) Navigator.of(context).pop();
    } on AdminUsersException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _confirmAndDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassPanel(
          opacity: 0.18,
          borderRadius: BorderRadius.circular(20),
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Удалить пользователя?',
                  style: TextStyle(color: context.onSurface, fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  '${widget.user.email} будет удалён(а) безвозвратно, вместе с '
                  'его обращениями в поддержку и историей расхода токенов. '
                  'Загруженные им документы для RAG останутся (просто станут '
                  'без автора).',
                  style: TextStyle(color: context.onSurfaceFaded(0.6), fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text('Отмена', style: TextStyle(color: context.onSurfaceFaded(0.6))),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: const Color(0xFFFF6B6B)),
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Удалить'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (confirmed != true) return;

    final token = widget.authStore.token;
    if (token == null) return;
    setState(() {
      _isBusy = true;
      _error = null;
    });
    try {
      await widget.service.deleteUser(baseUrl: widget.authStore.baseUrl, token: token, userId: widget.user.id);
      widget.onDeleted();
      if (mounted) Navigator.of(context).pop();
    } on AdminUsersException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: GlassPanel(
        opacity: 0.18,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        padding: const EdgeInsets.all(20),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.email, style: TextStyle(color: context.onSurface, fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),

                Text('ТАРИФ', style: TextStyle(color: context.onSurfaceFaded(0.4), fontSize: 11, letterSpacing: 1.2)),
                const SizedBox(height: 8),
                Row(
                  children: [
                  Expanded(
                    child: TextField(
                      controller: _tariffController,
                      style: TextStyle(color: context.onSurface),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: context.onSurfaceFaded(0.08),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        hintText: 'free / pro / unlimited',
                        hintStyle: TextStyle(color: context.onSurfaceFaded(0.3)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: _isBusy ? null : () => _apply(tariff: _tariffController.text.trim()),
                    child: const Text('Сохранить'),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              Text('СРОК ПОДПИСКИ', style: TextStyle(color: context.onSurfaceFaded(0.4), fontSize: 11, letterSpacing: 1.2)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final days in [7, 30, 90, 365])
                    OutlinedButton(
                      onPressed: _isBusy ? null : () => _apply(tariffDays: days),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: context.onSurfaceFaded(0.16)),
                        foregroundColor: context.onSurface,
                      ),
                      child: Text('+$days дн.'),
                    ),
                  OutlinedButton(
                    onPressed: _isBusy ? null : () => _apply(clearTariffExpiry: true),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: context.onSurfaceFaded(0.16)),
                      foregroundColor: context.onSurfaceFaded(0.7),
                    ),
                    child: const Text('Сделать бессрочным'),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              Text('РОЛЬ И ДОСТУП', style: TextStyle(color: context.onSurfaceFaded(0.4), fontSize: 11, letterSpacing: 1.2)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isBusy ? null : () => _apply(role: user.isAdmin ? 'user' : 'admin'),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: context.onSurfaceFaded(0.16)),
                        foregroundColor: context.onSurface,
                      ),
                      child: Text(user.isAdmin ? 'Снять права админа' : 'Сделать админом'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isBusy ? null : () => _apply(isActive: !user.isActive),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: (user.isActive ? const Color(0xFFFF6B6B) : const Color(0xFF00E6A0)).withValues(alpha: 0.4)),
                        foregroundColor: user.isActive ? const Color(0xFFFFB4B4) : const Color(0xFF00E6A0),
                      ),
                      child: Text(user.isActive ? 'Деактивировать' : 'Активировать'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isBusy ? null : () => _apply(isOperator: !user.isOperator),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: (user.isOperator ? const Color(0xFF00E6A0) : context.onSurface).withValues(alpha: 0.16)),
                    foregroundColor: user.isOperator ? const Color(0xFF00E6A0) : context.onSurface,
                  ),
                  icon: Icon(user.isOperator ? Icons.support_agent_rounded : Icons.support_agent_outlined, size: 18),
                  label: Text(
                    user.isOperator ? 'Убрать доступ к живой помощи' : 'Дать доступ к живой помощи',
                  ),
                ),
              ),

              const SizedBox(height: 20),
              _isSelf
                  ? Text(
                      'Нельзя удалить свой же аккаунт, пока ты им пользуешься.',
                      style: TextStyle(color: context.onSurfaceFaded(0.35), fontSize: 12),
                    )
                  : SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _isBusy ? null : _confirmAndDelete,
                        icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFFFB4B4)),
                        label: const Text('Удалить пользователя', style: TextStyle(color: Color(0xFFFFB4B4))),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: const Color(0xFFFF6B6B).withValues(alpha: 0.4)),
                        ),
                      ),
                    ),

              if (_error != null) ...[
                const SizedBox(height: 14),
                Text(_error!, style: const TextStyle(color: Color(0xFFFFB4B4), fontSize: 13)),
              ],
              if (_isBusy) ...[
                const SizedBox(height: 14),
                const Center(child: CircularProgressIndicator(color: Color(0xFF6C5CE7))),
              ],
            ],
          ),
          ),
        ),
      ),
    );
  }
}

class _CreateUserSheet extends StatefulWidget {
  final AuthStore authStore;
  final AdminUsersService service;
  final ValueChanged<AdminUser> onCreated;

  const _CreateUserSheet({
    required this.authStore,
    required this.service,
    required this.onCreated,
  });

  @override
  State<_CreateUserSheet> createState() => _CreateUserSheetState();
}

class _CreateUserSheetState extends State<_CreateUserSheet> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _tariffController = TextEditingController(text: 'free');
  String _role = 'user';
  bool _isOperator = false;
  bool _isBusy = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _tariffController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Заполни email и пароль.');
      return;
    }

    final token = widget.authStore.token;
    if (token == null) return;
    setState(() {
      _isBusy = true;
      _error = null;
    });
    try {
      final created = await widget.service.createUser(
        baseUrl: widget.authStore.baseUrl,
        token: token,
        email: email,
        password: password,
        role: _role,
        tariff: _tariffController.text.trim().isEmpty ? 'free' : _tariffController.text.trim(),
        isOperator: _isOperator,
      );
      widget.onCreated(created);
      if (mounted) Navigator.of(context).pop();
    } on AdminUsersException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: GlassPanel(
        opacity: 0.18,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        padding: const EdgeInsets.all(20),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Новый пользователь',
                style: TextStyle(color: context.onSurface, fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                'Создаётся сразу с указанным паролем — сам человек регистрироваться не должен.',
                style: TextStyle(color: context.onSurfaceFaded(0.5), fontSize: 12),
              ),
              const SizedBox(height: 16),
              _field(_emailController, 'Email', keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 10),
              _field(_passwordController, 'Пароль (минимум 8 символов)', obscure: true),
              const SizedBox(height: 10),
              _field(_tariffController, 'Тариф (free / pro / unlimited)'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text('Роль:', style: TextStyle(color: context.onSurfaceFaded(0.6), fontSize: 13)),
                  const SizedBox(width: 10),
                  ChoiceChip(
                    label: const Text('Пользователь'),
                    selected: _role == 'user',
                    onSelected: (_) => setState(() => _role = 'user'),
                    selectedColor: const Color(0xFF6C5CE7),
                    labelStyle: TextStyle(color: _role == 'user' ? Colors.white : Colors.white70, fontSize: 12.5),
                    backgroundColor: context.onSurfaceFaded(0.06),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Админ'),
                    selected: _role == 'admin',
                    onSelected: (_) => setState(() => _role = 'admin'),
                    selectedColor: const Color(0xFF6C5CE7),
                    labelStyle: TextStyle(color: _role == 'admin' ? Colors.white : Colors.white70, fontSize: 12.5),
                    backgroundColor: context.onSurfaceFaded(0.06),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Material(
                color: context.onSurfaceFaded(0.06),
                borderRadius: BorderRadius.circular(12),
                child: SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  value: _isOperator,
                  onChanged: (v) => setState(() => _isOperator = v),
                  activeThumbColor: const Color(0xFF00E6A0),
                  title: Text('Доступ к живой помощи', style: TextStyle(color: context.onSurface, fontSize: 13.5)),
                  subtitle: Text(
                    'Сможет видеть очередь заявок и подключаться к чатам — например, для врача/оператора.',
                    style: TextStyle(color: context.onSurfaceFaded(0.45), fontSize: 11.5),
                  ),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: Color(0xFFFFB4B4), fontSize: 13)),
              ],
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFF6C5CE7)),
                  onPressed: _isBusy ? null : _submit,
                  child: _isBusy
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Создать'),
                ),
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController controller, String hint, {bool obscure = false, TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: TextStyle(color: context.onSurface),
      decoration: InputDecoration(
        filled: true,
        fillColor: context.onSurfaceFaded(0.08),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        hintText: hint,
        hintStyle: TextStyle(color: context.onSurfaceFaded(0.3)),
      ),
    );
  }
}
