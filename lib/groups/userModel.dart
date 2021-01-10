class UserModel {
  final String userName;
  final String id;
  final String pushToken;

  UserModel({
    this.userName,
    this.id,
    this.pushToken,
  });

  UserModel copyWith({
    String userName,
    String id,
    String pushToken,
  }) =>
      UserModel(
        userName: userName ?? this.userName,
        id: id ?? this.id,
        pushToken: pushToken ?? this.pushToken,
      );

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        userName: json["userName"] == null ? null : json["userName"],
        id: json["id"] == null ? null : json["id"],
        pushToken: json["pushToken"] == null ? null : json["pushToken"],
      );

  Map<String, dynamic> toJson() => {
        "userName": userName == null ? null : userName,
        "id": id == null ? null : id,
        "pushToken": pushToken == null ? null : pushToken,
      };
}
