import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/dashboard_stats.dart';
import '../services/stats_service.dart';
import '../state/auth_store.dart';
import '../theme/app_text_color.dart';
import '../widgets/activity_line_chart.dart';
import '../widgets/complaints_bar_chart.dart';
import '../widgets/export_buttons.dart';
import '../widgets/glass_panel.dart';
import 'admin_ai_screen.dart';
import 'admin_blog_screen.dart';
import 'admin_custom_tests_screen.dart';
import 'admin_documents_screen.dart';
import 'admin_oauth_panel.dart';
import 'admin_ollama_pool_panel.dart';
import 'admin_operators_screen.dart';
import 'admin_payment_panel.dart';
import 'admin_purchases_panel.dart';
import 'admin_reports_screen.dart';
import 'admin_smtp_panel.dart';
import 'admin_sounds_screen.dart';
import 'admin_sql_panel.dart';
import 'admin_support_screen.dart';
import 'admin_tariffs_panel.dart';
import 'admin_telegram_panel.dart';
import 'admin_users_screen.dart';
import 'admin_voice_screen.dart';

enum _Section {
  dashboard,
  purchases,
  users,
  reports,
  documents,
  support,
  voice,
  ai,
  operators,
  blog,
  sounds,
  customTests,
  sqlConsole,
  ollamaPool,
  oauthProviders,
  smtpSettings,
  tariffs,
  telegramSettings,
  paymentSettings,
}

/// Замена сетке плиток (старый admin_home_screen.dart) - постоянный
/// сайдбар слева на широких экранах (обычный вид для админ-панелей),
/// выпадающее меню на узких. Часть разделов (Пользователи, Жалобы и
/// т.д.) пока не встроены содержимым внутрь оболочки - у них своя
/// полноценная навигация (Scaffold+AppBackground), это следующий шаг
/// переработки; сейчас они просто открываются поверх при выборе в
/// сайдбаре, как и раньше.
class AdminShellScreen extends StatefulWidget {
  final AuthStore authStore;
  const AdminShellScreen({super.key, required this.authStore});

  @override
  State<AdminShellScreen> createState() => _AdminShellScreenState();
}

class _AdminShellScreenState extends State<AdminShellScreen> {
  _Section _section = _Section.dashboard;

  static const _wideBreakpoint = 900.0;

  final List<({_Section section, IconData icon, String label})> _navItems = const [
    (section: _Section.dashboard, icon: Icons.dashboard_outlined, label: 'Обзор'),
    (section: _Section.purchases, icon: Icons.payments_outlined, label: 'Покупки'),
    (section: _Section.users, icon: Icons.people_alt_rounded, label: 'Пользователи'),
    (section: _Section.reports, icon: Icons.flag_rounded, label: 'Жалобы на ИИ'),
    (section: _Section.documents, icon: Icons.menu_book_rounded, label: 'Документы (RAG)'),
    (section: _Section.support, icon: Icons.support_agent_rounded, label: 'Обращения'),
    (section: _Section.voice, icon: Icons.record_voice_over_rounded, label: 'Голос'),
    (section: _Section.ai, icon: Icons.face_retouching_natural_rounded, label: 'Поведение ИИ'),
    (section: _Section.operators, icon: Icons.medical_services_outlined, label: 'Доктора'),
    (section: _Section.blog, icon: Icons.article_outlined, label: 'Блог'),
    (section: _Section.sounds, icon: Icons.multitrack_audio_rounded, label: 'Звуки'),
    (section: _Section.customTests, icon: Icons.fact_check_outlined, label: 'Свои тесты'),
    (section: _Section.sqlConsole, icon: Icons.terminal_rounded, label: 'SQL-запросчик'),
    (section: _Section.ollamaPool, icon: Icons.dns_rounded, label: 'Серверы ИИ'),
    (section: _Section.oauthProviders, icon: Icons.login_rounded, label: 'Вход через соцсети'),
    (section: _Section.smtpSettings, icon: Icons.mail_outline_rounded, label: 'Настройки почты'),
    (section: _Section.tariffs, icon: Icons.payments_outlined, label: 'Тарифы'),
    (section: _Section.telegramSettings, icon: Icons.send_rounded, label: 'Telegram'),
    (section: _Section.paymentSettings, icon: Icons.credit_card_outlined, label: 'Оплата и реклама'),
  ];

