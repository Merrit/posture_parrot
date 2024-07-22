import 'package:dbus/dbus.dart';

import 'kwin_dbus.dart';
import 'kwin_scripting_dbus.dart';
import '../../logs/logging_manager.dart';

/// Service that interacts with KWin.
class KWin {
  final _kwinScriptingDBus = KwinScriptingDBus(DBusClient.session());
  final _kwinDBus = KWinDBus(DBusClient.session());

  Future<void> loadScript(String scriptPath, String pluginName) async {
    log.t('Loading script $scriptPath with plugin name $pluginName');
    await _kwinScriptingDBus.callloadScript(scriptPath, pluginName);
    await _kwinDBus.callreconfigure();
  }

  Future<void> unloadScript(String pluginName) async {
    log.t('Unloading script with plugin name $pluginName');
    await _kwinScriptingDBus.callunloadScript(pluginName);
  }

  Future<void> dispose() async {
    await _kwinScriptingDBus.dispose();
    await _kwinDBus.dispose();
  }
}
