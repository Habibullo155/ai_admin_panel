import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../models/chat_message.dart';
import '../models/chat_source.dart';
import '../state/theme_store.dart';
import '../theme/app_text_color.dart';
import '../theme/background_variant.dart';
import 'animated_ai_avatar.dart';
import 'glass_panel.dart';
import 'theme_variant_swatch.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onDelete;
  final VoidCallback? onReport;
  final VoidCallback? onSpeak;
  final ValueChanged<String>? onEdit;
  final ValueChanged<bool>? onRate;
  final VoidCallback? onRegenerate;
  // true - "да, хочу пройти тест" (открывает выбор теста), false - "нет,
  // просто продолжим разговор" (отправляет обычное сообщение-продолжение)
  final ValueChanged<bool>? onTestPromptResponse;
  // вызывается один раз, когда человек либо выбрал вариант темы (тогда
  // ThemeStore уже обновлён к этому моменту), либо закрыл предложение
  // без выбора - в обоих случаях кнопки под сообщением нужно спрятать
  final VoidCallback? onThemePickerDismissed;
  const MessageBubble({
    super.key,
    required this.message,
    this.onDelete,
    this.onReport,
    this.onSpeak,
    this.onEdit,
    this.onRate,
    this.onRegenerate,
    this.onTestPromptResponse,
    this.onThemePickerDismissed,
  });

  @override
  Widget build(BuildContext context) {
    // остаётся в истории для связности контекста ИИ (см. isHidden в
    // chat_message.dart), но никогда не рисуется пузырём - нулевая высота
    // просто не занимает места в ListView, соседние сообщения не сдвигаются
    if (message.isHidden) return const SizedBox.shrink();

    final isUser = message.role == MessageRole.user;
    final time = DateFormat.Hm().format(message.createdAt);

    final bubble = GlassPanel(
      opacity: isUser ? 0.16 : 0.09,
      tint: isUser ? const Color(0xFF6C5CE7) : null,
      blurred: false, // рендерится по одному на сообщение, BackdropFilter тут дорогой
      borderRadius: BorderRadius.only(
        topLeft: const Radius.circular(20),
        topRight: const Radius.circular(20),
        bottomLeft: Radius.circular(isUser ? 20 : 4),
        bottomRight: Radius.circular(isUser ? 4 : 20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (message.images != null && message.images!.isNotEmpty) ...[
              _AttachedImages(images: message.images!),
              if (message.content.isNotEmpty) const SizedBox(height: 8),
            ],
            if (message.content.isNotEmpty)
              SelectableText(
                message.content,
                style: TextStyle(
                  color: message.isError
                      ? const Color(0xFFFFB4B4)
                      : context.onSurfaceFaded(0.94),
                  fontSize: 15.5,
                  height: 1.45,
                ),
              ),
            if (message.sources != null && message.sources!.isNotEmpty) ...[
              const SizedBox(height: 8),
              _SourcesBlock(sources: message.sources!),
            ],
            if (message.offersTestPrompt && !message.testPromptAnswered && onTestPromptResponse != null) ...[
              const SizedBox(height: 10),
              _TestOfferButtons(onAnswer: onTestPromptResponse!),
            ],
            if (message.offersThemePicker && !message.themePickerAnswered && onThemePickerDismissed != null) ...[
              const SizedBox(height: 10),
              _InlineThemePicker(onDone: onThemePickerDismissed!),
            ],
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time,
                  style: TextStyle(
                    color: context.onSurfaceFaded(0.38),
                    fontSize: 11,
                  ),
                ),
                if (!message.isStreaming) ...[
                  const SizedBox(width: 8),
                  _CopyIconButton(text: message.content),
                  if (onRate != null) ...[
                    const SizedBox(width: 4),
                    _RateIconButton(
                      icon: Icons.thumb_up_outlined,
                      activeIcon: Icons.thumb_up_rounded,
                      active: message.liked == true,
                      onTap: () => onRate!(true),
                    ),
                    const SizedBox(width: 2),
                    _RateIconButton(
                      icon: Icons.thumb_down_outlined,
                      activeIcon: Icons.thumb_down_rounded,
                      active: message.liked == false,
                      onTap: () => onRate!(false),
                    ),
                  ],
                  if (onRegenerate != null) ...[
                    const SizedBox(width: 2),
                    _RateIconButton(
                      icon: Icons.refresh_rounded,
                      activeIcon: Icons.refresh_rounded,
                      active: false,
                      onTap: onRegenerate!,
                    ),
                  ],
                ],
              ],
            ),
          ],
        ),
      ),
    );

    final hasMenu = !message.isStreaming;
    final bubbleWithGestures = !hasMenu
        ? bubble
        : GestureDetector(
            onLongPress: () => _showMessageMenu(context),
            child: bubble,
          );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) _avatar(context, isUser: false),
          if (!isUser) const SizedBox(width: 8),
          Flexible(child: bubbleWithGestures),
          if (isUser) const SizedBox(width: 8),
          if (isUser) _avatar(context, isUser: true),
        ],
      ),
    );
  }

  void _showMessageMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A2036),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        // фон листа всегда тёмный (0xFF1A2036 выше), текст константами
        // белый - от темы приложения не зависит
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onEdit != null)
              ListTile(
                leading: const Icon(Icons.edit_outlined, color: Colors.white70),
                title: const Text('Редактировать и переспросить', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.of(context).pop();
                  _showEditDialog(context);
                },
              ),
            ListTile(
              leading: const Icon(Icons.copy_rounded, color: Colors.white70),
              title: const Text('Скопировать текст', style: TextStyle(color: Colors.white)),
              onTap: () async {
                Navigator.of(context).pop();
                await Clipboard.setData(ClipboardData(text: message.content));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Скопировано'), duration: Duration(seconds: 1)),
                  );
                }
              },
            ),
            if (onSpeak != null)
              ListTile(
                leading: const Icon(Icons.volume_up_rounded, color: Colors.white70),
                title: const Text('Прочитать вслух', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.of(context).pop();
                  onSpeak?.call();
                },
              ),
            if (onReport != null)
              ListTile(
                leading: const Icon(Icons.flag_outlined, color: Color(0xFFFFD166)),
                title: const Text('Пожаловаться на ответ', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.of(context).pop();
                  onReport?.call();
                },
              ),
            if (onDelete != null)
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded, color: Color(0xFFFFB4B4)),
                title: const Text('Удалить сообщение', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.of(context).pop();
                  onDelete?.call();
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditDialog(BuildContext context) async {
    final controller = TextEditingController(text: message.content);
    await showDialog(
      context: context,
      // тот же тёмный лист поверх приложения, что и меню выше
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassPanel(
          tint: const Color(0xFF1A2036),
          opacity: 0.95,
          borderRadius: BorderRadius.circular(20),
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Редактировать сообщение',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Ответ модели на это сообщение и всё, что было после, будет удалено — модель ответит заново на исправленный текст.',
                  style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: controller,
                  autofocus: true,
                  maxLines: 6,
                  minLines: 1,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.08),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Отмена', style: TextStyle(color: Colors.white70)),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: const Color(0xFF6C5CE7)),
                      onPressed: () {
                        final text = controller.text.trim();
                        Navigator.of(context).pop();
                        if (text.isNotEmpty && text != message.content) {
                          onEdit?.call(text);
                        }
                      },
                      child: const Text('Переспросить'),
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

  Widget _avatar(BuildContext context, {required bool isUser}) {
    if (!isUser && message.isStreaming) {
      return AnimatedAiAvatar(isActive: true, size: 34);
    }
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: isUser
              ? [const Color(0xFF6C5CE7), const Color(0xFF00D9C0)]
              : [const Color(0xFF6FB1DE), const Color(0xFF4DD0C4)], // приглушённые сине-зелёные для ассистента
        ),
        border: Border.all(color: Colors.white.withOpacity(0.25)),
      ),
      child: Icon(
        isUser ? Icons.person_rounded : Icons.spa_rounded,
        size: 18,
        color: Colors.white,
      ),
    );
  }
}

