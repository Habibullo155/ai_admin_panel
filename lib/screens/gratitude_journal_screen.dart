import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../models/gratitude_entry.dart';
import '../services/gratitude_service.dart';
import '../theme/app_text_color.dart';
import '../widgets/app_background.dart';
import '../widgets/glass_panel.dart';

const _uuid = Uuid();

/// "Три вещи, за которые я благодарен(на)" — простая, изученная техника
/// позитивной психологии (Seligman и коллеги, начало 2000-х): регулярная
/// короткая запись небольших благодарностей связана с улучшением
/// субъективного ощущения благополучия в исследованиях. Не диагностика,
/// не терапия — просто привычка, которую легко попробовать. Записи не
/// покидают устройство — тот же принцип, что и у чек-ина самочувствия.
class GratitudeJournalScreen extends StatefulWidget {
  final String userId;
  const GratitudeJournalScreen({super.key, required this.userId});

  @override
  State<GratitudeJournalScreen> createState() => _GratitudeJournalScreenState();
}

class _GratitudeJournalScreenState extends State<GratitudeJournalScreen> {
  final _service = GratitudeService();
  final _controllers = List.generate(3, (_) => TextEditingController());
  List<GratitudeEntry> _entries = [];
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final entries = await _service.loadEntries(widget.userId);
    if (!mounted) return;
    setState(() {
      _entries = entries;
      _isLoading = false;
    });
  }

  Future<void> _save() async {
    final items = _controllers.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList();
    if (items.isEmpty) return;

    setState(() => _isSaving = true);
    final entry = GratitudeEntry(id: _uuid.v4(), date: DateTime.now(), items: items);
    final saved = await _service.addEntry(widget.userId, entry);
    if (!mounted) return;
    setState(() {
      _isSaving = false;
      if (saved != null) {
        _entries = [saved, ..._entries];
        for (final c in _controllers) {
          c.clear();
        }
      }
    });
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
                      'Дневник благодарности',
                      style: TextStyle(color: context.onSurface, fontSize: 17, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          GlassPanel(
                            opacity: 0.08,
                            borderRadius: BorderRadius.circular(20),
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Три вещи, за которые ты сегодня благодарен(на)',
                                  style: TextStyle(color: context.onSurfaceFaded(0.85), fontWeight: FontWeight.w600, fontSize: 14.5),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Не обязательно что-то большое — подойдёт и мелочь.',
                                  style: TextStyle(color: context.onSurfaceFaded(0.4), fontSize: 12),
                                ),
                                const SizedBox(height: 16),
                                for (var i = 0; i < 3; i++) ...[
                                  TextField(
                                    controller: _controllers[i],
                                    style: TextStyle(color: context.onSurface, fontSize: 13.5),
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: context.onSurfaceFaded(0.07),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                      hintText: '${i + 1}.',
                                      hintStyle: TextStyle(color: context.onSurfaceFaded(0.25)),
                                    ),
                                  ),
                                  if (i < 2) const SizedBox(height: 10),
                                ],
                                const SizedBox(height: 16),
                                Material(
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
                              ],
                            ),
                          ),
                          if (_entries.isNotEmpty) ...[
                            const SizedBox(height: 20),
                            Text(
                              'ЗАПИСИ',
                              style: TextStyle(color: context.onSurfaceFaded(0.4), fontSize: 11, letterSpacing: 1.2, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 10),
                            if (_isLoading)
                              const Center(child: CircularProgressIndicator(color: Color(0xFF6C5CE7)))
                            else
                              ..._entries.map(_buildEntryCard),
                          ],
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

  Widget _buildEntryCard(GratitudeEntry entry) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassPanel(
        opacity: 0.07,
        blurred: false, // список из многих записей — см. message_bubble.dart
        borderRadius: BorderRadius.circular(14),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat.yMMMd().add_Hm().format(entry.date),
              style: TextStyle(color: context.onSurfaceFaded(0.35), fontSize: 11),
            ),
            const SizedBox(height: 6),
            ...entry.items.map((item) => Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text('· $item', style: TextStyle(color: context.onSurface, fontSize: 13, height: 1.4)),
                )),
          ],
        ),
      ),
    );
  }
}
