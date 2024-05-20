class User {
  int? id;
  String? role;
  String? name;
  String? password;
  String? phonenumber;
  String? login;
  String? user_image;
  static User currentUser = User.undef();

  User.undef(){
    id=-1;
    role=null;
    name=null;
    password=null;
    phonenumber=null;
    login=null;
    user_image=null;
  }
  User({
    this.id,
    this.name,
    this.password,
    this.login,
    this.phonenumber,
    this.role,
    this.user_image
  });

  factory User.fromJson(Map<String, dynamic> json) {
 return User(
    id: json['id'],
    name: json['name'],
    password: json['password'] ?? null,
    login: json['login'] ?? null,
    phonenumber: json['phonenumber'] ?? null,
    role: json['role'] ?? null, // Исправлено на 'role'
    user_image: json['user_image'] ?? null, // Исправлено на 'user_image'
 );
}


  @override
  String toString() {
    return 'User{id: $id, name: $name, password: $password phoneNumber: $phonenumber, role: $role,image $user_image}';
  }
}