class _CopyIconButton extends StatelessWidget {
  final String text;
  const _CopyIconButton({required this.text});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () async {
          await Clipboard.setData(ClipboardData(text: text));
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Скопировано'), duration: Duration(seconds: 1)),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Icon(Icons.copy_rounded, size: 13, color: context.onSurfaceFaded(0.38)),
        ),
      ),
    );
  }
}

class _RateIconButton extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final bool active;
  final VoidCallback onTap;
  const _RateIconButton({
    required this.icon,
    required this.activeIcon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Icon(
            active ? activeIcon : icon,
            size: 13,
            color: active ? const Color(0xFF6C5CE7) : context.onSurfaceFaded(0.38),
          ),
        ),
      ),
    );
  }
}

// видно только когда сервер прислал источники, а он делает это только
// для админа - на Flutter ничего дополнительно проверять не нужно
class _SourcesBlock extends StatelessWidget {
  final List<ChatSource> sources;
  const _SourcesBlock({required this.sources});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.black.withOpacity(0.18),
        border: Border.all(color: context.onSurfaceFaded(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.source_outlined, size: 12, color: context.onSurfaceFaded(0.4)),
              const SizedBox(width: 4),
              Text(
                'ИСТОЧНИКИ (видно только админу)',
                style: TextStyle(color: context.onSurfaceFaded(0.4), fontSize: 9.5, letterSpacing: 0.5),
              ),
            ],
          ),
          const SizedBox(height: 4),
          for (final s in sources)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                '${s.filename}${s.page != null ? ', стр. ${s.page}' : ''} · ${(s.similarity * 100).round()}%',
                style: TextStyle(color: context.onSurfaceFaded(0.55), fontSize: 11),
              ),
            ),
        ],
      ),
    );
  }
}

