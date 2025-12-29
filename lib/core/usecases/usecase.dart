import 'package:dartz/dartz.dart';
import 'package:erpfarmasimobile/core/error/failures.dart';

// Since we didn't add dartz to pubspec, we should probably add it or use a Result type.
// For now, let's use a simple Result class or standard dartz if user prefers.
// Wait, I didn't add dartz in the previous step. Let me add dartz strictly or just use a custom Result.
// Actually, dartz is standard in Flutter Clean Arch. I'll add fpdart which is better maintained.
// But for now, I'll stick to a simple Result wrapper to avoid extra deps if not needed,
// OR I will add fpdart properly in the next step.
// Let's use `fpdart` as it's modern.

// Re-writing implementation to use a lightweight Result from core or just standard dartz/fpdart.
// I'll stick to 'either_dart' or 'fpdart'.
// Let's use `fpdart`.
abstract class UseCase<Type, Params> {
  Future<Type> call(Params params);
}
