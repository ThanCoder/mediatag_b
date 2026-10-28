sealed class Result<T, E> {
  const new();

  bool get isOk => this is Ok<T, E>;
  bool get isErr => this is Err<T, E>;

  T unwrap() {
    return switch (this) {
      Ok(value: final val) => val,
      Err() => throw StateError('Called unwrap() on Err!'),
    };
  }

  E unwrapError() {
    return switch (this) {
      Err(value: final val) => val,
      Ok() => throw StateError('Called unwrapError() on Err!'),
    };
  }
}

class Ok<T, E> extends Result<T, E> {
  const new(this.value);
  final T value;
}

class Err<T, E> extends Result<T, E> {
  const new(this.value);
  final E value;
}
