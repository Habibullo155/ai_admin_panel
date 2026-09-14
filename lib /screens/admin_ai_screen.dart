import 'package:flutter/material.dart';

import '../services/app_settings_service.dart';
import '../state/auth_store.dart';
import '../theme/app_text_color.dart';
import '../widgets/app_background.dart';
import '../widgets/glass_panel.dart';

/// Имя ассистента и дополнительные инструкции ("о чём и как ему отвечать") —
/// admin-only, влияет на все разговоры сразу. Намеренно НЕ может отключить
/// или заменить встроенные правила безопасности (см. main.py) — это
/// добавка поверх обычного тона, не замена защиты.
class AdminAiScreen extends StatefulWidget {
  final AuthStore authStore;
  final VoidCallback? onBack;
  const AdminAiScreen({super.key, required this.authStore, this.onBack});

  @override
  State<AdminAiScreen> createState() => _AdminAiScreenState();
}

class _AdminAiScreenState extends State<AdminAiScreen> {
  final _service = AppSettingsService();
  final _nameController = TextEditingController();
  final _promptController = TextEditingController();
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isResetting = false;
  String? _error;
  String? _savedNotice;

  // скорость/тон ответа - отдельный раздел, отдельный сброс на бэкенде
  double _temperature = 1.0;
  double _topP = 0.95;
  ResponseLength _responseLength = ResponseLength.balanced;
  bool _themeControlEnabled = true;
  bool _isSavingModel = false;
  bool _isResettingModel = false;
  String? _modelError;
  String? _modelSavedNotice;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _service.dispose();
    _nameController.dispose();
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final token = widget.authStore.token;
    if (token == null) return;
    setState(() => _isLoading = true);
    try {
      final persona = await _service.getPersonaSettings(baseUrl: widget.authStore.baseUrl, token: token);
      final model = await _service.getModelSettings(baseUrl: widget.authStore.baseUrl, token: token);
      if (!mounted) return;
      _nameController.text = persona.assistantName;
      _promptController.text = persona.assistantCustomPrompt;
      setState(() {
        _temperature = model.temperature;
        _topP = model.topP;
        _responseLength = model.responseLength;
        _themeControlEnabled = model.themeControlEnabled;
      });
    } on AppSettingsException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveModel() async {
    final token = widget.authStore.token;
    if (token == null) return;
    setState(() {
      _isSavingModel = true;
      _modelError = null;
      _modelSavedNotice = null;
    });
    try {
      await _service.updateModelSettings(
        baseUrl: widget.authStore.baseUrl,
        token: token,
        temperature: _temperature,
        topP: _topP,
        responseLength: _responseLength,
        themeControlEnabled: _themeControlEnabled,
      );
      if (mounted) setState(() => _modelSavedNotice = 'Сохранено');
    } on AppSettingsException catch (e) {
      if (mounted) setState(() => _modelError = e.message);
    } finally {
      if (mounted) setState(() => _isSavingModel = false);
    }
  }

  Future<void> _resetModel() async {
    final token = widget.authStore.token;
    if (token == null) return;
    setState(() {
      _isResettingModel = true;
      _modelError = null;
      _modelSavedNotice = null;
    });
    try {
      final reset = await _service.resetModelSettings(baseUrl: widget.authStore.baseUrl, token: token);
      if (mounted) {
        setState(() {
          _temperature = reset.temperature;
          _topP = reset.topP;
          _responseLength = reset.responseLength;
          _themeControlEnabled = reset.themeControlEnabled;
        });
      }
    } on AppSettingsException catch (e) {
      if (mounted) setState(() => _modelError = e.message);
    } finally {
      if (mounted) setState(() => _isResettingModel = false);
    }
  }

