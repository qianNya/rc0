import Cocoa
import FlutterMacOS

public class Rc0UnityWidgetPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
  private var eventSink: FlutterEventSink?

  public static var isUnityPlayerLinked: Bool {
    Rc0UnityMacPlayer.isLinked
  }

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "rc0_unity_widget", binaryMessenger: registrar.messenger)
    let instance = Rc0UnityWidgetPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)

    let events = FlutterEventChannel(
      name: "rc0_unity_widget/events", binaryMessenger: registrar.messenger)
    events.setStreamHandler(instance)

    let factory = Rc0UnityViewFactory(messenger: registrar.messenger)
    registrar.register(factory, withId: "rc0-unity-view-macos")
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "isUnityAvailable":
      result(Rc0UnityWidgetPlugin.isUnityPlayerLinked)
    case "createView":
      Rc0UnityMacPlayer.ensureRunning { ok in
        result(ok ? Int(Date().timeIntervalSince1970 * 1000) % Int.max : nil)
      }
    case "sendCommand":
      if let args = call.arguments as? [String: Any],
         let json = args["json"] as? String {
        Rc0UnityNativeBridge.sendToUnity(json)
      }
      result(nil)
    case "disposeView":
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    eventSink = events
    Rc0UnityNativeBridge.eventSink = events
    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    eventSink = nil
    Rc0UnityNativeBridge.eventSink = nil
    return nil
  }
}

class Rc0UnityViewFactory: NSObject, FlutterPlatformViewFactory {
  private let messenger: FlutterBinaryMessenger

  init(messenger: FlutterBinaryMessenger) {
    self.messenger = messenger
  }

  func create(withViewIdentifier viewId: Int64, arguments args: Any?) -> NSView {
    let params = args as? [String: Any]
    let sessionId = params?["sessionId"] as? String ?? "default"
    return Rc0UnityMacPlatformView(sessionId: sessionId)
  }

  func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
    FlutterStandardMessageCodec.sharedInstance()
  }
}

final class Rc0UnityMacPlatformView: NSView {
  private let statusLabel = NSTextField(labelWithString: "")
  private let sessionId: String

  init(sessionId: String) {
    self.sessionId = sessionId
    super.init(frame: .zero)
    wantsLayer = true
    layer?.backgroundColor = NSColor(calibratedRed: 0.07, green: 0.06, blue: 0.09, alpha: 1).cgColor
    setupChrome()
    bootPlayer()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setupChrome() {
    statusLabel.translatesAutoresizingMaskIntoConstraints = false
    statusLabel.textColor = NSColor.white.withAlphaComponent(0.55)
    statusLabel.font = NSFont.systemFont(ofSize: 13, weight: .medium)
    statusLabel.alignment = .center
    statusLabel.maximumNumberOfLines = 3
    statusLabel.stringValue = "正在启动 Unity 运行时…"
    addSubview(statusLabel)

    NSLayoutConstraint.activate([
      statusLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
      statusLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
      statusLabel.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 16),
      statusLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -16),
    ])
  }

  private func bootPlayer() {
    Rc0UnityMacPlayer.ensureRunning { [weak self] ok in
      guard let self else { return }
      if ok {
        self.statusLabel.stringValue =
          "Unity 已在独立窗口运行 · \(self.sessionId)\nFlutter 通过 IPC 桥接控制场景"
      } else {
        self.statusLabel.stringValue =
          "Unity 启动失败\n请运行 scripts/link_unity_macos.sh 并重新构建 Unity 导出"
      }
    }
  }
}
