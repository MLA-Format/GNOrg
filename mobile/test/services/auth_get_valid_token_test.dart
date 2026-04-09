import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gnorg_mobile/services/auth_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('returns null when no token is stored', () async {
    final result = await AuthService.getValidToken();
    expect(result, isNull);
  });

  test('returns null and clears token when token is expired', () async {
    // Expired token: exp set to 1 (Unix epoch 1970)
    final payload = base64Url.encode(
      utf8.encode(jsonEncode({'exp': 1, 'type': 'auth'})),
    );
    final expiredToken = 'header.$payload.signature';
    SharedPreferences.setMockInitialValues({'token': expiredToken});

    final result = await AuthService.getValidToken();

    expect(result, isNull);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('token'), isNull);
  });

  test('returns token when it is valid and not expired', () async {
    final futureExp =
        (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 3600;
    final payload = base64Url.encode(
      utf8.encode(jsonEncode({'exp': futureExp, 'type': 'auth'})),
    );
    final validToken = 'header.$payload.signature';
    SharedPreferences.setMockInitialValues({'token': validToken});

    final result = await AuthService.getValidToken();

    expect(result, equals(validToken));
  });

  test('returns null and clears malformed token', () async {
    SharedPreferences.setMockInitialValues({'token': 'not.a.valid.jwt.format'});

    final result = await AuthService.getValidToken();

    expect(result, isNull);
  });
}
