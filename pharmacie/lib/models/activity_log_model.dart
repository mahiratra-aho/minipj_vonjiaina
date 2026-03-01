enum ActivityType { delivery, update, inventory, alert, import }

class ActivityLogModel {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  final ActivityType type;

  const ActivityLogModel({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.type,
  });

  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) {
      return 'Il y a ${diff.inHours} heure${diff.inHours > 1 ? 's' : ''}';
    }
    if (diff.inDays == 1) {
      return 'Hier, ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
    return '${diff.inDays} jours';
  }
}
