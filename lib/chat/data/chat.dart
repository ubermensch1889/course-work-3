enum ChatType {
  group,
  personal,
}

enum MessageStatus {
  delivering,
  delivered,
  read,
}

class ChatItem {
  final String id;
  final String name;
  final String? lastMessageText;
  final String? lastMessageDate;
  final ChatType chatType;
  final String? imageUrl;

  final String? lastMessageAuthorName;
  final MessageStatus? messageStatus;

  ChatItem({
    required this.id,
    required this.name,
    required this.chatType,
    this.lastMessageText,
    this.lastMessageDate,
    this.imageUrl,
    this.lastMessageAuthorName,
    this.messageStatus,
  });

  // TODO: написать конструктор
  // factory ChatItem.fromJson(Map<String, dynamic> json) {
  //   return null;
  // }
}