  Future<void> _save() async {
    final token = widget.authStore.token;
    if (token == null) return;
    setState(() {
      _isSaving = true;
      _error = null;
      _savedNotice = null;
    });
    try {
      await _service.updatePersonaSettings(
        baseUrl: widget.authStore.baseUrl,
        token: token,
        assistantName: _nameController.text.trim(),
        assistantCustomPrompt: _promptController.text.trim(),
      );
      if (mounted) setState(() => _savedNotice = 'Сохранено');
    } on AppSettingsException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _confirmReset() async {
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
                  'Сбросить имя и инструкции ИИ?',
                  style: TextStyle(color: context.onSurface, fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ассистент вернётся к обычному поведению без имени и '
                  'дополнительных инструкций.',
                  style: TextStyle(color: context.onSurfaceFaded(0.6), fontSize: 13, height: 1.5),
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
                      child: const Text('Сбросить'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (confirmed != true || !mounted) return;

    final token = widget.authStore.token;
    if (token == null) return;
    setState(() {
      _isResetting = true;
      _error = null;
      _savedNotice = null;
    });
    try {
      final reset = await _service.resetPersonaSettings(baseUrl: widget.authStore.baseUrl, token: token);
      if (mounted) {
        _nameController.text = reset.assistantName;
        _promptController.text = reset.assistantCustomPrompt;
      }
    } on AppSettingsException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isResetting = false);
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
                    Text(
                      'Поведение ИИ',
                      style: TextStyle(color: context.onSurface, fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Color(0xFF6C5CE7))
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 560),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (_error != null) ...[
                                  Text(_error!, style: const TextStyle(color: Color(0xFFFFB4B4), fontSize: 13)),
                                  const SizedBox(height: 12),
                                ],
                                GlassPanel(
                                  opacity: 0.08,
                                  borderRadius: BorderRadius.circular(16),
                                  padding: const EdgeInsets.all(14),
                                  child: Row(
                                    children: [
                                      Icon(Icons.shield_outlined, color: context.onSurfaceFaded(0.6), size: 18),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          'Встроенные правила безопасности и поддерживающий тон '
                                          'нельзя отключить или переопределить отсюда — то, что '
                                          'ты задашь ниже, добавляется поверх них, не вместо.',
                                          style: TextStyle(color: context.onSurfaceFaded(0.55), fontSize: 12, height: 1.4),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  'ИМЯ АССИСТЕНТА',
                                  style: TextStyle(color: context.onSurfaceFaded(0.4), fontSize: 11, letterSpacing: 1.2, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _nameController,
                                  style: TextStyle(color: context.onSurface),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: context.onSurfaceFaded(0.07),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                    hintText: 'Например: Люмен (необязательно)',
                                    hintStyle: TextStyle(color: context.onSurfaceFaded(0.3)),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  'ДОПОЛНИТЕЛЬНЫЕ ИНСТРУКЦИИ',
                                  style: TextStyle(color: context.onSurfaceFaded(0.4), fontSize: 11, letterSpacing: 1.2, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Чем должен заниматься ассистент, какого стиля держаться — добавляется к каждому разговору.',
                                  style: TextStyle(color: context.onSurfaceFaded(0.4), fontSize: 11.5),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _promptController,
                                  maxLines: 6,
                                  style: TextStyle(color: context.onSurface, fontSize: 13.5),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: context.onSurfaceFaded(0.07),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                    contentPadding: const EdgeInsets.all(14),
                                    hintText: 'Например: специализируешься на поддержке в учёбе, объясняй просто и с примерами.',
                                    hintStyle: TextStyle(color: context.onSurfaceFaded(0.3)),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(14),
                                          onTap: _isSaving ? null : _save,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(vertical: 13),
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(14),
                                              gradient: const LinearGradient(colors: [Color(0xFF6C5CE7), Color(0xFF00B4D8)]),
                                            ),
                                            child: _isSaving
                                                ? const SizedBox(
                                                    width: 18,
                                                    height: 18,
                                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                                  )
                                                : const Text('Сохранить', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (_savedNotice != null) ...[
                                  const SizedBox(height: 8),
                                  Text(_savedNotice!, style: const TextStyle(color: Color(0xFF00E6A0), fontSize: 12.5)),
                                ],
                                const SizedBox(height: 20),
                                OutlinedButton.icon(
                                  onPressed: _isResetting ? null : _confirmReset,
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: context.onSurfaceFaded(0.16)),
                                    padding: const EdgeInsets.symmetric(vertical: 13),
                                    foregroundColor: Colors.white70,
                                  ),
                                  icon: _isResetting
                                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70))
                                      : const Icon(Icons.restart_alt_rounded, size: 18),
                                  label: const Text('Сбросить'),
                                ),
                                const SizedBox(height: 32),
                                _buildModelSection(),
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

  // "точность" читается человеку понятнее, чем сырое число температуры -
  // подписи и цвет плавно меняются при движении слайдера (AnimatedSwitcher/
  // AnimatedContainer), не мгновенным скачком
  String _temperatureLabel(double t) {
    if (t < 0.5) return 'Точный и предсказуемый';
    if (t < 1.3) return 'Сбалансированный';
    return 'Творческий и разнообразный';
  }

  Color _temperatureColor(double t) {
    if (t < 0.5) return const Color(0xFF00B4D8);
    if (t < 1.3) return const Color(0xFF6C5CE7);
    return const Color(0xFFFF6B9D);
  }

  Widget _buildModelSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'СКОРОСТЬ И ТОН ОТВЕТА',
          style: TextStyle(color: context.onSurfaceFaded(0.4), fontSize: 11, letterSpacing: 1.2, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          'Насколько предсказуемо или творчески отвечает модель, и как подробно.',
          style: TextStyle(color: context.onSurfaceFaded(0.4), fontSize: 11.5),
        ),
        const SizedBox(height: 16),
        if (_modelError != null) ...[
          Text(_modelError!, style: const TextStyle(color: Color(0xFFFFB4B4), fontSize: 13)),
          const SizedBox(height: 12),
        ],
        GlassPanel(
          opacity: 0.08,
          borderRadius: BorderRadius.circular(16),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: _temperatureColor(_temperature)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        _temperatureLabel(_temperature),
                        key: ValueKey(_temperatureLabel(_temperature)),
                        style: TextStyle(color: context.onSurface, fontSize: 13.5, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  Text(_temperature.toStringAsFixed(2), style: TextStyle(color: context.onSurfaceFaded(0.4), fontSize: 12)),
                ],
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: _temperatureColor(_temperature),
                  thumbColor: _temperatureColor(_temperature),
                  overlayColor: _temperatureColor(_temperature).withValues(alpha: 0.2),
                  inactiveTrackColor: context.onSurfaceFaded(0.12),
                ),
                child: Slider(
                  value: _temperature,
                  min: 0,
                  max: 2,
                  divisions: 40,
                  onChanged: (v) => setState(() => _temperature = v),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.filter_alt_outlined, color: context.onSurfaceFaded(0.5), size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('Фокус ответа (top_p)', style: TextStyle(color: context.onSurface, fontSize: 13)),
                  ),
                  Text(_topP.toStringAsFixed(2), style: TextStyle(color: context.onSurfaceFaded(0.4), fontSize: 12)),
                ],
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: const Color(0xFF00E6A0),
                  thumbColor: const Color(0xFF00E6A0),
                  overlayColor: const Color(0xFF00E6A0).withValues(alpha: 0.2),
                  inactiveTrackColor: context.onSurfaceFaded(0.12),
                ),
                child: Slider(
                  value: _topP,
                  min: 0,
                  max: 1,
                  divisions: 20,
                  onChanged: (v) => setState(() => _topP = v),
                ),
              ),
              const SizedBox(height: 12),
              Text('Длина ответа', style: TextStyle(color: context.onSurface, fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: [
                  _lengthChip(ResponseLength.concise, 'Кратко', Icons.short_text_rounded),
                  _lengthChip(ResponseLength.balanced, 'Обычно', Icons.notes_rounded),
                  _lengthChip(ResponseLength.detailed, 'Подробно', Icons.article_outlined),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.palette_outlined, color: context.onSurfaceFaded(0.5), size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Смена темы по просьбе в чате', style: TextStyle(color: context.onSurface, fontSize: 13)),
                        Text(
                          'ИИ сможет менять цвет фона приложения, если пользователь попросит',
                          style: TextStyle(color: context.onSurfaceFaded(0.4), fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _themeControlEnabled,
                    onChanged: (v) => setState(() => _themeControlEnabled = v),
                    activeThumbColor: const Color(0xFF6C5CE7),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: _isSavingModel ? null : _saveModel,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: LinearGradient(colors: [_temperatureColor(_temperature), const Color(0xFF00E6A0)]),
                    ),
                    child: _isSavingModel
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Сохранить', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (_modelSavedNotice != null) ...[
          const SizedBox(height: 8),
          Text(_modelSavedNotice!, style: const TextStyle(color: Color(0xFF00E6A0), fontSize: 12.5)),
        ],
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _isResettingModel ? null : _resetModel,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: context.onSurfaceFaded(0.16)),
            padding: const EdgeInsets.symmetric(vertical: 13),
            foregroundColor: Colors.white70,
          ),
          icon: _isResettingModel
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70))
              : const Icon(Icons.restart_alt_rounded, size: 18),
          label: const Text('Сбросить'),
        ),
      ],
    );
  }

  Widget _lengthChip(ResponseLength value, String label, IconData icon) {
    final selected = _responseLength == value;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: ChoiceChip(
        avatar: Icon(icon, size: 16, color: selected ? Colors.white : context.onSurfaceFaded(0.6)),
        label: Text(label),
        selected: selected,
        onSelected: (_) => setState(() => _responseLength = value),
        labelStyle: TextStyle(color: selected ? Colors.white : context.onSurfaceFaded(0.7), fontSize: 12.5),
        selectedColor: const Color(0xFF6C5CE7),
        backgroundColor: context.onSurfaceFaded(0.06),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: context.onSurfaceFaded(0.12)),
        ),
      ),
    );
  }
}
