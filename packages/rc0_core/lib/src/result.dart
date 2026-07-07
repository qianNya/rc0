/// Typed result for repository/service boundaries during Riverpod migration.
sealed class Rc0Result<T> {
  const Rc0Result();

  factory Rc0Result.ok(T value) = Rc0Ok<T>;
  factory Rc0Result.err(String message, {Object? cause}) = Rc0Err<T>;

  bool get isOk => this is Rc0Ok<T>;
  bool get isErr => this is Rc0Err<T>;

  T? get valueOrNull => switch (this) {
        Rc0Ok<T>(:final value) => value,
        Rc0Err<T>() => null,
      };

  String? get errorOrNull => switch (this) {
        Rc0Ok<T>() => null,
        Rc0Err<T>(:final message) => message,
      };

  Rc0Result<R> map<R>(R Function(T value) transform) => switch (this) {
        Rc0Ok<T>(:final value) => Rc0Result.ok(transform(value)),
        Rc0Err<T>(:final message, :final cause) =>
          Rc0Result.err(message, cause: cause),
      };
}

final class Rc0Ok<T> extends Rc0Result<T> {
  const Rc0Ok(this.value);
  final T value;
}

final class Rc0Err<T> extends Rc0Result<T> {
  const Rc0Err(this.message, {this.cause});
  final String message;
  final Object? cause;
}
