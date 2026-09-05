class OllamaServer {
  final int id;
  final String name;
  final String baseUrl;
  final bool enabled;
  final String status; // pending | pulling_models | ready | unreachable | error
  final int pullProgress;
  final String? statusDetail;
  final int activeRequests;

  OllamaServer({
    required this.id,
    required this.name,
    required this.baseUrl,
    required this.enabled,
    required this.status,
    required this.pullProgress,
    this.statusDetail,
    required this.activeRequests,
  });

  bool get isBusyPreparing => status == 'pending' || status == 'pulling_models';
  bool get isReady => status == 'ready';
  bool get hasProblem => status == 'unreachable' || status == 'error';

  factory OllamaServer.fromJson(Map<String, dynamic> json) => OllamaServer(
        id: json['id'] as int,
        name: json['name'] as String,
        baseUrl: json['base_url'] as String,
        enabled: json['enabled'] as bool? ?? true,
        status: json['status'] as String? ?? 'pending',
        pullProgress: json['pull_progress'] as int? ?? 0,
        statusDetail: json['status_detail'] as String?,
        activeRequests: json['active_requests'] as int? ?? 0,
      );
}
