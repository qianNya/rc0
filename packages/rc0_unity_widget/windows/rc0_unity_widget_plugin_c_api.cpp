#include "include/rc0_unity_widget/rc0_unity_widget_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "rc0_unity_widget_plugin.h"

void Rc0UnityWidgetPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  rc0_unity::Rc0UnityWidgetPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
