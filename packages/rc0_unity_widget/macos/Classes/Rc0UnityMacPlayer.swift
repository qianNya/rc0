import Cocoa
import FlutterMacOS
import Network

/// Resolves and launches the exported macOS Unity/Tuanjie standalone player.
enum Rc0UnityMacPlayer {
  static let ipcPort = 19721
  private static var process: Process?
  private static var ipcClient: Rc0UnityMacIpcClient?

  static var isLinked: Bool {
    resolvePlayerPath() != nil
  }

  static func resolvePlayerPath() -> String? {
    if let env = ProcessInfo.processInfo.environment["RC0_UNITY_PLAYER_PATH"],
       FileManager.default.fileExists(atPath: env) {
      return env
    }

    let pluginBundle = Bundle(for: Rc0UnityWidgetPlugin.self)

    if let bundlePath = pluginBundle.path(forResource: "Rc0UnityPlayer", ofType: "bundle"),
       let resourceBundle = Bundle(path: bundlePath),
       let path = resourceBundle.path(forResource: "rc0_runtime", ofType: "app") {
      return path
    }

    if let path = pluginBundle.path(
      forResource: "rc0_runtime",
      ofType: "app",
      inDirectory: "UnityPlayer"
    ) {
      return path
    }

    let devPath = pluginBundle.bundleURL
      .deletingLastPathComponent()
      .appendingPathComponent("UnityPlayer/rc0_runtime.app")
      .path
    if FileManager.default.fileExists(atPath: devPath) {
      return devPath
    }

    if let resources = Bundle.main.resourcePath {
      let embedded = "\(resources)/UnityPlayer/rc0_runtime.app"
      if FileManager.default.fileExists(atPath: embedded) {
        return embedded
      }
    }

    return nil
  }

  static func ensureRunning(completion: @escaping (Bool) -> Void) {
    if ipcClient?.isConnected == true {
      completion(true)
      return
    }

    if Rc0UnityMacIpcClient.probe(port: ipcPort) {
      connectIpc(completion: completion)
      return
    }

    guard let appPath = resolvePlayerPath() else {
      completion(false)
      return
    }

    let executable = "\(appPath)/Contents/MacOS/rc0_runtime"
    guard FileManager.default.isExecutableFile(atPath: executable) else {
      NSLog("[RC0Unity] macOS player executable missing: %@", executable)
      completion(false)
      return
    }

    if process?.isRunning == true {
      waitForIpc(completion: completion)
      return
    }

    let task = Process()
    task.executableURL = URL(fileURLWithPath: executable)
    task.currentDirectoryURL = URL(fileURLWithPath: appPath)
    var env = ProcessInfo.processInfo.environment
    env["RC0_UNITY_IPC_PORT"] = "\(ipcPort)"
    task.environment = env

    do {
      try task.run()
      process = task
      NSLog("[RC0Unity] Launched macOS player: %@", appPath)
      waitForIpc(completion: completion)
    } catch {
      NSLog("[RC0Unity] Failed to launch macOS player: %@", error.localizedDescription)
      completion(false)
    }
  }

  private static func waitForIpc(completion: @escaping (Bool) -> Void) {
    DispatchQueue.global(qos: .userInitiated).async {
      let deadline = Date().addingTimeInterval(30)
      while Date() < deadline {
        if Rc0UnityMacIpcClient.probe(port: ipcPort) {
          connectIpc(completion: completion)
          return
        }
        Thread.sleep(forTimeInterval: 0.25)
      }
      DispatchQueue.main.async { completion(false) }
    }
  }

  private static func connectIpc(completion: @escaping (Bool) -> Void) {
    let client = Rc0UnityMacIpcClient(port: ipcPort)
    client.onMessage = { json in
      Rc0UnityNativeBridge.eventSink?(json)
    }
    client.connect { ok in
      if ok {
        ipcClient = client
      }
      completion(ok)
    }
  }

  static func sendToUnity(_ json: String) {
    if ipcClient?.isConnected != true {
      ensureRunning { ok in
        if ok { ipcClient?.send(json) }
      }
      return
    }
    ipcClient?.send(json)
  }

  static func shutdown() {
    ipcClient?.disconnect()
    ipcClient = nil
    if let task = process, task.isRunning {
      task.terminate()
    }
    process = nil
  }
}

final class Rc0UnityMacIpcClient {
  private let port: Int
  private var connection: NWConnection?
  private(set) var isConnected = false
  var onMessage: ((String) -> Void)?

  init(port: Int) {
    self.port = port
  }

  static func probe(port: Int) -> Bool {
    let fd = socket(AF_INET, SOCK_STREAM, 0)
    guard fd >= 0 else { return false }
    defer { close(fd) }

    var addr = sockaddr_in()
    addr.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
    addr.sin_family = sa_family_t(AF_INET)
    addr.sin_port = in_port_t(UInt16(port).bigEndian)
    addr.sin_addr.s_addr = inet_addr("127.0.0.1")

    let result = withUnsafePointer(to: &addr) {
      $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
        connect(fd, $0, socklen_t(MemoryLayout<sockaddr_in>.size))
      }
    }
    return result == 0
  }

  func connect(completion: @escaping (Bool) -> Void) {
    let host = NWEndpoint.Host("127.0.0.1")
    let port = NWEndpoint.Port(integerLiteral: NWEndpoint.Port.IntegerLiteralType(self.port))
    let conn = NWConnection(host: host, port: port, using: .tcp)
    connection = conn

    conn.stateUpdateHandler = { [weak self] state in
      switch state {
      case .ready:
        self?.isConnected = true
        self?.receiveLoop()
        DispatchQueue.main.async { completion(true) }
      case .failed, .cancelled:
        self?.isConnected = false
        DispatchQueue.main.async { completion(false) }
      default:
        break
      }
    }
    conn.start(queue: .global(qos: .userInitiated))
  }

  func send(_ json: String) {
    guard let connection, isConnected else { return }
    let payload = (json + "\n").data(using: .utf8) ?? Data()
    connection.send(content: payload, completion: .contentProcessed { _ in })
  }

  func disconnect() {
    connection?.cancel()
    connection = nil
    isConnected = false
  }

  private func receiveLoop() {
    connection?.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] data, _, _, error in
      guard let self else { return }
      if let data, !data.isEmpty, let text = String(data: data, encoding: .utf8) {
        for line in text.split(separator: "\n", omittingEmptySubsequences: true) {
          self.onMessage?(String(line))
        }
      }
      if error == nil {
        self.receiveLoop()
      }
    }
  }
}
