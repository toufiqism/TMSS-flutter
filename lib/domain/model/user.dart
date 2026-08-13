import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';

@freezed
abstract class User with _$User {
  const factory User({
    required String id,
    required String name,
    required String designation,
    required String email,
  }) = _User;
}

@freezed
abstract class Session with _$Session {
  const factory Session({required String token, required User user}) = _Session;
}
