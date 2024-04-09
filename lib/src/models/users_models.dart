class UsersModel {
  UsersModel({required this.data});

  final List<UsersData> data;

  factory UsersModel.fromJson(Map<String, dynamic> map) {
    List<UsersData> usersData = [];

    if (map['data'] != null) {
      map['data'].forEach((value) {
        usersData.add(UsersData.fromJson(value));
      });
    } else {
      usersData = [];
    }

    return UsersModel(data: usersData);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['data'] = this.data.map((value) => value.toJson()).toList();
    return data;
  }
}

class UsersData {
  UsersData({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.avatar,
  });

  final int? id;
  final String email;
  final String firstName;
  final String lastName;
  final String fullName;
  final String avatar;

  factory UsersData.fromJson(Map<String, dynamic> map) {
    final id = map['id'];
    final email = map['email'] ?? '';
    final firstName = map['first_name'] ?? '';
    final lastName = map['last_name'] ?? '';
    final avatar = map['avatar'] ?? '';

    return UsersData(
      id: id,
      email: email,
      firstName: firstName,
      lastName: lastName,
      fullName: firstName + ' ' + lastName,
      avatar: avatar,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['email'] = email;
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['avatar'] = avatar;
    data['full_name'] = fullName;
    return data;
  }
}
