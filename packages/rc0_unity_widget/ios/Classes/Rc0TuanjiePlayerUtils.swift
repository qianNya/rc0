import Foundation
import UIKit

#if !RC0_TUANJIE_STUB
import TuanjieFramework
#endif

private var unityWarmedUp = false
private let constsection = 0

var gArgc: Int32 = 0
var gArgv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?
var gLaunchOpts: [UIApplication.LaunchOptionsKey: Any]?

public func InitUnityIntegration(
  argc: Int32,
  argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?,
  launchOptions: [UIApplication.LaunchOptionsKey: Any]?
) {
  gArgc = argc
  gArgv = argv
  gLaunchOpts = launchOptions
}

func loadTuanjieFramework() -> NSObject? {
  #if !RC0_TUANJIE_STUB
  if let path = Bundle.main.path(
    forResource: "TuanjieFramework",
    ofType: "framework",
    inDirectory: "Frameworks"
  ), let bundle = Bundle(path: path) {
    if !bundle.isLoaded { bundle.load() }
    return TuanjieFramework.getInstance()
  }

  let candidates = [
    Bundle.main.privateFrameworksURL?.appendingPathComponent("TuanjieFramework.framework"),
    Bundle(for: Rc0UnityWidgetPlugin.self).bundleURL
      .deletingLastPathComponent()
      .appendingPathComponent("TuanjieFramework.framework"),
  ].compactMap { $0 }

  for url in candidates {
    if let bundle = Bundle(url: url) {
      if !bundle.isLoaded { bundle.load() }
      return TuanjieFramework.getInstance()
    }
  }
  #endif
  return nil
}

var globalUnityControllers: [Rc0UnityPlatformViewController] = []

func getTuanjiePlayer() -> Rc0TuanjiePlayerUtils {
  Rc0TuanjiePlayerUtils.shared
}

@objc public class Rc0TuanjiePlayerUtils: NSObject {
  static let shared = Rc0TuanjiePlayerUtils()

  #if !RC0_TUANJIE_STUB
  var ufw: TuanjieFramework?
  var controller: UnityAppController? { ufw?.appController() }
  #endif

  private var isReady = false
  private var isLoaded = false

  func isInitialized() -> Bool {
    #if !RC0_TUANJIE_STUB
    return ufw != nil
    #else
    return false
    #endif
  }

  func initUnity() {
    #if !RC0_TUANJIE_STUB
    if isInitialized() {
      ufw?.showUnityWindow()
      return
    }
    guard let framework = loadTuanjieFramework() as? TuanjieFramework else {
      NSLog("[RC0Unity] TuanjieFramework not found")
      return
    }
    ufw = framework
    framework.setDataBundleId("com.unity3d.framework")
    framework.register(self)
    framework.runEmbedded(
      withArgc: gArgc,
      argv: gArgv,
      appLaunchOpts: gLaunchOpts
    )
    if let appController = framework.appController() {
      if let window = appController.window {
        window.windowLevel = UIWindow.Level(UIWindow.Level.normal.rawValue - 1)
      }
    }
    isLoaded = true
    listenAppLifecycle()
    #endif
  }

  func createPlayer(completion: @escaping (UIView?) -> Void) {
    #if !RC0_TUANJIE_STUB
    if isInitialized() && isReady {
      completion(controller?.rootView)
      return
    }
    DispatchQueue.main.async {
      self.initUnity()
      unityWarmedUp = true
      self.isReady = true
      self.isLoaded = true
      self.ufw?.pause(false)
      completion(self.controller?.rootView)
    }
    #else
    completion(nil)
    #endif
  }

  func resume() {
    #if !RC0_TUANJIE_STUB
    ufw?.pause(false)
    #endif
  }

  func postMessage(gameObject: String, method: String, message: String) {
    #if !RC0_TUANJIE_STUB
    ufw?.sendMessageToGO(withName: gameObject, functionName: method, message: message)
    #endif
  }

  private func listenAppLifecycle() {
    #if !RC0_TUANJIE_STUB
    let names: [NSNotification.Name] = [
      UIApplication.didBecomeActiveNotification,
      UIApplication.didEnterBackgroundNotification,
      UIApplication.willTerminateNotification,
      UIApplication.willResignActiveNotification,
      UIApplication.willEnterForegroundNotification,
      UIApplication.didReceiveMemoryWarningNotification,
    ]
    for name in names {
      NotificationCenter.default.addObserver(
        self,
        selector: #selector(handleAppState(_:)),
        name: name,
        object: nil
      )
    }
    #endif
  }

  @objc private func handleAppState(_ notification: Notification) {
    #if !RC0_TUANJIE_STUB
    guard isReady, let appController = controller else { return }
    let app = UIApplication.shared
    switch notification.name {
    case UIApplication.willResignActiveNotification:
      appController.applicationWillResignActive(app)
    case UIApplication.didEnterBackgroundNotification:
      appController.applicationDidEnterBackground(app)
    case UIApplication.willEnterForegroundNotification:
      appController.applicationWillEnterForeground(app)
    case UIApplication.didBecomeActiveNotification:
      appController.applicationDidBecomeActive(app)
    case UIApplication.willTerminateNotification:
      appController.applicationWillTerminate(app)
    case UIApplication.didReceiveMemoryWarningNotification:
      appController.applicationDidReceiveMemoryWarning(app)
    default:
      break
    }
    #endif
  }
}

#if !RC0_TUANJIE_STUB
extension Rc0TuanjiePlayerUtils: UnityFrameworkListener {
  @objc public func unityDidUnload(_ notification: Notification!) {
    ufw?.unregisterFrameworkListener(self)
    ufw = nil
    isReady = false
    isLoaded = false
  }

  @objc public func unityDidQuit(_ notification: Notification!) {
    unityDidUnload(notification)
  }
}
#endif
