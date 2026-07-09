#ifndef FLUTTER_PLUGIN_RC0_UNITY_WIDGET_PLUGIN_H_
#define FLUTTER_PLUGIN_RC0_UNITY_WIDGET_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <memory>

namespace rc0_unity {

class Rc0UnityWidgetPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows* registrar);

  Rc0UnityWidgetPlugin();

  virtual ~Rc0UnityWidgetPlugin();

  // Disallow copy and assign.
  Rc0UnityWidgetPlugin(const Rc0UnityWidgetPlugin&) = delete;
  Rc0UnityWidgetPlugin& operator=(const Rc0UnityWidgetPlugin&) = delete;

 private:
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue>& method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace rc0_unity

#endif  // FLUTTER_PLUGIN_RC0_UNITY_WIDGET_PLUGIN_H_
