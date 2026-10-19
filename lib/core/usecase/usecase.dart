import 'package:equatable/equatable.dart';

import '../error/result.dart';

abstract interface class UseCase<T, Params> {
  Future<Result<T>> call(Params params);
}

final class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}
