import 'package:flutter/material.dart';

import '../models/custom_test.dart';
import '../services/custom_tests_service.dart';
import '../state/auth_store.dart';
import '../theme/app_text_color.dart';
import '../widgets/app_background.dart';
import '../widgets/glass_panel.dart';
import 'custom_test_taking_screen.dart';

class CustomTestListScreen extends StatefulWidget {
  final AuthStore authStore;
  final Future<void> Function(String summary)? onDiscussWithAi;
  const CustomTestListScreen({super.key, required this.authStore, this.onDiscussWithAi});

  @override
  State<CustomTestListScreen> createState() => _CustomTestListScreenState();
}

class _CustomTestListScreenState extends State<CustomTestListScreen> {
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
      final tests = await _service.list(baseUrl: widget.authStore.baseUrl, token: token);
      if (mounted) setState(() => _tests = tests);
    } on CustomTestsException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
                    Text(
                      'Тесты',
                      style: TextStyle(color: context.onSurface, fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: RefreshIndicator(
                    onRefresh: _load,
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator(color: Color(0xFF6C5CE7)))
                        : ListView(
                            padding: const EdgeInsets.all(16),
                            children: [
                              Center(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(maxWidth: 480),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      if (_error != null)
                                        Text(_error!, style: const TextStyle(color: Color(0xFFFFB4B4), fontSize: 13))
                                      else if (_tests.isEmpty)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 40),
                                          child: Center(
                                            child: Text(
                                              'Пока нет доступных тестов.',
                                              style: TextStyle(color: context.onSurfaceFaded(0.4)),
                                            ),
                                          ),
                                        )
                                      else
                                        ..._tests.map((t) => Padding(
                                              padding: const EdgeInsets.only(bottom: 10),
                                              child: _TestTile(
                                                test: t,
                                                onTap: () => Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (_) => CustomTestTakingScreen(
                                                      authStore: widget.authStore,
                                                      testId: t.id,
                                                      onDiscussWithAi: widget.onDiscussWithAi,
                                                    ),
                                                  ),
                                                ),
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
  const _TestTile({required this.test, required this.onTap});

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
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(test.title, style: TextStyle(color: context.onSurface, fontSize: 14.5, fontWeight: FontWeight.w600)),
                    if (test.description != null && test.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        test.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: context.onSurfaceFaded(0.5), fontSize: 12),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Text('${test.questionCount} вопрос(ов)', style: TextStyle(color: context.onSurfaceFaded(0.35), fontSize: 11)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: context.onSurfaceFaded(0.3)),
            ],
          ),
        ),
      ),
    );
  }
}
