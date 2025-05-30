class Media {
  final String type;
  final String url;

  Media(this.type, this.url);

  factory Media.fromJson(Map<String, dynamic> json) {
    return Media(json['type'], json['url']);
  }
}


class MessengerMessageContent {
  final String? content;
  List<Media>? media = [];

  MessengerMessageContent({required this.content, this.media});

  factory MessengerMessageContent.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('media')) {
      List<dynamic> media_json = json['media'];
      List<Media> media = media_json.map((dynamic item) => Media.fromJson(item)).toList();
      return MessengerMessageContent(content: json['content'], media: media);
    }
    return MessengerMessageContent(content: json['content']);
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
    DateTime timestamp;

    if (json.containsKey('timestamp')) {
      timestamp = DateTime.parse(json['timestamp']);
    }
    else {
      timestamp = DateTime.now();
    }

    return MessengerMessage(
        chatId: json['chat_id'],
        senderId: json['sender_id'],
        content: content,
        timestamp: timestamp,
    );
  }

  String getPrettyDatetime() {
    if (DateTime.timestamp().difference(timestamp).inDays >= 7) {
      return '${timestamp.month.toString().padLeft(2, '0')}.${timestamp.day.toString().padLeft(2, '0')}';
    }

    if (timestamp.day != DateTime.timestamp().day) {
      return weekdays[timestamp.weekday];
    }

    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  String getTime() {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}

class MessengerListedChatInfo {
  final String chatId;
  String chatName;
  final MessengerMessage? lastMessage;
  String? photoUrl;
  String? personalChatName;

  MessengerListedChatInfo({
    required this.chatId,
    required this.chatName,
    this.lastMessage,
    this.photoUrl,
  });

  String getPrettyChatName() {
    if (personalChatName != null) {
      return personalChatName!;
    }

    return chatName;
  }

  factory MessengerListedChatInfo.fromJson(Map<String, dynamic> json) {
    MessengerMessage? lastMessage;

    if (json.containsKey('last_message') && json['last_message']['chat_id'].toString().isNotEmpty) {
      lastMessage = MessengerMessage.fromJson(json['last_message']);
    }

    return MessengerListedChatInfo(
        chatId: json['chat_id'],
        chatName: json['chat_name'],
        lastMessage: lastMessage
    );
  }

  bool isPersonal() {
    // temporary solution due to limitations on the backend side
    if (chatName.endsWith('_ps_') && chatName.startsWith('_ps_')) {
      return true;
    }

    return false;
  }

  String? getSecondParticipantId(String userId) {
    // temporary solution due to limitations on the backend side
    if (!isPersonal()) {
      return null;
    }

    var words = chatName.split('_');
    if (words.length != 6) {
      throw Exception('Некорректный формат названия чата.');
    }

    return words[2] == userId ? words[3] : words[2];
  }
}
