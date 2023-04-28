class ShoppingList {
  String title;
  bool archived;
  List<String> users;
  int itemsCounter;

  ShoppingList(this.title, {this.itemsCounter = 0, this.archived = false, this.users = const []});

  ShoppingList.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        itemsCounter = json['itemsCounter'],
        archived = json['archived'],
        users = json['users'];

  Map<String, dynamic> toJson() => {
        'title': title,
        'itemsCounter': itemsCounter,
        'archived': archived,
        'users': users,
      };
}
