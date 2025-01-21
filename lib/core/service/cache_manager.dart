import 'dart:convert';

import 'package:get_storage/get_storage.dart';
import 'package:googleapis/admin/directory_v1.dart';

mixin CacheManager {
  Future<bool> saveIsLogin(bool? isLogin) async {
    final storage = GetStorage();
    await storage.write(CMEnums.isLogin.toString(), isLogin);
    return true;
  }

  bool? getIsLogin() {
    final storage = GetStorage();
    return storage.read(CMEnums.isLogin.toString());
  }

  // Future<bool> saveUsers(Users? users) async {
  //   final storage = GetStorage();
  //   await storage.write(CMEnums.users.toString(), jsonEncode(users!.toMap()));
  //   return true;
  // }
  //
  // Users? getUsers() {
  //   final storage = GetStorage();
  //   final usersJson = storage.read(CMEnums.users.toString());
  //   if (usersJson != null) {
  //     Map<String, dynamic> userMap = jsonDecode(usersJson);
  //     return Users.fromMap(userMap);
  //   } else {
  //     return null;
  //   }
  // }

  Future<bool> saveUserEmail(String email) async {
    final storage = GetStorage();
    await storage.write(CMEnums.userEmail.toString(), email);
    return true;
  }

  String? getUserEmail() {
    final storage = GetStorage();
    return storage.read(CMEnums.userEmail.toString());
  }

  Future<bool> removeAllData() async {
    final storage = GetStorage();
    await storage.remove(CMEnums.isLogin.toString());
    await storage.remove(CMEnums.userEmail.toString());
    return true;
  }
}

enum CMEnums {
  isLogin,
  userEmail,
}
