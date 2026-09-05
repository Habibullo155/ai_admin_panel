import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/rag_document.dart';
import '../services/documents_service.dart';
import '../state/auth_store.dart';
import '../theme/app_text_color.dart';
import '../widgets/app_background.dart';
import '../widgets/glass_panel.dart';

class AdminDocumentsScreen extends StatefulWidget {
  final AuthStore authStore;
  final VoidCallback? onBack;
  const AdminDocumentsScreen({super.key, required this.authStore, this.onBack});

  @override
  State<AdminDocumentsScreen> createState() => _AdminDocumentsScreenState();
}

class _AdminDocumentsScreenState extends State<AdminDocumentsScreen> {
  final _service = DocumentsService();
  List<RagDocument> _documents = [];
  bool _isLoading = true;
  bool _isUploading = false;
  // null, пока не начали — 1.0 значит "байты все ушли по сети", дальше
  // сервер ещё какое-то время разбирает PDF и считает эмбеддинги (это
  // уже без пошагового прогресса, см. _buildUploadButton).
  double? _uploadProgress;
  String? _error;

  // Сохраняем последний выбранный файл — если загрузка большой книги
  // сорвалась (сеть, таймаут), можно попробовать снова СРАЗУ, не
  // открывая заново системный диалог выбора файла.
  Uint8List? _lastPickedBytes;
  String? _lastPickedName;

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
      final docs = await _service.list(baseUrl: widget.authStore.baseUrl, token: token);
      if (!mounted) return;
      setState(() => _documents = docs);
    } on DocumentsException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickAndUpload() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true, // байты сразу в памяти — одинаково работает и в вебе
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.single;
    final bytes = file.bytes;
    if (bytes == null) {
      setState(() => _error = 'Не удалось прочитать файл.');
      return;
    }
    _lastPickedBytes = bytes;
    _lastPickedName = file.name;
    await _uploadBytes(bytes, file.name);
  }

  /// Повторяет отправку УЖЕ выбранного файла — не открывает системный
  /// диалог заново. Полезно, если загрузка большой книги сорвалась на
  /// таймауте или сети: не нужно повторно искать файл на диске.
  Future<void> _retryUpload() async {
    final bytes = _lastPickedBytes;
    final name = _lastPickedName;
    if (bytes == null || name == null) return;
    await _uploadBytes(bytes, name);
  }

  Future<void> _uploadBytes(Uint8List bytes, String filename) async {
    final token = widget.authStore.token;
    if (token == null) return;

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
      _error = null;
    });
    try {
      final doc = await _service.upload(
        baseUrl: widget.authStore.baseUrl,
        token: token,
        filename: filename,
        bytes: bytes,
        onProgress: (progress) {
          if (mounted) setState(() => _uploadProgress = progress);
        },
      );
      if (!mounted) return;
      setState(() {
        _documents = [doc, ..._documents];
        // Успех — больше нечего повторять.
        _lastPickedBytes = null;
        _lastPickedName = null;
      });
    } on DocumentsException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _uploadProgress = null;
        });
      }
    }
  }

  Future<void> _delete(RagDocument doc) async {
    final token = widget.authStore.token;
    if (token == null) return;
    try {
      await _service.delete(baseUrl: widget.authStore.baseUrl, token: token, documentId: doc.id);
      if (!mounted) return;
      setState(() => _documents.removeWhere((d) => d.id == doc.id));
    } on DocumentsException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
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
                        'Обучение на документах (RAG)',
                        style: TextStyle(color: context.onSurface, fontSize: 17, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: RefreshIndicator(
                      onRefresh: _load,
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          _buildIntro(),
                          const SizedBox(height: 16),
                          _buildUploadButton(),
                          if (_error != null) ...[
                            const SizedBox(height: 12),
                            Text(_error!, style: const TextStyle(color: Color(0xFFFFB4B4), fontSize: 13)),
                            if (_lastPickedBytes != null && !_isUploading) ...[
                              const SizedBox(height: 8),
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(10),
                                  onTap: _retryUpload,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.refresh_rounded, size: 16, color: Color(0xFF00D9C0)),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Повторить загрузку «${_lastPickedName ?? ''}»',
                                        style: const TextStyle(color: Color(0xFF00D9C0), fontSize: 13, fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ],
                          const SizedBox(height: 20),
                          if (_isLoading)
                            const Center(child: CircularProgressIndicator(color: Color(0xFF6C5CE7)))
                          else if (_documents.isEmpty)
                            _buildEmptyState()
                          else
                            ..._documents.map(_buildDocTile),
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

  Widget _buildIntro() {
    return GlassPanel(
      opacity: 0.08,
      borderRadius: BorderRadius.circular(20),
      padding: const EdgeInsets.all(16),
      child: Text(
        'Загрузи PDF — сервер сам разобьёт его на смысловые разделы и '
        'посчитает эмбеддинги. При ответах модель будет автоматически '
        'подмешивать релевантные куски из загруженных документов, если '
        'вопрос пользователя с ними связан.',
        style: TextStyle(color: context.onSurfaceFaded(0.65), fontSize: 13, height: 1.5),
      ),
    );
  }

  Widget _buildUploadButton() {
    final progress = _uploadProgress;
    final isSendingBytes = _isUploading && progress != null && progress < 1.0;
    final isProcessingOnServer = _isUploading && (progress == null || progress >= 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: _isUploading ? null : _pickAndUpload,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: _isUploading
                      ? [context.onSurfaceFaded(0.24), context.onSurfaceFaded(0.10)]
                      : [const Color(0xFF6C5CE7), const Color(0xFF00B4D8)],
                ),
              ),
              child: isSendingBytes
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                            value: progress,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text('Загружаю: ${(progress * 100).round()}%', style: const TextStyle(color: Colors.white)),
                      ],
                    )
                  : isProcessingOnServer
                      ? const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            ),
                            SizedBox(width: 10),
                            // Байты уже все ушли — здесь уже нельзя
                            // показать процент, сервер разбирает PDF и
                            // считает эмбеддинги без пошагового статуса.
                            Text('Обрабатываю PDF, считаю эмбеддинги…', style: TextStyle(color: Colors.white)),
                          ],
                        )
                      : const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.upload_file_rounded, color: Colors.white, size: 20),
                            SizedBox(width: 10),
                            Text('Загрузить PDF', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                          ],
                        ),
            ),
          ),
        ),
        if (isSendingBytes) ...[
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: context.onSurfaceFaded(0.1),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF00D9C0)),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Text(
          'Документов пока нет',
          style: TextStyle(color: context.onSurfaceFaded(0.4)),
        ),
      ),
    );
  }

  Widget _buildDocTile(RagDocument doc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassPanel(
        opacity: 0.08,
        blurred: false, // рендерится по одному на документ в списке
        borderRadius: BorderRadius.circular(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(Icons.picture_as_pdf_rounded, color: context.onSurfaceFaded(0.6)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doc.filename,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: context.onSurface, fontWeight: FontWeight.w500, fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${doc.chunkCount} разделов · ${DateFormat.yMMMd().format(doc.createdAt)}',
                    style: TextStyle(color: context.onSurfaceFaded(0.4), fontSize: 12),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline_rounded, color: context.onSurfaceFaded(0.5), size: 20),
              onPressed: () => _delete(doc),
            ),
          ],
        ),
      ),
    );
  }
}
