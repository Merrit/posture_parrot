import 'dart:async';

import 'package:dbus/dbus.dart';

import '../../logs/logging_manager.dart';

/// DBus object that exposes the `codes.merritt.PostureParrot` interface.
class PostureParrotIdleDBus extends DBusObject {
  /// Creates a new object to expose on [path].
  PostureParrotIdleDBus({DBusObjectPath path = const DBusObjectPath.unchecked('/')}) : super(path);

  final StreamController<void> _userActivityController = StreamController<void>.broadcast();

  /// Stream that emits an event when the user becomes active.
  Stream<void> get userActivity => _userActivityController.stream;

  /// Implementation of codes.merritt.PostureParrot.registerUserActivity()
  Future<DBusMethodResponse> doregisterUserActivity() async {
    log.t('User activity registered via DBus');
    _userActivityController.add(null);
    return DBusMethodSuccessResponse();
  }

  @override
  List<DBusIntrospectInterface> introspect() {
    return [
      DBusIntrospectInterface('codes.merritt.PostureParrot',
          methods: [DBusIntrospectMethod('registerUserActivity')])
    ];
  }

  @override
  Future<DBusMethodResponse> handleMethodCall(DBusMethodCall methodCall) async {
    if (methodCall.interface == 'codes.merritt.PostureParrot') {
      if (methodCall.name == 'registerUserActivity') {
        if (methodCall.values.isNotEmpty) {
          return DBusMethodErrorResponse.invalidArgs();
        }
        return doregisterUserActivity();
      } else {
        return DBusMethodErrorResponse.unknownMethod();
      }
    } else {
      return DBusMethodErrorResponse.unknownInterface();
    }
  }

  @override
  Future<DBusMethodResponse> getProperty(String interface, String name) async {
    if (interface == 'codes.merritt.PostureParrot') {
      return DBusMethodErrorResponse.unknownProperty();
    } else {
      return DBusMethodErrorResponse.unknownProperty();
    }
  }

  @override
  Future<DBusMethodResponse> setProperty(String interface, String name, DBusValue value) async {
    if (interface == 'codes.merritt.PostureParrot') {
      return DBusMethodErrorResponse.unknownProperty();
    } else {
      return DBusMethodErrorResponse.unknownProperty();
    }
  }

  Future<void> dispose() async {
    return await _userActivityController.close();
  }
}
