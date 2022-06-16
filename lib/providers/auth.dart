import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class Auth with ChangeNotifier {
  String token;
  DateTime expiryDate;
  String userId;

  bool get isAuth {
    return touken != null;
  }

  String get touken {
    if (expiryDate != null &&
        expiryDate.isAfter(DateTime.now()) &&
        token != null) {
      return token;
    }
    return null;
  }

  Future<void> authenticate(
      String password, String email, String urlSegment) async {
    try {
      final url =
          "https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyARu9xogXddCXUCqQqJgVMkaoPJ4sm3JkU";
      final response = await http.post(
        url,
        body: json.encode(
          {
            "email": email,
            "password": password,
            "returnSecureToken": true,
          },
        ),
      );
      final responseData = json.decode(response.body);
      if (responseData["error"] != null) {
        return null;
      }
      token = responseData["idToken"];
      userId = responseData["localId"];
      expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(
            responseData["expiresIn"],
          ),
        ),
      );
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> signup(String password, String email) async {
    return authenticate(password, email, "signUp");
  }

  Future<void> login(String password, String email) async {
    return authenticate(password, email, "signInWithPassword");
  }
}
