import 'dart:async';

import 'package:equatable/equatable.dart';

import 'failures.dart';

sealed class Result<T> extends Equatable {
  const Result();

  bool get isOk => this is Ok<T>;

  R fold<R>(
    R Function(Failure failure) onFailure,
    R Function(T value) onSuccess,
  ) {
    return switch (this) {
      Ok<T>(:final value) => onSuccess(value),
      Err<T>(:final failure) => onFailure(failure),
    };
  }

  Future<Result<R>> andThen<R>(
    FutureOr<Result<R>> Function(T value) next,
  ) async {
    return switch (this) {
      Ok<T>(:final value) => await next(value),
      Err<T>(:final failure) => Err<R>(failure),
    };
  }
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);

  final T value;

  @override
  List<Object?> get props => [value];
}

final class Err<T> extends Result<T> {
  const Err(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
