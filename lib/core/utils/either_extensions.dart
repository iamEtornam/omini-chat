import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';

/// Extension methods for Either type to make it easier to work with
extension EitherExtensions<L, R> on Either<L, R> {
  /// Get the right value, throws if Left
  R getRight() => (this as Right<L, R>).value;

  /// Get the left value, throws if Right
  L getLeft() => (this as Left<L, R>).value;

  /// Map to a widget based on success or failure
  Widget when({
    required Widget Function(L failure) failure,
    required Widget Function(R data) success,
  }) {
    return fold(
      (l) => failure(l),
      (r) => success(r),
    );
  }

  /// Chain operations that can fail
  Either<L, T> flatMap<T>(Either<L, T> Function(R r) f) {
    return fold(
      (l) => Left(l),
      (r) => f(r),
    );
  }

  /// Get the right value or return a default
  R getOrElse(R Function() defaultValue) {
    return fold(
      (l) => defaultValue(),
      (r) => r,
    );
  }

  /// Check if this is a Right
  bool get isRight => fold((_) => false, (_) => true);

  /// Check if this is a Left
  bool get isLeft => fold((_) => true, (_) => false);
}

