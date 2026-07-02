#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>
#include <memory>
#include <windows.h>

namespace rc0_unity {

class Rc0UnityWidgetPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows* registrar);

  Rc0UnityWidgetPlugin();
  virtual ~Rc0UnityWidgetPlugin();

 private:
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue>& method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

void Rc0UnityWidgetPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows* registrar) {
  auto channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), "rc0_unity_widget",
          &flutter::StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<Rc0UnityWidgetPlugin>();
  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto& call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  registrar->AddPlugin(std::move(plugin));
}

Rc0UnityWidgetPlugin::Rc0UnityWidgetPlugin() {}
Rc0UnityWidgetPlugin::~Rc0UnityWidgetPlugin() {}

void Rc0UnityWidgetPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  const auto& method = method_call.method_name();
  if (method == "isUnityAvailable") {
    result->Success(flutter::EncodableValue(false));
    return;
  }
  if (method == "createView") {
    result->Success(flutter::EncodableValue(static_cast<int32_t>(GetTickCount())));
    return;
  }
  if (method == "sendCommand" || method == "disposeView") {
    result->Success();
    return;
  }
  result->NotImplemented();
}

}  // namespace rc0_unity

void Rc0UnityWidgetPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  rc0_unity::Rc0UnityWidgetPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
