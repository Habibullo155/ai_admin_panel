class OllamaServer {
  final int id;
  final String name;
  final String baseUrl;
  final bool enabled;
  // у vLLM (в отличие от Ollama) нет шага установки модели - либо она
  // уже загружена на сервере, либо нет, поэтому "pulling_models"/прогресс
  // больше не существуют как статусы
  final String status; // pending | ready | unreachable | model_mismatch
  final String? statusDetail;
  final int activeRequests;
  // "base" | "pro" - какую ИМЕННО модель должен обслуживать этот сервер
  // (OLLAMA_MODEL/OLLAMA_PRO_MODEL на бэкенде соответственно) - два
  // независимых пула, не общий список вперемешку
  final String modelTier;

  OllamaServer({
    required this.id,
    required this.name,
    required this.baseUrl,
    required this.enabled,
    required this.status,
    this.statusDetail,
    required this.activeRequests,
    required this.modelTier,
  });

  bool get isBusyPreparing => status == 'pending';
  bool get isReady => status == 'ready';
  bool get hasProblem => status == 'unreachable' || status == 'model_mismatch';
  bool get isPro => modelTier == 'pro';

  factory OllamaServer.fromJson(Map<String, dynamic> json) => OllamaServer(
        id: json['id'] as int,
        name: json['name'] as String,
        baseUrl: json['base_url'] as String,
        enabled: json['enabled'] as bool? ?? true,
        status: json['status'] as String? ?? 'pending',
        statusDetail: json['status_detail'] as String?,
        activeRequests: json['active_requests'] as int? ?? 0,
        modelTier: json['model_tier'] as String? ?? 'base',
      );
}