/// Превью прикреплённых фото в пузыре сообщения — тап открывает во весь
/// экран. base64 хранится и рендерится напрямую из памяти, отдельного
/// файла на диске для этого не заводим.
class _AttachedImages extends StatelessWidget {
  final List<String> images;
  const _AttachedImages({required this.images});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: images.map((base64Image) {
        final bytes = base64Decode(base64Image);
        return GestureDetector(
          onTap: () => showDialog(
            context: context,
            builder: (context) => Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.all(16),
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: InteractiveViewer(
                  child: Image.memory(bytes, fit: BoxFit.contain),
                ),
              ),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(bytes, width: 140, height: 140, fit: BoxFit.cover),
          ),
        );
      }).toList(),
    );
  }
}

/// Показывает ВСЕ доступные образцы темы прямо под сообщением ИИ, когда
/// оно содержало маркер [[OFFER_THEME_PICKER]] - вместо того чтобы
/// заставлять модель помнить, какие варианты уже предлагались (ненадёжно
/// для маленькой модели), человек просто видит весь набор и выбирает сам.
class _InlineThemePicker extends StatelessWidget {
  final VoidCallback onDone;
  const _InlineThemePicker({required this.onDone});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ThemeStore.instance,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Выбери, что понравится:', style: TextStyle(color: context.onSurfaceFaded(0.55), fontSize: 12)),
            const SizedBox(height: 8),
            SizedBox(
              height: 70,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: BackgroundVariant.values
                      .map((v) => Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: ThemeVariantSwatch(
                              variant: v,
                              selected: ThemeStore.instance.variant == v,
                              onTap: () {
                                ThemeStore.instance.setVariant(v);
                                onDone();
                              },
                            ),
                          ))
                      .toList(),
                ),
              ),
            ),
            TextButton(
              onPressed: onDone,
              style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
              child: Text('Не сейчас', style: TextStyle(color: context.onSurfaceFaded(0.4), fontSize: 11.5)),
            ),
          ],
        );
      },
    );
  }
}

/// Кнопки Да/Нет под сообщением ИИ, когда оно содержало маркер
/// [[OFFER_TEST]] (обработано и вырезано в chat_store.dart). Решение
/// всегда за человеком - ИИ только предлагает, ничего не выбирает сам.
class _TestOfferButtons extends StatelessWidget {
  final ValueChanged<bool> onAnswer;
  const _TestOfferButtons({required this.onAnswer});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _AnswerChip(
          label: 'Да, давай тест',
          backgroundColor: const Color(0xFF6C5CE7),
          textColor: Colors.white,
          onTap: () => onAnswer(true),
        ),
        const SizedBox(width: 8),
        _AnswerChip(
          label: 'Нет, продолжим так',
          backgroundColor: context.onSurfaceFaded(0.1),
          textColor: context.onSurfaceFaded(0.8),
          onTap: () => onAnswer(false),
        ),
      ],
    );
  }
}

class _AnswerChip extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onTap;
  const _AnswerChip({required this.label, required this.backgroundColor, required this.textColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: backgroundColor,
          ),
          child: Text(label, style: TextStyle(color: textColor, fontSize: 12.5, fontWeight: FontWeight.w500)),
        ),
      ),
    );
  }
}
