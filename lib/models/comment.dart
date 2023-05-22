class Comment {
  final String content;
  final DateTime date;
  final String userName;
  final String userAvatar;

  Comment({
    required this.content,
    required this.date,
    required this.userName,
    required this.userAvatar,
  });

  Comment.fromJson(Map<String, dynamic> json)
      : content = json['content'],
        date = json['date'].toDate(),
        userName = json['userName'],
        userAvatar = json['userAvatar'];

  Map<String, dynamic> toJson() => {
        'content': content,
        'date': date,
        'userName': userName,
        'userAvatar': userAvatar,
      };
}
