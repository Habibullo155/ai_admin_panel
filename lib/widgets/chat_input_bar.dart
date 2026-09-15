import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../state/voice_store.dart';
import '../theme/app_text_color.dart';
import 'glass_panel.dart';

class ChatInputBar extends StatefulWidget {
  final bool enabled;
  final void Function(String text, {List<String>? images}) onSend;
  final VoiceStore? voiceStore;
  final VoidCallback? onQuickStart;

  const ChatInputBar({super.key, required this.enabled, required this.onSend, this.voiceStore, this.onQuickStart});

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  // Отдельный узел для перехвата Enter — создаём один раз, а не в build(),
  // иначе на каждой перерисовке плодились бы висячие FocusNode (утечка).
  final _keyboardFocusNode = FocusNode(debugLabel: 'chat-input-keyboard');
  final _picker = ImagePicker();

  // base64 уже выбранных, но ещё не отправленных фото — с превью выше
  // поля ввода, можно убрать перед отправкой
  final List<String> _pickedImages = [];

  Future<void> _pickImage(ImageSource source) async {
    // сжимаем сразу при выборе (не после) — иначе несжатое фото с камеры
    // в несколько МБ раздувало бы локальную историю чата на каждое
    // отправленное фото. 1280px и качество 70 — разумный компромисс:
    // модели достаточно этого разрешения, чтобы разобрать содержимое.
    final file = await _picker.pickImage(
      source: source,
      maxWidth: 1280,
      maxHeight: 1280,
      imageQuality: 70,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    if (!mounted) return;
    setState(() => _pickedImages.add(base64Encode(bytes)));
  }

  Future<void> _showImageSourceSheet() async {
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
            ],
          ),
        ),
      ),
    );
    if (source != null) await _pickImage(source);
  }

  void _submit() {
    final text = _controller.text.trim();
    if ((text.isEmpty && _pickedImages.isEmpty) || !widget.enabled) return;
    HapticFeedback.lightImpact();
    widget.onSend(text, images: _pickedImages.isEmpty ? null : List.of(_pickedImages));
    _controller.clear();
    setState(() => _pickedImages.clear());
    _focusNode.requestFocus();
  }

  Future<void> _toggleListening() async {
    final voice = widget.voiceStore;
    if (voice == null) return;
    if (voice.isListening) {
      await voice.stopListening();
      return;
    }
    HapticFeedback.lightImpact();
    await voice.startListening(
      onResult: (text) {
        _controller.text = text;
        _controller.selection = TextSelection.collapsed(offset: text.length);
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final voice = widget.voiceStore;
    final showMic = voice != null && voice.isVoiceAvailable && voice.isSttAvailable;

    return GlassPanel(
      opacity: 0.12,
      borderRadius: BorderRadius.circular(28),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_pickedImages.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6, bottom: 2),
              child: SizedBox(
                height: 56,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _pickedImages.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 6),
                  itemBuilder: (context, i) => Stack(
                    clipBehavior: Clip.none,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.memory(base64Decode(_pickedImages[i]), width: 56, height: 56, fit: BoxFit.cover),
                      ),
                      Positioned(
                        top: -6,
                        right: -6,
                        child: GestureDetector(
                          onTap: () => setState(() => _pickedImages.removeAt(i)),
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFFF6B6B)),
                            child: const Icon(Icons.close_rounded, color: Colors.white, size: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Row(
            children: [
              if (widget.onQuickStart != null) ...[
                _QuickStartButton(onTap: widget.onQuickStart!),
                const SizedBox(width: 6),
              ],
              _AttachButton(onTap: widget.enabled ? _showImageSourceSheet : null),
              const SizedBox(width: 6),
              Expanded(
            child: KeyboardListener(
              focusNode: _keyboardFocusNode,
              onKeyEvent: (event) {
                if (event is KeyDownEvent &&
                    event.logicalKey == LogicalKeyboardKey.enter &&
                    !HardwareKeyboard.instance.isShiftPressed) {
                  _submit();
                }
              },
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                enabled: widget.enabled,
                minLines: 1,
                maxLines: 6,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _submit(),
                style: TextStyle(color: context.onSurface, fontSize: 15),
                cursorColor: const Color(0xFF00D9C0),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: widget.enabled
                      ? 'Напиши сообщение…'
                      : 'Ожидание ответа модели…',
                  hintStyle: TextStyle(color: context.onSurfaceFaded(0.4)),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                ),
              ),
            ),
          ),
          if (showMic) ...[
            AnimatedBuilder(
              animation: voice,
              builder: (context, _) => _MicButton(
                isListening: voice.isListening,
                enabled: widget.enabled,
                onTap: _toggleListening,
              ),
            ),
            const SizedBox(width: 6),
          ],
          _SendButton(enabled: widget.enabled, onTap: _submit),
        ],
      ),
        ],
      ),
    );
  }
}

class _AttachButton extends StatelessWidget {
  final VoidCallback? onTap;
  const _AttachButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: context.onSurfaceFaded(0.06),
          ),
          child: Icon(Icons.add_photo_alternate_outlined, color: context.onSurfaceFaded(0.7), size: 20),
        ),
      ),
    );
  }
}

class _QuickStartButton extends StatelessWidget {
  final VoidCallback onTap;
  const _QuickStartButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: context.onSurfaceFaded(0.06),
          ),
          child: Icon(Icons.forum_outlined, color: context.onSurfaceFaded(0.7), size: 20),
        ),
      ),
    );
  }
}

class _MicButton extends StatelessWidget {
  final bool isListening;
  final bool enabled;
  final VoidCallback onTap;
  const _MicButton({required this.isListening, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: enabled ? onTap : null,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isListening ? const Color(0xFFFF6B6B).withOpacity(0.25) : context.onSurfaceFaded(0.06),
          ),
          child: Icon(
            isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
            color: isListening ? const Color(0xFFFF6B6B) : context.onSurfaceFaded(0.7),
            size: 20,
          ),
        ),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onTap;
  const _SendButton({required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: enabled ? onTap : null,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: enabled
                  ? [const Color(0xFF6C5CE7), const Color(0xFF00D9C0)]
                  : [context.onSurfaceFaded(0.24), context.onSurfaceFaded(0.10)],
            ),
          ),
          child: Icon(
            enabled ? Icons.arrow_upward_rounded : Icons.hourglass_top_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }
}
