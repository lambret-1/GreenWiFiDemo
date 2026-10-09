import Foundation

/// 隧道状态管理器：通过AppGroup共享plist与Tweak通信
class TunnelStateManager: ObservableObject {
    static let shared = TunnelStateManager()
    private init() {}

    private let groupID = "group.com.demo.greenwifi"
    private let fileName = "tunnelState.plist"

    @Published var logs: [String] = []

    private func log(_ msg: String) {
        DispatchQueue.main.async {
            self.logs.append(msg)
            if self.logs.count > 50 {
                self.logs.removeFirst()
            }
        }
        print(msg)
    }

    /// 获取AppGroup共享目录路径
    private func sharedPlistURL() -> URL? {
        guard let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupID) else {
            log("❌ AppGroup获取失败，请确认已开启App Groups能力并勾选 \(groupID)")
            return nil
        }
        return groupURL.appendingPathComponent(fileName)
    }

    /// 写入隧道状态（供Tweak读取）
    func setTunnelActive(_ active: Bool) {
        guard let plistURL = sharedPlistURL() else { return }
        let dict: [String: Bool] = ["tunnelActive": active]
        do {
            let data = try PropertyListSerialization.data(fromPropertyList: dict, format: .xml, options: 0)
            try data.write(to: plistURL)
            log("✅ 已写入 tunnelActive=\(active) 到 \(plistURL.path)")
        } catch {
            log("❌ 写入失败: \(error.localizedDescription)")
        }
    }

    /// 读取当前共享状态（用于界面回显）
    func readTunnelActive() -> Bool {
        guard let plistURL = sharedPlistURL() else { return false }
        guard let data = try? Data(contentsOf: plistURL),
              let dict = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Bool] else {
            log("⚠️ 读取状态文件为空或不存在")
            return false
        }
        let active = dict["tunnelActive"] ?? false
        log("📖 读取到 tunnelActive=\(active)")
        return active
    }

    func clearLogs() {
        logs.removeAll()
    }
}
