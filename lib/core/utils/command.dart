import 'dart:async';

import 'package:flutter/foundation.dart';

import 'result.dart';

typedef CommandAction0<T> = Future<Result<T>> Function();
typedef CommandAction1<T, A> = Future<Result<T>> Function(A argument);

/// Facilitates interaction with a view model.
/// Encapsulates an action, exposes its running, completed and error states,
/// and prevents re-entrant concurrent invocations.
abstract class Command<T> extends ChangeNotifier {
  bool _running = false;
  bool get running => _running;

  Result<T>? _result;
  bool get error => _result is Error;

  Exception? get errorException => switch (_result) {
    Error(:final error) => error,
    _ => null,
  };

  bool get completed => _result is Ok;
  Result<T>? get result => _result;

  T? get value => switch (_result) {
    Ok(:final value) => value,
    _ => null,
  };

  void clearResult() {
    _result = null;
    notifyListeners();
  }

  Future<void> _execute(CommandAction0<T> action) async {
    if (_running) return;

    _running = true;
    _result = null;
    notifyListeners();

    try {
      _result = await action();
    } on Exception catch (e) {
      _result = Result.error(e);
    } catch (e) {
      _result = Result.error(Exception(e.toString()));
    } finally {
      _running = false;
      notifyListeners();
    }
  }
}

/// A [Command] that accepts no arguments.
final class Command0<T> extends Command<T> {
  Command0(this._action);

  final CommandAction0<T> _action;

  Future<void> execute() async {
    await _execute(_action);
  }
}

/// A [Command] that accepts one argument of type [A].
final class Command1<T, A> extends Command<T> {
  Command1(this._action);

  final CommandAction1<T, A> _action;

  Future<void> execute(A argument) async {
    await _execute(() => _action(argument));
  }
}
