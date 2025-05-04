enum ChatType {
  group,
  personal,
}

class MessengerMessageContent {
  final String? content;

  MessengerMessageContent(this.content);

  factory MessengerMessageContent.fromJson(Map<String, dynamic> json) {
    return MessengerMessageContent(json['content']);
  }
}

class MessengerMessage {
  final String chatId;
  final String senderId;
  final MessengerMessageContent content;
  final DateTime timestamp;

  static const Map weekdays = {
    1: 'Пн',
    2: 'Вт',
    3: 'Ср',
    4: 'Чт',
    5: 'Пт',
    6: 'Сб',
    7: 'Вс',
  };

  MessengerMessage({
    required this.chatId,
    required this.senderId,
    required this.content,
    required this.timestamp
  });

  factory MessengerMessage.fromJson(Map<String, dynamic> json) {
    var content = MessengerMessageContent.fromJson(json['content']);
    var timestamp = DateTime.parse(json['timestamp']);

    return MessengerMessage(
        chatId: json['chat_id'],
        senderId: json['sender_id'],
        content: content,
        timestamp: timestamp,
    );
  }

  String getPrettyDatetime() {
    if (timestamp.day != DateTime.timestamp().day) {
      return weekdays[timestamp.weekday];
    }

    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}

class MessengerListedChatInfo {
  final String chatId;
  final String chatName;
  final MessengerMessage? lastMessage;

  MessengerListedChatInfo({
    required this.chatId,
    required this.chatName,
    this.lastMessage
  });

  factory MessengerListedChatInfo.fromJson(Map<String, dynamic> json) {
    MessengerMessage? lastMessage;

    if (json.containsKey('last_message')) {
      lastMessage = MessengerMessage.fromJson(json['last_message']);
    }

    return MessengerListedChatInfo(
        chatId: json['chat_id'],
        chatName: json['chat_name'],
        lastMessage: lastMessage
    );
  }
}

class SuggestedUser {
  final String name;
  final String userId;
  final String? imageUrl;

  SuggestedUser({
    required this.name,
    required this.userId,
    this.imageUrl
  });

  @override
  bool operator ==(Object other) {
    if (other is SuggestedUser) {
      return userId == (other as SuggestedUser).userId;
    }

    return false;
  }
}
