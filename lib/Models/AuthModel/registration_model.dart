class RegistrationModel {
  String? sId;
  String? username;
  String? email;
  String? avatar;
  String? token;

  RegistrationModel(
      {this.sId, this.username, this.email, this.avatar, this.token});

  RegistrationModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    username = json['username'];
    email = json['email'];
    avatar = json['avatar'];
    token = json['token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['username'] = this.username;
    data['email'] = this.email;
    data['avatar'] = this.avatar;
    data['token'] = this.token;
    return data;
  }
}
