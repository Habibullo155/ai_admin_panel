import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../models/app_user.dart';
import '../state/auth_store.dart';
import '../theme/app_text_color.dart';
import '../utils/auth_navigation.dart';
import '../widgets/app_background.dart';
import '../widgets/glass_panel.dart';

// склонение "год/года/лет" по числу - "21 лет" грамматически неверно,
// Вынесено отдельной функцией, чтобы не дублировать оформление пикера
// (тема + границы дат) в двух местах - и при тапе прямо по значению
// даты рождения на экране просмотра, и внутри диалога "Редактировать
// профиль". initialDate - откуда пикер стартует, если дата ещё не
// задана.
Future<DateTime?> _showBirthDatePicker(BuildContext context, DateTime? currentValue) {
  final now = DateTime.now();
  return showDatePicker(
    context: context,
    initialDate: currentValue ?? DateTime(now.year - 25, now.month, now.day),
    firstDate: DateTime(now.year - 120),
    lastDate: now,
    helpText: 'Дата рождения',
    // тема выбора даты подстраивается под текущую (свето/тёмную) тему
    // приложения, только акцентный цвет меняем на фирменный фиолетовый -
    // иначе стандартный Material-пикер выглядел бы чужеродно рядом со
    // стеклянным интерфейсом остального приложения
    builder: (context, child) => Theme(
      data: Theme.of(context).copyWith(
        colorScheme: Theme.of(context).colorScheme.copyWith(primary: const Color(0xFF6C5CE7)),
      ),
      child: child!,
    ),
  );
}

// должно быть "21 год". Проверено на 1, 11, 21, 22, 25, 111 и т.п. -
// исключение 11-14 (всегда "лет", даже когда последняя цифра 1-4)
String _pluralYears(int n) {
  final n100 = n % 100;
  final n10 = n % 10;
  if (n100 >= 11 && n100 <= 14) return 'лет';
  if (n10 == 1) return 'год';
  if (n10 >= 2 && n10 <= 4) return 'года';
  return 'лет';
}

class ProfileScreen extends StatefulWidget {
  final AuthStore authStore;
  const ProfileScreen({super.key, required this.authStore});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _picker = ImagePicker();
  bool _isUploadingAvatar = false;

