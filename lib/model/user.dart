import 'dart:typed_data';

class User {
  final int? id; // nullable for new entries where ID is auto-generated
  final String userName;
  final Uint8List? userImage;

  const User({
    this.id,
    required this.userName,
    required this.userImage,
  });

  // Convert a User into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userName': userName,
      'userImage': userImage,
    };
  }



  // Factory constructor to create a User from a Map (when reading from DB)
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ,
      userName: map['userName'] ,
      userImage: map['userImage'] ,
    );
  }
}