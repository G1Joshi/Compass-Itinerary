/// Utility class that simplifies handling errors and eliminates unhandled exceptions.
///
/// Return a [Result] from a function to indicate success or failure.
///
/// A [Result] is either an [Ok] with a value of type [T]
/// or an [Error] with an [Exception].
sealed class Result<T> {
  const Result();

  /// Creates a successful [Result], completed with the specified [value].
  const factory Result.ok(T value) = Ok._;

  /// Creates an error [Result], completed with the specified [error].
  const factory Result.error(Exception error) = Error._;

  /// Returns true if this is an [Ok] instance.
  bool get isOk => this is Ok<T>;

  /// Returns true if this is an [Error] instance.
  bool get isError => this is Error<T>;

  /// Returns the value if [Ok], or null if [Error].
  T? get valueOrNull => switch (this) {
    Ok(:final value) => value,
    Error() => null,
  };

  /// Returns the error if [Error], or null if [Ok].
  Exception? get errorOrNull => switch (this) {
    Ok() => null,
    Error(:final error) => error,
  };

  /// Transforms the successful value if [Ok], preserving the [Error].
  Result<R> map<R>(R Function(T value) transform) => switch (this) {
    Ok(:final value) => Result.ok(transform(value)),
    Error(:final error) => Result.error(error),
  };
}

/// A successful [Result] with a returned [value].
final class Ok<T> extends Result<T> {
  const Ok._(this.value);

  /// The returned value of this result.
  final T value;

  @override
  String toString() => 'Result<$T>.ok($value)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Ok<T> && other.value == value);

  @override
  int get hashCode => value.hashCode;
}

/// An error [Result] with a resulting [error].
final class Error<T> extends Result<T> {
  const Error._(this.error);

  /// The resulting error of this result.
  final Exception error;

  @override
  String toString() => 'Result<$T>.error($error)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Error<T> && other.error.toString() == error.toString());

  @override
  int get hashCode => error.hashCode;
}
