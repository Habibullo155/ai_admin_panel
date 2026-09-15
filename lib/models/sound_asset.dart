enum SoundCategory { release, whiteNoise, sleepMusic, streamWater }

SoundCategory soundCategoryFromString(String value) {
  switch (value) {
    case 'white_noise':
      return SoundCategory.whiteNoise;
    case 'sleep_music':
      return SoundCategory.sleepMusic;
    case 'stream_water':
      return SoundCategory.streamWater;
    default:
      return SoundCategory.release;
  }
}

String soundCategoryToString(SoundCategory category) {
  switch (category) {
    case SoundCategory.whiteNoise:
      return 'white_noise';
    case SoundCategory.sleepMusic:
      return 'sleep_music';
    case SoundCategory.streamWater:
      return 'stream_water';
    case SoundCategory.release:
      return 'release';
  }
}

class SoundAsset {
  final int id;
  final String title;
  final SoundCategory category;
  final DateTime createdAt;

  SoundAsset({required this.id, required this.title, required this.category, required this.createdAt});

  factory SoundAsset.fromJson(Map<String, dynamic> json) {
    return SoundAsset(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      category: soundCategoryFromString(json['category'] as String? ?? ''),
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
