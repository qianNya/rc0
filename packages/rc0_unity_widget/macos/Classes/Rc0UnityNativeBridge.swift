import Cocoa
import FlutterMacOS

@objc public class Rc0UnityNativeBridge: NSObject {
  @objc public static var eventSink: FlutterEventSink?

  @objc public static func sendToUnity(_ json: String) {
    Rc0UnityMacPlayer.sendToUnity(json)
  }

  @objc public static func sendToFlutter(_ json: String) {
    eventSink?(json)
  }
}