  Future<void> _pickAvatar() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1A2036),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera_rounded, color: Colors.white),
                title: const Text('Сделать фото', style: TextStyle(color: Colors.white)),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded, color: Colors.white),
                title: const Text('Выбрать из галереи', style: TextStyle(color: Colors.white)),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
              if (widget.authStore.user?.avatarBase64 != null)
                ListTile(
                  leading: const Icon(Icons.delete_outline_rounded, color: Color(0xFFFF6B6B)),
                  title: const Text('Удалить фото', style: TextStyle(color: Color(0xFFFF6B6B))),
                  onTap: () {
                    Navigator.of(context).pop();
                    _removeAvatar();
                  },
                ),
            ],
          ),
        ),
      ),
    );

    if (source != null) {
      await _uploadAvatar(source);
    }
  }

  Future<void> _uploadAvatar(ImageSource source) async {
    // квадратный кроп + сжатие сразу при выборе - тот же приём, что и у
    // фото в чате (chat_input_bar.dart), маленький аватар не должен
    // раздувать профиль на сервере
    final file = await _picker.pickImage(source: source, maxWidth: 512, maxHeight: 512, imageQuality: 75);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() => _isUploadingAvatar = true);
    final error = await widget.authStore.updateProfile(avatarBase64: base64Encode(bytes));
    if (mounted) {
      setState(() => _isUploadingAvatar = false);
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      }
    }
  }

  Future<void> _removeAvatar() async {
    setState(() => _isUploadingAvatar = true);
    final error = await widget.authStore.updateProfile(clearAvatar: true);
    if (mounted) {
      setState(() => _isUploadingAvatar = false);
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      }
    }
  }

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
                    IconButton(
                      icon: Icon(Icons.arrow_back_rounded, color: context.onSurface),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Личный кабинет',
                      style: TextStyle(color: context.onSurface, fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      // Слушаем authStore напрямую — после сохранения
                      // профиля в диалоге редактирования user меняется
                      // и экран должен сразу показать новые значения, а
                      // не только после повторного открытия.
                      child: AnimatedBuilder(
                        animation: widget.authStore,
                        builder: (context, _) {
                          final user = widget.authStore.user;
                          return user == null
                              ? Text('Нет данных', style: TextStyle(color: context.onSurface))
                              : _buildContent(context, user);
                        },
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

  Widget _buildContent(BuildContext context, AppUser user) {
    final displayName = user.fullName?.isNotEmpty == true ? user.fullName! : user.email.split('@').first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // карточка-заголовок - аватар с именем и почтой прямо под ним,
        // крупно. Раньше имя было просто ещё одной строкой в общем
        // списке наравне с "Тарифом"/"Ролью" - в профилях крупных
        // компаний (Google, Apple и т.п.) личность человека всегда
        // выделена визуально отдельно от списка настроек, не растворена
        // в нём
        GlassPanel(
          opacity: 0.10,
          borderRadius: BorderRadius.circular(28),
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              Center(
                child: GestureDetector(
                  onTap: _isUploadingAvatar ? null : _pickAvatar,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 88,
                        height: 88,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(colors: [Color(0xFF6C5CE7), Color(0xFF00D9C0)]),
                          image: user.avatarBase64 != null
                              ? DecorationImage(image: MemoryImage(base64Decode(user.avatarBase64!)), fit: BoxFit.cover)
                              : null,
                        ),
                        child: _isUploadingAvatar
                            ? const CircularProgressIndicator(color: Colors.white)
                            : user.avatarBase64 == null
                                ? Text(
                                    (user.fullName?.isNotEmpty == true ? user.fullName![0] : user.email[0]).toUpperCase(),
                                    style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700),
                                  )
                                : null,
                      ),
                      Positioned(
                        bottom: -2,
                        right: -2,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF6C5CE7),
                            border: Border.all(color: const Color(0xFF1A2036), width: 2),
                          ),
                          child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (user.avatarBase64 != null) ...[
                const SizedBox(height: 6),
                TextButton(
                  onPressed: _isUploadingAvatar ? null : _removeAvatar,
                  child: Text('Удалить фото', style: TextStyle(color: context.onSurfaceFaded(0.5), fontSize: 12.5)),
                ),
              ],
              const SizedBox(height: 12),
              Text(
                displayName,
                textAlign: TextAlign.center,
                style: TextStyle(color: context.onSurface, fontSize: 19, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 3),
              Text(
                user.email,
                textAlign: TextAlign.center,
                style: TextStyle(color: context.onSurfaceFaded(0.5), fontSize: 13.5),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: const LinearGradient(colors: [Color(0xFF6C5CE7), Color(0xFF00B4D8)]),
                ),
                child: Text(
                  user.tariff,
                  style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _sectionCard('ЛИЧНОЕ', [
          _row('ФИО', user.fullName?.isNotEmpty == true ? user.fullName! : 'не указано'),
          _row(
            'Дата рождения',
            user.birthDate != null
                ? '${DateFormat('d MMMM yyyy', 'ru').format(user.birthDate!)} (${user.age} ${_pluralYears(user.age!)})'
                : 'не указано',
            onTap: () => _editBirthDateInline(context, widget.authStore, user),
          ),
          _row('Хобби', user.hobbies?.isNotEmpty == true ? user.hobbies! : 'не указано'),
          _row('Экстренный контакт', user.emergencyContact?.isNotEmpty == true ? user.emergencyContact! : 'не указано'),
        ]),
        const SizedBox(height: 16),
        _sectionCard('АККАУНТ', [
          _row('Email', user.email, onTap: () => _showEmailChangeDialog(context, widget.authStore, user)),
          _row('Роль', user.isAdmin ? 'Администратор' : 'Пользователь'),
          _row('Аккаунт создан', DateFormat.yMMMd().format(user.createdAt)),
        ]),
        const SizedBox(height: 20),
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => _showEditDialog(context, user),
            child: Container(
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: const LinearGradient(colors: [Color(0xFF6C5CE7), Color(0xFF00B4D8)]),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.edit_outlined, size: 18, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Редактировать профиль', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => _showPasswordChangeDialog(context, widget.authStore),
            child: Container(
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: context.borderSubtle),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline_rounded, size: 18, color: context.onSurfaceFaded(0.7)),
                  const SizedBox(width: 8),
                  Text('Изменить пароль', style: TextStyle(color: context.onSurface, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _LogoutButton(onTap: () => confirmAndLogout(context, widget.authStore)),
      ],
    );
  }

  // отдельная карточка на группу связанных полей, с подписью группы -
  // раньше все поля шли одним сплошным списком через _divider(), теперь
  // видно, что "Хобби" и "Экстренный контакт" относятся к личным данным,
  // а "Роль" и "Дата создания" - к самому аккаунту, не всё вперемешку
  Widget _sectionCard(String label, List<Widget> rows) {
    final withDividers = <Widget>[];
    for (var i = 0; i < rows.length; i++) {
      if (i > 0) withDividers.add(_divider());
      withDividers.add(rows[i]);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: TextStyle(color: context.onSurfaceFaded(0.4), fontSize: 11.5, fontWeight: FontWeight.w600, letterSpacing: 0.6),
          ),
        ),
        GlassPanel(
          opacity: 0.10,
          borderRadius: BorderRadius.circular(20),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: withDividers),
        ),
      ],
    );
  }

  Future<void> _showEditDialog(BuildContext context, AppUser user) async {
    await showDialog(
      context: context,
      builder: (context) => _EditProfileDialog(authStore: widget.authStore, user: user),
    );
  }

  Future<void> _showPasswordChangeDialog(BuildContext context, AuthStore authStore) async {
    await showDialog(
      context: context,
      builder: (context) => _PasswordChangeDialog(authStore: authStore),
    );
  }

  Future<void> _showEmailChangeDialog(BuildContext context, AuthStore authStore, AppUser user) async {
    await showDialog(
      context: context,
      builder: (context) => _EmailChangeDialog(authStore: authStore, currentEmail: user.email),
    );
  }

  // тап прямо по значению даты рождения - открывает календарь и сразу
  // сохраняет выбор, без необходимости открывать общий диалог
  // редактирования ради одного этого поля
  Future<void> _editBirthDateInline(BuildContext context, AuthStore authStore, AppUser user) async {
    final picked = await _showBirthDatePicker(context, user.birthDate);
    if (picked == null) return;
    final error = await authStore.updateProfile(birthDate: picked);
    if (error != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  Widget _divider() => Divider(color: context.onSurfaceFaded(0.08), height: 28);

  Widget _row(String label, String value, {VoidCallback? onTap}) {
    final row = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: context.onSurfaceFaded(0.55), fontSize: 13.5)),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: TextStyle(color: context.onSurface, fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
            // лёгкий намёк, что по значению можно тапнуть и поменять его
            // напрямую - не нужно открывать общий диалог редактирования
            // ради одного этого поля
            if (onTap != null) ...[
              const SizedBox(width: 4),
              Icon(Icons.chevron_right_rounded, size: 16, color: context.onSurfaceFaded(0.3)),
            ],
          ],
        ),
      ],
    );

    if (onTap == null) return row;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: row),
    );
  }
}

