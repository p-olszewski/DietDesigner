class ShoppingList {
  String title;
  bool archived;
  List<String> users;

  ShoppingList(this.title, {this.archived = false, this.users = const []});

  ShoppingList.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        archived = json['archived'],
        users = json['users'];

  Map<String, dynamic> toJson() => {
        'title': title,
        'archived': archived,
        'users': users,
      };
}