  // разделы, у которых пока нет содержимого внутри оболочки - открываются
  // отдельным полноэкранным маршрутом поверх, как в старой сетке плиток
  void _select(_Section section, BuildContext sidebarContext) {
    // закрываем выпадающее меню после выбора на узком экране - на широком
    // (постоянный сайдбар, без Drawer) hasDrawer будет false, пропускаем
    if (Scaffold.of(sidebarContext).hasDrawer) {
      Navigator.of(sidebarContext).pop();
    }
    setState(() => _section = section);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1220),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= _wideBreakpoint;
          if (isWide) {
            return Row(
              children: [
                _buildSidebar(),
                Expanded(child: _buildContent()),
              ],
            );
          }
          return Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: const Color(0xFF161A2E),
              title: Text('Админ-панель', style: TextStyle(color: context.onSurface, fontSize: 16)),
              iconTheme: IconThemeData(color: context.onSurface),
            ),
            drawer: Drawer(backgroundColor: const Color(0xFF161A2E), child: _buildSidebarContent()),
            body: _buildContent(),
          );
        },
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 260,
      decoration: const BoxDecoration(
        color: Color(0xFF161A2E),
        border: Border(right: BorderSide(color: Color(0x1AFFFFFF))),
      ),
      child: _buildSidebarContent(),
    );
  }

  Widget _buildSidebarContent() {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.white70),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Выйти из админки',
                ),
                const SizedBox(width: 4),
                const Text('Админ-панель', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          Expanded(
            child: Builder(
              builder: (sidebarContext) => ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: _navItems.map((item) {
                  final selected = item.section == _section;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Material(
                      color: selected ? const Color(0xFF6C5CE7).withValues(alpha: 0.16) : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () => _select(item.section, sidebarContext),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                          child: Row(
                            children: [
                              Icon(item.icon, size: 19, color: selected ? const Color(0xFF9D8CFF) : Colors.white54),
                              const SizedBox(width: 12),
                              Text(
                                item.label,
                                style: TextStyle(
                                  color: selected ? Colors.white : Colors.white70,
                                  fontSize: 13.5,
                                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    void backToDashboard() => setState(() => _section = _Section.dashboard);
    return DecoratedBox(
      decoration: const BoxDecoration(color: Color(0xFF0F1220)),
      child: switch (_section) {
        _Section.dashboard => _DashboardPanel(authStore: widget.authStore),
        _Section.purchases => AdminPurchasesPanel(authStore: widget.authStore),
        _Section.users => AdminUsersScreen(authStore: widget.authStore, onBack: backToDashboard),
        _Section.reports => AdminReportsScreen(authStore: widget.authStore, onBack: backToDashboard),
        _Section.support => AdminSupportScreen(authStore: widget.authStore, onBack: backToDashboard),
        _Section.documents => AdminDocumentsScreen(authStore: widget.authStore, onBack: backToDashboard),
        _Section.voice => AdminVoiceScreen(authStore: widget.authStore, onBack: backToDashboard),
        _Section.ai => AdminAiScreen(authStore: widget.authStore, onBack: backToDashboard),
        _Section.operators => AdminOperatorsScreen(authStore: widget.authStore, onBack: backToDashboard),
        _Section.blog => AdminBlogScreen(authStore: widget.authStore, onBack: backToDashboard),
        _Section.sounds => AdminSoundsScreen(authStore: widget.authStore, onBack: backToDashboard),
        _Section.customTests => AdminCustomTestsScreen(authStore: widget.authStore, onBack: backToDashboard),
        _Section.sqlConsole => AdminSqlPanel(authStore: widget.authStore),
        _Section.ollamaPool => AdminOllamaPoolPanel(authStore: widget.authStore),
        _Section.oauthProviders => AdminOAuthPanel(authStore: widget.authStore),
        _Section.smtpSettings => AdminSmtpPanel(authStore: widget.authStore),
        _Section.tariffs => AdminTariffsPanel(authStore: widget.authStore),
        _Section.telegramSettings => AdminTelegramPanel(authStore: widget.authStore),
        _Section.paymentSettings => AdminPaymentPanel(authStore: widget.authStore),
      },
    );
  }
}

/// Дашборд - карточки со статистикой (тот же /api/admin/stats, что и
/// раньше) плюс два новых графика (активность по дням, жалобы по месяцам).
class _DashboardPanel extends StatefulWidget {
  final AuthStore authStore;
  const _DashboardPanel({required this.authStore});

  @override
  State<_DashboardPanel> createState() => _DashboardPanelState();
}

class _DashboardPanelState extends State<_DashboardPanel> {
  final _service = StatsService();
  DashboardStats? _stats;
  List<ActivityDay> _activity = [];
  List<ComplaintsMonth> _complaints = [];
  List<HourlyActivity> _hourly = [];
  List<TokenUsageByUser> _tokenUsage = [];
  bool _isLoading = true;

  // месяц, за который сейчас смотрим статистику - по умолчанию текущий
  late int _selectedYear;
  late int _selectedMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedYear = now.year;
    _selectedMonth = now.month;
    _load();
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  bool get _isCurrentMonth {
    final now = DateTime.now();
    return _selectedYear == now.year && _selectedMonth == now.month;
  }

  void _changeMonth(int delta) {
    setState(() {
      var newMonth = _selectedMonth + delta;
      var newYear = _selectedYear;
      if (newMonth > 12) {
        newMonth = 1;
        newYear++;
      } else if (newMonth < 1) {
        newMonth = 12;
        newYear--;
      }
      _selectedMonth = newMonth;
      _selectedYear = newYear;
    });
    _load();
  }

  Future<void> _load() async {
    final token = widget.authStore.token;
    if (token == null) return;
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _service.getDashboardStats(
          baseUrl: widget.authStore.baseUrl,
          token: token,
          year: _selectedYear,
          month: _selectedMonth,
        ),
        _service.getActivity(baseUrl: widget.authStore.baseUrl, token: token, days: 30),
        _service.getComplaintsByMonth(baseUrl: widget.authStore.baseUrl, token: token, months: 6),
        _service.getActivityByHour(baseUrl: widget.authStore.baseUrl, token: token, days: 30),
        _service.getTokenUsageByUser(baseUrl: widget.authStore.baseUrl, token: token, days: 30),
      ]);
      if (!mounted) return;
      setState(() {
        _stats = results[0] as DashboardStats;
        _activity = results[1] as List<ActivityDay>;
        _complaints = results[2] as List<ComplaintsMonth>;
        _hourly = results[3] as List<HourlyActivity>;
        _tokenUsage = results[4] as List<TokenUsageByUser>;
      });
    } on StatsException {
      // тихо оставляем предыдущие данные - дашборд необязателен для
      // остальной работы админки
    }
    if (mounted) setState(() => _isLoading = false);
  }

  static const _monthNames = [
    'Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь',
    'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь',
  ];

  // "Обзор" уже написано в сайдбаре как название раздела - повторять то
  // же самое заголовком в контенте было избыточно. Вместо этого -
  // приветствие с учётом времени суток и датой, как у обычных SaaS-
  // дашбордов, а не голый технический заголовок
  String get _timeAwareGreeting {
    final hour = DateTime.now().hour;
    if (hour < 6) return 'Доброй ночи';
    if (hour < 12) return 'Доброе утро';
    if (hour < 18) return 'Добрый день';
    return 'Добрый вечер';
  }

  Widget _buildGreetingHeader() {
    final user = widget.authStore.user;
    final displayName = user?.fullName?.isNotEmpty == true ? user!.fullName! : (user?.email.split('@').first ?? 'администратор');
    final today = DateFormat('EEEE, d MMMM', 'ru').format(DateTime.now());
    // с заглавной буквы - DateFormat отдаёт день недели со строчной
    final todayCapitalized = today.isEmpty ? today : today[0].toUpperCase() + today.substring(1);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFF6C5CE7).withValues(alpha: 0.18), const Color(0xFF00B4D8).withValues(alpha: 0.1)],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$_timeAwareGreeting, $displayName 👋',
                  style: TextStyle(color: context.onSurface, fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(todayCapitalized, style: TextStyle(color: context.onSurfaceFaded(0.55), fontSize: 13)),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: context.onSurfaceFaded(0.5)),
            onPressed: _load,
            tooltip: 'Обновить',
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _stats == null) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF6C5CE7)));
    }
    final stats = _stats;

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildGreetingHeader(),
          const SizedBox(height: 20),
          _buildMonthSelector(),
          const SizedBox(height: 20),
          if (stats != null) _buildStatsGrid(stats),
          const SizedBox(height: 24),
          GlassPanel(
            opacity: 0.06,
            borderRadius: BorderRadius.circular(16),
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Активность за 30 дней', style: TextStyle(color: context.onSurface, fontSize: 14.5, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text('Ответы модели по дням', style: TextStyle(color: context.onSurfaceFaded(0.4), fontSize: 11.5)),
                const SizedBox(height: 16),
                ActivityLineChart(data: _activity),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlassPanel(
            opacity: 0.06,
            borderRadius: BorderRadius.circular(16),
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Жалобы по месяцам', style: TextStyle(color: context.onSurface, fontSize: 14.5, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text('Сравнение за последние 6 месяцев', style: TextStyle(color: context.onSurfaceFaded(0.4), fontSize: 11.5)),
                const SizedBox(height: 16),
                ComplaintsBarChart(data: _complaints),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlassPanel(
            opacity: 0.06,
            borderRadius: BorderRadius.circular(16),
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Активность по часам суток', style: TextStyle(color: context.onSurface, fontSize: 14.5, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(
                  'За последние 30 дней, время UTC - помогает понять, в какие часы обычно больше нагрузки, чтобы решить, когда усиливать сервер',
                  style: TextStyle(color: context.onSurfaceFaded(0.4), fontSize: 11.5, height: 1.4),
                ),
                const SizedBox(height: 16),
                _buildHourlyTable(),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlassPanel(
            opacity: 0.06,
            borderRadius: BorderRadius.circular(16),
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text('Расход токенов по пользователям', style: TextStyle(color: context.onSurface, fontSize: 14.5, fontWeight: FontWeight.w600)),
                    ),
                    ExportButtonsRow(
                      filename: 'Расход токенов',
                      columns: const ['Пользователь', 'Запросов', 'Prompt', 'Completion', 'Всего'],
                      rows: _tokenUsage
                          .map((u) => [u.userEmail, u.requestCount, u.promptTokens, u.completionTokens, u.totalTokens])
                          .toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text('За последние 30 дней, топ-50 по расходу', style: TextStyle(color: context.onSurfaceFaded(0.4), fontSize: 11.5)),
                const SizedBox(height: 16),
                _buildTokenUsageTable(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.chevron_left_rounded, color: context.onSurfaceFaded(0.6)),
          onPressed: () => _changeMonth(-1),
        ),
        Text(
          '${_monthNames[_selectedMonth - 1]} $_selectedYear',
          style: TextStyle(color: context.onSurface, fontSize: 14, fontWeight: FontWeight.w600),
        ),
        IconButton(
          icon: Icon(Icons.chevron_right_rounded, color: context.onSurfaceFaded(0.6)),
          onPressed: () => _changeMonth(1),
        ),
        if (!_isCurrentMonth) ...[
          const SizedBox(width: 8),
          TextButton(
            onPressed: () {
              final now = DateTime.now();
              setState(() {
                _selectedYear = now.year;
                _selectedMonth = now.month;
              });
              _load();
            },
            child: Text('Сейчас', style: TextStyle(color: context.onSurfaceFaded(0.5), fontSize: 12.5)),
          ),
        ],
      ],
    );
  }

  Widget _buildStatsGrid(DashboardStats stats) {
    final items = [
      (stats.usersTotal.toString(), 'пользователей', Icons.people_alt_rounded, const Color(0xFF6C5CE7)),
      (stats.usersOnlineNow.toString(), 'онлайн сейчас', Icons.circle, const Color(0xFF00E6A0)),
      (stats.ticketsOpen.toString(), 'открытых тикетов', Icons.support_agent_rounded, const Color(0xFF00B4D8)),
      (stats.reportsOpen.toString(), 'открытых жалоб', Icons.flag_rounded, const Color(0xFFFF6B6B)),
      (stats.documentsTotal.toString(), 'документов RAG', Icons.menu_book_rounded, const Color(0xFFFFD166)),
      (_formatTokens(stats.tokensUsedInPeriod), 'токенов за месяц', Icons.bolt_rounded, const Color(0xFF9D8CFF)),
      (stats.purchasesCountInPeriod.toString(), 'покупок за месяц', Icons.shopping_bag_rounded, const Color(0xFF6FCF97)),
      (_formatCents(stats.purchasesTotalCentsInPeriod), 'выручка за месяц', Icons.payments_rounded, const Color(0xFF00E6A0)),
    ];

    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.7,
      children: items
          .map((item) => GlassPanel(
                opacity: 0.06,
                borderRadius: BorderRadius.circular(14),
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: item.$4.withValues(alpha: 0.16)),
                      child: Icon(item.$3, size: 15, color: item.$4),
                    ),
                    const SizedBox(height: 8),
                    Text(item.$1, style: TextStyle(color: context.onSurface, fontSize: 20, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(item.$2, style: TextStyle(color: context.onSurfaceFaded(0.5), fontSize: 11)),
                  ],
                ),
              ))
          .toList(),
    );
  }

  Widget _buildHourlyTable() {
    if (_hourly.isEmpty) {
      return Text('Нет данных.', style: TextStyle(color: context.onSurfaceFaded(0.4)));
    }
    final maxMessages = _hourly.map((h) => h.messages).fold<int>(0, (a, b) => a > b ? a : b);
    final safeMax = maxMessages == 0 ? 1 : maxMessages;

    return Column(
      children: _hourly.map((h) {
        final hourLabel = '${h.hour.toString().padLeft(2, '0')}:00';
        final barWidth = h.messages / safeMax;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            children: [
              SizedBox(width: 48, child: Text(hourLabel, style: TextStyle(color: context.onSurfaceFaded(0.5), fontSize: 11.5))),
              Expanded(
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 16,
                      child: DecoratedBox(
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: context.onSurfaceFaded(0.05)),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: barWidth.clamp(0.02, 1.0),
                      child: Container(
                        height: 16,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: const Color(0xFF6C5CE7)),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 40,
                child: Text('${h.messages}', textAlign: TextAlign.right, style: TextStyle(color: context.onSurfaceFaded(0.6), fontSize: 11.5)),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTokenUsageTable() {
    if (_tokenUsage.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text('Нет расхода токенов за этот период.', style: TextStyle(color: context.onSurfaceFaded(0.4))),
      );
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          DataColumn(label: Text('Пользователь', style: TextStyle(color: context.onSurfaceFaded(0.4), fontSize: 11.5, fontWeight: FontWeight.w600))),
          DataColumn(label: Text('Запросов', style: TextStyle(color: context.onSurfaceFaded(0.4), fontSize: 11.5, fontWeight: FontWeight.w600)), numeric: true),
          DataColumn(label: Text('Prompt', style: TextStyle(color: context.onSurfaceFaded(0.4), fontSize: 11.5, fontWeight: FontWeight.w600)), numeric: true),
          DataColumn(label: Text('Completion', style: TextStyle(color: context.onSurfaceFaded(0.4), fontSize: 11.5, fontWeight: FontWeight.w600)), numeric: true),
          DataColumn(label: Text('Всего', style: TextStyle(color: context.onSurfaceFaded(0.4), fontSize: 11.5, fontWeight: FontWeight.w600)), numeric: true),
        ],
        rows: _tokenUsage
            .map((u) => DataRow(cells: [
                  DataCell(Text(u.userEmail, style: TextStyle(color: context.onSurface, fontSize: 12.5))),
                  DataCell(Text('${u.requestCount}', style: TextStyle(color: context.onSurfaceFaded(0.6), fontSize: 12.5))),
                  DataCell(Text('${u.promptTokens}', style: TextStyle(color: context.onSurfaceFaded(0.6), fontSize: 12.5))),
                  DataCell(Text('${u.completionTokens}', style: TextStyle(color: context.onSurfaceFaded(0.6), fontSize: 12.5))),
                  DataCell(Text('${u.totalTokens}', style: TextStyle(color: context.onSurface, fontSize: 12.5, fontWeight: FontWeight.w600))),
                ]))
            .toList(),
      ),
    );
  }

  String _formatCents(int cents) {
    final major = cents / 100;
    return r'$' + major.toStringAsFixed(2);
  }

  String _formatTokens(int tokens) {
    if (tokens >= 1000000) return '${(tokens / 1000000).toStringAsFixed(1)}M';
    if (tokens >= 1000) return '${(tokens / 1000).toStringAsFixed(1)}k';
    return tokens.toString();
  }
}
