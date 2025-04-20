class GroupMessage {
  final String id;
  final String groupId;
  final String userId;
  final String senderName;
  final String content;
  final String? attachmentUrl;
  final DateTime createdAt;

  GroupMessage({
    required this.id,
    required this.groupId,
    required this.userId,
    required this.senderName,
    required this.content,
    this.attachmentUrl,
    required this.createdAt,
  });

  factory GroupMessage.fromJson(Map<String, dynamic> json) {
    return GroupMessage(
      id: json['id'],
      groupId: json['group_id'],
      userId: json['user_id'],
      senderName: json['sender_name'],
      content: json['content'],
      attachmentUrl: json['attachment_url'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'group_id': groupId,
      'user_id': userId,
      'sender_name': senderName,
      'content': content,
      'attachment_url': attachmentUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
