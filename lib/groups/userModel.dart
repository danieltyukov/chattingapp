class UserModel {
  final String userName;
  final String id;
  // final String photoUrl;
  final String pushToken;
  // final String aboutMe;

  UserModel({
    this.userName,
    this.id,
    // this.photoUrl,
    this.pushToken,
    // this.aboutMe,
  });

  UserModel copyWith({
    String userName,
    String id,
    // String photoUrl,
    String pushToken,
    // String aboutMe,
  }) =>
      UserModel(
        userName: userName ?? this.userName,
        id: id ?? this.id,
        // photoUrl: photoUrl ?? this.photoUrl,
        pushToken: pushToken ?? this.pushToken,
        // aboutMe: aboutMe ?? this.aboutMe,
      );

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        userName: json["userName"] == null ? null : json["userName"],
        id: json["id"] == null ? null : json["id"],
        // photoUrl: json["photoUrl"] == null ? null : json["photoUrl"],
        pushToken: json["pushToken"] == null ? null : json["pushToken"],
        // aboutMe: json["aboutMe"] == null ? null : json["aboutMe"],
      );

  Map<String, dynamic> toJson() => {
        "userName": userName == null ? null : userName,
        "id": id == null ? null : id,
        // "photoUrl": photoUrl == null ? null : photoUrl,
        "pushToken": pushToken == null ? null : pushToken,
        // "aboutMe": aboutMe == null ? null : aboutMe,
      };
}