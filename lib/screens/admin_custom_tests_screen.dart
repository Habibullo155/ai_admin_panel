import 'package:flutter/material.dart';

import '../models/custom_test.dart';
import '../services/custom_tests_service.dart';
import '../state/auth_store.dart';
import '../theme/app_text_color.dart';
import '../widgets/app_background.dart';
import '../widgets/glass_panel.dart';
import 'admin_custom_test_editor_screen.dart';

class AdminCustomTestsScreen extends StatefulWidget {
  final AuthStore authStore;
  final VoidCallback? onBack;
  const AdminCustomTestsScreen({super.key, required this.authStore, this.onBack});

  @override
  State<AdminCustomTestsScreen> createState() => _AdminCustomTestsScreenState();
}

class _AdminCustomTestsScreenState extends State<AdminCustomTestsScreen> {
  final _service = CustomTestsService();
  List<CustomTestSummary> _tests = [];
  bool _isLoading = true;
  String? _error;

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
      final tests = await _service.adminList(baseUrl: widget.authStore.baseUrl, token: token);
      if (mounted) setState(() => _tests = tests);
    } on CustomTestsException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _openEditor({int? testId}) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => AdminCustomTestEditorScreen(authStore: widget.authStore, testId: testId)),
    );
    if (saved == true) _load();
  }

  Future<void> _confirmDelete(CustomTestSummary test) async {
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
                  'Удалить тест «${test.title}»?',
                  style: TextStyle(color: context.onSurface, fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text('Действие необратимо.', style: TextStyle(color: context.onSurfaceFaded(0.6), fontSize: 13)),
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
    try {
      await _service.adminDelete(baseUrl: widget.authStore.baseUrl, token: token, testId: test.id);
      _load();
    } on CustomTestsException catch (e) {
      if (mounted) setState(() => _error = e.message);
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
                    Expanded(
                      child: Text(
                        'Свои тесты',
                        style: TextStyle(color: context.onSurface, fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_rounded, color: Color(0xFF00E6A0)),
                      onPressed: () => _openEditor(),
                      tooltip: 'Новый тест',
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Color(0xFF6C5CE7))
                      : RefreshIndicator(
                          onRefresh: _load,
                          child: ListView(
                            padding: const EdgeInsets.all(16),
                            children: [
                              Center(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(maxWidth: 560),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      if (_error != null) ...[
                                        Text(_error!, style: const TextStyle(color: Color(0xFFFFB4B4), fontSize: 13)),
                                        const SizedBox(height: 12),
                                      ],
                                      if (_tests.isEmpty)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 40),
                                          child: Center(
                                            child: Text(
                                              'Тестов пока нет — нажми + сверху, чтобы создать первый.',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(color: context.onSurfaceFaded(0.4)),
                                            ),
                                          ),
                                        )
                                      else
                                        ..._tests.map((t) => Padding(
                                              padding: const EdgeInsets.only(bottom: 10),
                                              child: _TestTile(
                                                test: t,
                                                onTap: () => _openEditor(testId: t.id),
                                                onDelete: () => _confirmDelete(t),
                                              ),
                                            )),
                                    ],
                                  ),
                                ),
                              ),
                            ],
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
}

class _TestTile extends StatelessWidget {
  final CustomTestSummary test;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  const _TestTile({required this.test, required this.onTap, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: GlassPanel(
          opacity: 0.08,
          borderRadius: BorderRadius.circular(16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: test.isPublished ? const Color(0xFF00E6A0) : context.onSurfaceFaded(0.3),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      test.title,
                      style: TextStyle(color: context.onSurface, fontSize: 14.5, fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${test.isPublished ? "Опубликован" : "Черновик"} · ${test.questionCount} вопрос(ов)',
                      style: TextStyle(color: context.onSurfaceFaded(0.4), fontSize: 11.5),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete_outline_rounded, color: context.onSurfaceFaded(0.4), size: 20),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
