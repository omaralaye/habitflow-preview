class NotificationItem {
  final String id;
  final String type;
  final String title;
  final String message;
  final String time;
  final bool isRead;
  final String icon;
  final int colorValue;

  const NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.time,
    required this.isRead,
    required this.icon,
    required this.colorValue,
  });

  NotificationItem copyWith({bool? isRead}) {
    return NotificationItem(
      id: id,
      type: type,
      title: title,
      message: message,
      time: time,
      isRead: isRead ?? this.isRead,
      icon: icon,
      colorValue: colorValue,
    );
  }
}
