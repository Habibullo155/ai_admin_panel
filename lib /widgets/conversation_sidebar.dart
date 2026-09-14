import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/chat_conversation.dart';
import '../state/auth_store.dart';
import '../state/chat_store.dart';
import '../screens/wellbeing_calendar_screen.dart';
import '../screens/wellbeing_screen.dart';
import '../theme/app_text_color.dart';
import 'glass_panel.dart';

class ConversationSidebar extends StatelessWidget {
  final ChatStore store;
  final AuthStore authStore;
  final VoidCallback? onSelected;
  final VoidCallback? onCallHelp;

  const ConversationSidebar({super.key, required this.store, required this.authStore, this.onSelected, this.onCallHelp});

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      opacity: 0.08,
      borderRadius: BorderRadius.circular(28),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.spa_rounded,
                  color: context.onSurfaceFaded(0.85), size: 20),
              const SizedBox(width: 8),
              Text(
                'AI Chat',
                style: TextStyle(
                  color: context.onSurfaceFaded(0.92),
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SidebarLinkTile(
            icon: Icons.calendar_month_rounded,
            title: 'Календарь',
            subtitle: 'Результаты опросников по дням',
            onTap: () {
              final userId = authStore.user?.id.toString();
              if (userId == null) return;
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => WellbeingCalendarScreen(userId: userId, authStore: authStore)),
              );
              onSelected?.call();
            },
          ),
          const SizedBox(height: 8),
          _SidebarLinkTile(
            icon: Icons.self_improvement_rounded,
            title: 'Самочувствие',
            subtitle: 'Пройти тест, ситуативная помощь',
            onTap: () {
              final userId = authStore.user?.id.toString();
              if (userId == null) return;
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => WellbeingScreen(userId: userId, authStore: authStore)),
              );
              onSelected?.call();
            },
          ),
          const SizedBox(height: 16),
          _NewChatButton(
            onTap: () {
              store.createNewChat();
              onSelected?.call();
            },
          ),
          if (onCallHelp != null) ...[
            const SizedBox(height: 8),
            _SidebarLinkTile(
              icon: Icons.support_agent_rounded,
              title: 'Позвать на помощь',
              subtitle: 'Подключится врач или специалист',
              onTap: () {
                onCallHelp!.call();
                onSelected?.call();
              },
            ),
          ],
          const SizedBox(height: 16),
          Text(
            'ИСТОРИЯ',
            style: TextStyle(
              color: context.onSurfaceFaded(0.4),
              fontSize: 11,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: AnimatedBuilder(
              animation: store,
              builder: (context, _) {
                if (store.conversations.isEmpty) {
                  return Center(
                    child: Text(
                      'Пока нет диалогов',
                      style: TextStyle(color: context.onSurfaceFaded(0.4)),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: store.conversations.length,
                  itemBuilder: (context, i) {
                    final convo = store.conversations[i];
                    final isActive = convo.id == store.activeConversationId;
                    return _ConversationTile(
                      convo: convo,
                      isActive: isActive,
                      isGenerating: store.isSendingIn(convo.id),
                      onTap: () {
                        store.selectConversation(convo.id);
                        onSelected?.call();
                      },
                      onDelete: () => store.deleteConversation(convo.id),
                      onRename: (newTitle) => store.renameConversation(convo.id, newTitle),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Ссылка на календарь самочувствия — раньше здесь была пустота (кнопка
/// "Новый чат" была первым, что видно, и при пустой истории ниже
/// оставалась одна короткая надпись "Пока нет диалогов"). Занимает то же
/// место, кнопка "Новый чат" теперь ниже.
class _SidebarLinkTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _SidebarLinkTile({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: context.onSurfaceFaded(0.06),
            border: Border.all(color: context.onSurfaceFaded(0.1)),
          ),
          child: Row(
            children: [
              Icon(icon, color: context.onSurfaceFaded(0.75), size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(color: context.onSurfaceFaded(0.85), fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(color: context.onSurfaceFaded(0.4), fontSize: 11),
                    ),
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

class _NewChatButton extends StatelessWidget {
  final VoidCallback onTap;
  const _NewChatButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xFF6C5CE7), Color(0xFF00B4D8)],
            ),
          ),
          child: Row(
            children: const [
              Icon(Icons.add_rounded, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'Новый чат',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final ChatConversation convo;
  final bool isActive;
  final bool isGenerating;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final ValueChanged<String> onRename;

  const _ConversationTile({
    required this.convo,
    required this.isActive,
    required this.isGenerating,
    required this.onTap,
    required this.onDelete,
    required this.onRename,
  });

  Future<void> _showRenameDialog(BuildContext context) async {
    final controller = TextEditingController(text: convo.title);
    await showDialog(
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
                  'Переименовать чат',
                  style: TextStyle(color: context.onSurface, fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  autofocus: true,
                  style: TextStyle(color: context.onSurface),
                  onSubmitted: (value) {
                    onRename(value);
                    Navigator.of(context).pop();
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: context.onSurfaceFaded(0.08),
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
                      child: Text('Отмена', style: TextStyle(color: context.onSurfaceFaded(0.6))),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: const Color(0xFF6C5CE7)),
                      onPressed: () {
                        onRename(controller.text);
                        Navigator.of(context).pop();
                      },
                      child: const Text('Сохранить'),
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

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassPanel(
          opacity: 0.18,
          borderRadius: BorderRadius.circular(20),
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 340),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Удалить чат?',
                  style: TextStyle(color: context.onSurface, fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  'Переписка «${convo.title}» будет удалена без возможности восстановить.',
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
    if (confirmed == true) onDelete();
  }

  @override
  Widget build(BuildContext context) {
    final subtitle = convo.messages.isEmpty
        ? 'Пусто'
        : convo.messages.last.content.replaceAll('\n', ' ');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        onLongPress: () => _showRenameDialog(context),
        child: Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: isActive
                ? context.onSurfaceFaded(0.14)
                : Colors.transparent,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            convo.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: context.onSurfaceFaded(0.9),
                              fontWeight: FontWeight.w500,
                              fontSize: 13.5,
                            ),
                          ),
                        ),
                        if (isGenerating) ...[
                          const SizedBox(width: 6),
                          const SizedBox(
                            width: 8,
                            height: 8,
                            child: CircularProgressIndicator(strokeWidth: 1.5, color: Color(0xFF00D9C0)),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.onSurfaceFaded(0.42),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                DateFormat.Hm().format(convo.updatedAt),
                style: TextStyle(
                  color: context.onSurfaceFaded(0.3),
                  fontSize: 10.5,
                ),
              ),
              InkWell(
                onTap: () => _confirmDelete(context),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.close_rounded,
                    size: 14,
                    color: context.onSurfaceFaded(0.35),
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
