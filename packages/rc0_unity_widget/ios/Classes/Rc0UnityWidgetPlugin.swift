import Flutter
import UIKit

public class Rc0UnityWidgetPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
  private var eventSink: FlutterEventSink?

  public static var isUnityPlayerLinked: Bool {
    loadTuanjieFramework() != nil
  }

  public static func register(with registrar: FlutterPluginRegistrar) {
    NotificationCenter.default.addObserver(
      forName: NSNotification.Name("Rc0UnitySendToFlutter"),
      object: nil,
      queue: .main
    ) { note in
      guard let json = note.userInfo?["json"] as? String else { return }
      Rc0UnityNativeBridge.sendToFlutter(json)
    }

    let channel = FlutterMethodChannel(name: "rc0_unity_widget", binaryMessenger: registrar.messenger())
    let instance = Rc0UnityWidgetPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)

    let events = FlutterEventChannel(name: "rc0_unity_widget/events", binaryMessenger: registrar.messenger())
    events.setStreamHandler(instance)

    registrar.register(
      Rc0UnityViewFactory(messenger: registrar.messenger()),
      withId: "rc0-unity-view-ios"
    )
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "isUnityAvailable":
      result(Rc0UnityWidgetPlugin.isUnityPlayerLinked)
    case "createView":
      result(Int(Date().timeIntervalSince1970 * 1000) % Int.max)
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

@objc public class Rc0UnityNativeBridge: NSObject {
  @objc public static var eventSink: FlutterEventSink?

  @objc public static func sendToUnity(_ json: String) {
    getTuanjiePlayer().postMessage(
      gameObject: "RC0RuntimeBootstrap",
      method: "OnFlutterMessage",
      message: json
    )
  }

  @objc public static func sendToFlutter(_ json: String) {
    eventSink?(json)
  }
}

class Rc0UnityViewFactory: NSObject, FlutterPlatformViewFactory {
  private let messenger: FlutterBinaryMessenger

  init(messenger: FlutterBinaryMessenger) {
    self.messenger = messenger
  }

  func create(
    withFrame frame: CGRect,
    viewIdentifier viewId: Int64,
    arguments args: Any?
  ) -> FlutterPlatformView {
    let params = args as? [String: Any]
    let sessionId = params?["sessionId"] as? String ?? "default"
    return Rc0UnityPlatformViewController(frame: frame, sessionId: sessionId)
  }

  func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
    FlutterStandardMessageCodec.sharedInstance()
  }
}

class Rc0UnityPlatformViewController: NSObject, FlutterPlatformView {
  private let rootView: Rc0UnityContainerView
  private let sessionId: String

  init(frame: CGRect, sessionId: String) {
    self.sessionId = sessionId
    rootView = Rc0UnityContainerView(frame: frame)
    rootView.backgroundColor = UIColor(red: 0.07, green: 0.06, blue: 0.09, alpha: 1)
    super.init()
    globalUnityControllers.append(self)
    rootView.onBoundsReady = { [weak self] in
      self?.attachUnityView()
    }
    rootView.checkBoundsReady()
  }

  deinit {
    globalUnityControllers.removeAll { $0 === self }
    detachIfNeeded()
  }

  func view() -> UIView { rootView }

  private func attachUnityView() {
    getTuanjiePlayer().createPlayer { [weak self] unityView in
      guard let self, let unityView else { return }
      unityView.removeFromSuperview()
      unityView.frame = self.rootView.bounds
      unityView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
      self.rootView.addSubview(unityView)
      if self.rootView.bounds.width > 0, self.rootView.bounds.height > 0 {
        getTuanjiePlayer().resume()
      }
    }
  }

  private func detachIfNeeded() {
    guard globalUnityControllers.isEmpty else { return }
    #if !RC0_TUANJIE_STUB
    getTuanjiePlayer().controller?.rootView?.removeFromSuperview()
    #endif
  }
}

/// Waits for Flutter PlatformView layout before attaching Unity (avoids 0×0 Metal textures).
private final class Rc0UnityContainerView: UIView {
  var onBoundsReady: (() -> Void)?
  private var didNotify = false

  func checkBoundsReady() {
    guard !didNotify else { return }
    guard bounds.width > 0, bounds.height > 0 else { return }
    didNotify = true
    onBoundsReady?()
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    checkBoundsReady()
    if didNotify, bounds.width > 0, bounds.height > 0 {
      getTuanjiePlayer().resume()
    }
  }
}
