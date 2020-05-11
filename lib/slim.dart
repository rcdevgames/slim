library slim;

import 'package:flutter/material.dart';

class Slim<T> extends InheritedNotifier<ChangeNotifier> {
  Slim({@required Widget child, @required T stateObject})
      : super(child: child, notifier: _SlimNotifier(stateObject));

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) =>
      (notifier as _SlimNotifier).hasListeners;

  static T of<T>(BuildContext context) {
    _SlimNotifier notifier =
        context.dependOnInheritedWidgetOfExactType<Slim<T>>().notifier;
    if (!notifier.hasListeners && notifier.isModelNotifier) notifier.listen();
    return notifier.stateObject;
  }
}

class _SlimNotifier extends ChangeNotifier {
  final stateObject;
  _SlimNotifier(this.stateObject);

  bool get isModelNotifier => stateObject is ChangeNotifier;

  @override
  bool get hasListeners => isModelNotifier && stateObject.hasListeners;

  void listen() => (stateObject as ChangeNotifier).addListener(notifyListeners);
}

class Slimer<T> {
  final T stateObject;
  Slimer(this.stateObject);
  Widget slim(Widget child) => Slim<T>(child: child, stateObject: stateObject);
}

class MultiSlim extends StatelessWidget {
  final List<Slimer> slimers;
  final Widget child;
  MultiSlim({@required this.child, @required this.slimers});

  @override
  Widget build(BuildContext context) =>
      slimers.fold(null, (value, slimer) => slimer.slim(value ?? child));
}

extension SlimSlimersX on List<Slimer> {
  Widget slim({@required Widget child}) =>
      MultiSlim(child: child, slimers: this);
}

extension SlimBuildContextX on BuildContext {
  T slim<T>() => Slim.of<T>(this);
}
