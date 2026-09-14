class SystemStatus {
  final double cpuPercent;
  final double memoryPercent;
  final int memoryUsedMb;
  final int memoryTotalMb;
  final double diskPercent;
  final double diskUsedGb;
  final double diskTotalGb;
  final int backendUptimeSeconds;
  final String dbStatus; // "ok" | "unreachable"
  final double? dbSizeMb;
  final int? dbActiveConnections;
  final String dbType; // "postgresql" | "sqlite"
  final int backupsCount;
  final double backupsTotalSizeMb;
  final DateTime? lastBackupAt;

  SystemStatus({
    required this.cpuPercent,
    required this.memoryPercent,
    required this.memoryUsedMb,
    required this.memoryTotalMb,
    required this.diskPercent,
    required this.diskUsedGb,
    required this.diskTotalGb,
    required this.backendUptimeSeconds,
    required this.dbStatus,
    this.dbSizeMb,
    this.dbActiveConnections,
    required this.dbType,
    required this.backupsCount,
    required this.backupsTotalSizeMb,
    this.lastBackupAt,
  });

  factory SystemStatus.fromJson(Map<String, dynamic> json) => SystemStatus(
        cpuPercent: (json['cpu_percent'] as num?)?.toDouble() ?? 0,
        memoryPercent: (json['memory_percent'] as num?)?.toDouble() ?? 0,
        memoryUsedMb: json['memory_used_mb'] as int? ?? 0,
        memoryTotalMb: json['memory_total_mb'] as int? ?? 0,
        diskPercent: (json['disk_percent'] as num?)?.toDouble() ?? 0,
        diskUsedGb: (json['disk_used_gb'] as num?)?.toDouble() ?? 0,
        diskTotalGb: (json['disk_total_gb'] as num?)?.toDouble() ?? 0,
        backendUptimeSeconds: json['backend_uptime_seconds'] as int? ?? 0,
        dbStatus: json['db_status'] as String? ?? 'unreachable',
        dbSizeMb: (json['db_size_mb'] as num?)?.toDouble(),
        dbActiveConnections: json['db_active_connections'] as int?,
        dbType: json['db_type'] as String? ?? 'unknown',
        backupsCount: json['backups_count'] as int? ?? 0,
        backupsTotalSizeMb: (json['backups_total_size_mb'] as num?)?.toDouble() ?? 0,
        lastBackupAt: json['last_backup_at'] != null ? DateTime.tryParse(json['last_backup_at'] as String) : null,
      );
}

class BackupInfo {
  final String filename;
  final int sizeBytes;
  final DateTime createdAt;

  BackupInfo({required this.filename, required this.sizeBytes, required this.createdAt});

  factory BackupInfo.fromJson(Map<String, dynamic> json) => BackupInfo(
        filename: json['filename'] as String,
        sizeBytes: json['size_bytes'] as int? ?? 0,
        createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      );

  String get formattedSize {
    final mb = sizeBytes / (1024 * 1024);
    if (mb < 1) return '${(sizeBytes / 1024).toStringAsFixed(0)} КБ';
    return '${mb.toStringAsFixed(1)} МБ';
  }
}
