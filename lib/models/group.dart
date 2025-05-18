class Group {
  final String id;
  final String name;
  final String? description;
  final String createdBy;
  final DateTime createdAt;
  final Map<String, dynamic>? profiles;

  Group({
    required this.id,
    required this.name,
    this.description,
    required this.createdBy,
    required this.createdAt,
    this.profiles,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      createdBy: json['created_by'],
      createdAt: DateTime.parse(json['created_at']),
      profiles: json['profiles'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'profiles': profiles,
    };
  }
}

class GroupMember {
  final String id;
  final String name;
  final String imageUrl;
  final bool isAdmin;
  final DateTime joinedAt;

  GroupMember({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.isAdmin,
    required this.joinedAt,
  });
}

class GroupMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime timestamp;
  final String? attachmentUrl;
  final MessageType type;

  GroupMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.timestamp,
    this.attachmentUrl,
    this.type = MessageType.text,
  });
}

enum MessageType { text, image, file, audio, video }