class _EditProfileDialog extends StatefulWidget {
  final AuthStore authStore;
  final AppUser user;
  const _EditProfileDialog({required this.authStore, required this.user});

  @override
  State<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _hobbiesController;
  late final TextEditingController _emergencyContactController;
  DateTime? _birthDate;
  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.fullName ?? '');
    _hobbiesController = TextEditingController(text: widget.user.hobbies ?? '');
    _emergencyContactController = TextEditingController(text: widget.user.emergencyContact ?? '');
    _birthDate = widget.user.birthDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _hobbiesController.dispose();
    _emergencyContactController.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final picked = await _showBirthDatePicker(context, _birthDate);
    if (picked != null) setState(() => _birthDate = picked);
  }

  Future<void> _save() async {
    setState(() {
      _isSaving = true;
      _error = null;
    });

    final name = _nameController.text.trim();
    final hobbies = _hobbiesController.text.trim();
    final emergencyContact = _emergencyContactController.text.trim();

    final error = await widget.authStore.updateProfile(
      fullName: name.isNotEmpty ? name : null,
      clearFullName: name.isEmpty,
      birthDate: _birthDate,
      clearBirthDate: _birthDate == null,
      hobbies: hobbies.isNotEmpty ? hobbies : null,
      clearHobbies: hobbies.isEmpty,
      emergencyContact: emergencyContact.isNotEmpty ? emergencyContact : null,
      clearEmergencyContact: emergencyContact.isEmpty,
    );

    if (!mounted) return;

    if (error != null) {
      setState(() {
        _isSaving = false;
        _error = error;
      });
      return;
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassPanel(
        opacity: 0.18,
        borderRadius: BorderRadius.circular(20),
        padding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(colors: [Color(0xFF6C5CE7), Color(0xFF00B4D8)]),
                      ),
                      child: const Icon(Icons.badge_outlined, color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Личные данные',
                        style: TextStyle(color: context.onSurface, fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Все поля необязательны — оставь пустым, чтобы очистить.',
                  style: TextStyle(color: context.onSurfaceFaded(0.5), fontSize: 12),
                ),
                const SizedBox(height: 18),
                _buildField(_nameController, 'ФИО', Icons.person_outline_rounded, TextInputType.name),
                const SizedBox(height: 10),
                _buildDateField(),
                const SizedBox(height: 10),
                _buildField(_hobbiesController, 'Хобби', Icons.interests_outlined, TextInputType.text, maxLines: 3),
                const SizedBox(height: 20),
                // отдельная секция - на всякий случай, как в медицинских
                // приложениях, визуально отделена от обычной анкеты
                Row(
                  children: [
                    Icon(Icons.emergency_outlined, size: 16, color: context.onSurfaceFaded(0.5)),
                    const SizedBox(width: 6),
                    Text(
                      'НА ВСЯКИЙ СЛУЧАЙ',
                      style: TextStyle(color: context.onSurfaceFaded(0.45), fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.8),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildField(
                  _emergencyContactController,
                  'Экстренный контакт',
                  Icons.phone_forwarded_outlined,
                  TextInputType.text,
                  hint: 'Например: Мама, +7 900 123-45-67',
                ),
                if (_error != null) ...[
                  const SizedBox(height: 10),
                  Text(_error!, style: const TextStyle(color: Color(0xFFFFB4B4), fontSize: 12.5)),
                ],
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
                      child: Text('Отмена', style: TextStyle(color: context.onSurfaceFaded(0.6))),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: const Color(0xFF6C5CE7)),
                      onPressed: _isSaving ? null : _save,
                      child: _isSaving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Сохранить'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label,
    IconData icon,
    TextInputType type, {
    int maxLines = 1,
    String? hint,
  }) {
    return TextField(
      controller: controller,
      keyboardType: type,
      maxLines: maxLines,
      style: TextStyle(color: context.onSurface),
      decoration: InputDecoration(
        filled: true,
        fillColor: context.onSurfaceFaded(0.08),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        prefixIcon: Icon(icon, size: 19, color: context.onSurfaceFaded(0.4)),
        labelText: label,
        labelStyle: TextStyle(color: context.onSurfaceFaded(0.5)),
        hintText: hint,
        hintStyle: TextStyle(color: context.onSurfaceFaded(0.3), fontSize: 12.5),
      ),
    );
  }

  // визуально повторяет обычное текстовое поле (та же заливка, отступы,
  // радиус), но по тапу открывает календарь - выбрать дату рождения из
  // календаря быстрее и надёжнее, чем печатать её вручную, и полностью
  // исключает опечатки формата
  Widget _buildDateField() {
    final label = _birthDate == null ? 'Дата рождения' : DateFormat('d MMMM yyyy', 'ru').format(_birthDate!);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: _pickBirthDate,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: context.onSurfaceFaded(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(Icons.cake_outlined, size: 19, color: context.onSurfaceFaded(0.4)),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(color: _birthDate == null ? context.onSurfaceFaded(0.5) : context.onSurface, fontSize: 14.5),
              ),
              const Spacer(),
              if (_birthDate != null)
                InkWell(
                  onTap: () => setState(() => _birthDate = null),
                  child: Icon(Icons.close_rounded, size: 17, color: context.onSurfaceFaded(0.4)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  final Future<void> Function() onTap;
  const _LogoutButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: context.onSurfaceFaded(0.16)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout_rounded, size: 18, color: context.onSurfaceFaded(0.8)),
              const SizedBox(width: 8),
              Text('Выйти', style: TextStyle(color: context.onSurfaceFaded(0.85), fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}

class _PasswordChangeDialog extends StatefulWidget {
  final AuthStore authStore;
  const _PasswordChangeDialog({required this.authStore});

  @override
  State<_PasswordChangeDialog> createState() => _PasswordChangeDialogState();
}

class _PasswordChangeDialogState extends State<_PasswordChangeDialog> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _isSaving = false;
  String? _error;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final current = _currentController.text;
    final newPassword = _newController.text;
    final confirm = _confirmController.text;

    if (newPassword.length < 8) {
      setState(() => _error = 'Новый пароль должен быть не короче 8 символов.');
      return;
    }
    if (newPassword != confirm) {
      setState(() => _error = 'Пароли не совпадают.');
      return;
    }

    setState(() {
      _isSaving = true;
      _error = null;
    });

    final error = await widget.authStore.changePassword(currentPassword: current, newPassword: newPassword);
    if (!mounted) return;

    if (error != null) {
      setState(() {
        _isSaving = false;
        _error = error;
      });
      return;
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassPanel(
        opacity: 0.18,
        borderRadius: BorderRadius.circular(20),
        padding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Изменить пароль', style: TextStyle(color: context.onSurface, fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              TextField(
                controller: _currentController,
                obscureText: _obscureCurrent,
                style: TextStyle(color: context.onSurface),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: context.onSurfaceFaded(0.08),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  labelText: 'Текущий пароль',
                  labelStyle: TextStyle(color: context.onSurfaceFaded(0.5)),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureCurrent ? Icons.visibility_off_rounded : Icons.visibility_rounded, size: 18, color: context.onSurfaceFaded(0.5)),
                    onPressed: () => setState(() => _obscureCurrent = !_obscureCurrent),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _newController,
                obscureText: _obscureNew,
                style: TextStyle(color: context.onSurface),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: context.onSurfaceFaded(0.08),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  labelText: 'Новый пароль',
                  labelStyle: TextStyle(color: context.onSurfaceFaded(0.5)),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureNew ? Icons.visibility_off_rounded : Icons.visibility_rounded, size: 18, color: context.onSurfaceFaded(0.5)),
                    onPressed: () => setState(() => _obscureNew = !_obscureNew),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _confirmController,
                obscureText: _obscureNew,
                style: TextStyle(color: context.onSurface),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: context.onSurfaceFaded(0.08),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  labelText: 'Повтори новый пароль',
                  labelStyle: TextStyle(color: context.onSurfaceFaded(0.5)),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(_error!, style: const TextStyle(color: Color(0xFFFFB4B4), fontSize: 12.5)),
              ],
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
                    child: Text('Отмена', style: TextStyle(color: context.onSurfaceFaded(0.6))),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: const Color(0xFF6C5CE7)),
                    onPressed: _isSaving ? null : _save,
                    child: _isSaving
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Сохранить'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Смена почты в два экрана в одном диалоге - сначала новый адрес и
/// пароль (запрашивает код), потом сам код (применяет смену). Тот же
/// принцип "не менять молча", что и на бэкенде - см. комментарий там.
class _EmailChangeDialog extends StatefulWidget {
  final AuthStore authStore;
  final String currentEmail;
  const _EmailChangeDialog({required this.authStore, required this.currentEmail});

  @override
  State<_EmailChangeDialog> createState() => _EmailChangeDialogState();
}

enum _EmailChangeStage { enterNewEmail, enterCode }

class _EmailChangeDialogState extends State<_EmailChangeDialog> {
  final _newEmailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _codeController = TextEditingController();
  _EmailChangeStage _stage = _EmailChangeStage.enterNewEmail;
  bool _isSaving = false;
  String? _error;

  @override
  void dispose() {
    _newEmailController.dispose();
    _passwordController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _requestChange() async {
    final newEmail = _newEmailController.text.trim();
    final password = _passwordController.text;
    if (newEmail.isEmpty || password.isEmpty) return;

    setState(() {
      _isSaving = true;
      _error = null;
    });

    final error = await widget.authStore.requestEmailChange(newEmail: newEmail, currentPassword: password);
    if (!mounted) return;

    if (error != null) {
      setState(() {
        _isSaving = false;
        _error = error;
      });
      return;
    }

    setState(() {
      _isSaving = false;
      _stage = _EmailChangeStage.enterCode;
    });
  }

  Future<void> _confirmChange() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;

    setState(() {
      _isSaving = true;
      _error = null;
    });

    final error = await widget.authStore.confirmEmailChange(changeToken: code);
    if (!mounted) return;

    if (error != null) {
      setState(() {
        _isSaving = false;
        _error = error;
      });
      return;
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassPanel(
        opacity: 0.18,
        borderRadius: BorderRadius.circular(20),
        padding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Изменить почту', style: TextStyle(color: context.onSurface, fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text('Сейчас: ${widget.currentEmail}', style: TextStyle(color: context.onSurfaceFaded(0.5), fontSize: 12)),
              const SizedBox(height: 16),
              if (_stage == _EmailChangeStage.enterNewEmail) ...[
                TextField(
                  controller: _newEmailController,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(color: context.onSurface),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: context.onSurfaceFaded(0.08),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    labelText: 'Новый адрес',
                    labelStyle: TextStyle(color: context.onSurfaceFaded(0.5)),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  style: TextStyle(color: context.onSurface),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: context.onSurfaceFaded(0.08),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    labelText: 'Текущий пароль',
                    labelStyle: TextStyle(color: context.onSurfaceFaded(0.5)),
                  ),
                ),
              ] else ...[
                Text(
                  'Код отправлен на ${_newEmailController.text.trim()}. Введи его ниже, чтобы завершить смену.',
                  style: TextStyle(color: context.onSurfaceFaded(0.6), fontSize: 12.5, height: 1.4),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _codeController,
                  style: TextStyle(color: context.onSurface),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: context.onSurfaceFaded(0.08),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    labelText: 'Код из письма',
                    labelStyle: TextStyle(color: context.onSurfaceFaded(0.5)),
                  ),
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(_error!, style: const TextStyle(color: Color(0xFFFFB4B4), fontSize: 12.5)),
              ],
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
                    child: Text('Отмена', style: TextStyle(color: context.onSurfaceFaded(0.6))),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: const Color(0xFF6C5CE7)),
                    onPressed: _isSaving ? null : (_stage == _EmailChangeStage.enterNewEmail ? _requestChange : _confirmChange),
                    child: _isSaving
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(_stage == _EmailChangeStage.enterNewEmail ? 'Отправить код' : 'Подтвердить'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
