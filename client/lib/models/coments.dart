class Comment {
  int? id_comment;
  int? id_user;
  int? id_items;
  String? description;
  static Comment currentComment = Comment.undef();

  Comment.undef(){
    id_comment = -1;
    id_user = -1;
    id_items = -1;
    description = null;
  }

  Comment({
    this.id_comment,
    this.id_user,
    this.id_items,
    this.description
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id_comment: json['id_comment'],
      id_user: json['id_user'],
      id_items: json['id_items'],
      description: json['description']
    );
  }

  @override
  String toString() {
    return 'Comment{idComment: $id_comment, idUser: $id_user, idItems: $id_items, description: $description}';
  }
}
