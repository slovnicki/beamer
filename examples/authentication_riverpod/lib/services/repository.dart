import 'package:authentication_riverpod/models/user.model.dart';

class AppRepository {
  Future<UserModel> loginUser(String username, String password) async {
    if (username == 'beamer' && password == 'supersecret') {
      /// this is where you would do your API call and check if it was successful
      /// also store the `UserModel` in cache
      return UserModel(
          token: "0cc136ea-2862-49c5-832a-2fcacc498637", username: "Beamer");
    } else {
      return UserModel.empty;
    }
  }

  Future<void> logoutUser() async {
    /// on logout, delete the cache of userdata
  }
}
