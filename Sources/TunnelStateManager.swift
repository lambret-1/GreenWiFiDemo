import Foundation

/// 隧道状态管理器：通过rootless全局共享路径与Tweak通信
class TunnelStateManager: ObservableObject {
    static let shared = TunnelStateManager()
    private init() {}

    /// Dopamine rootless全局可写路径，App与SpringBoard指向同一物理文件，不被沙盒重映射
    private let sharedPath = "/var/jb/tmp/com.demo.greenwifi.state.plist"

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

    /// 写入隧道状态（供Tweak读取）
    func setTunnelActive(_ active: Bool) {
        let dict: [String: Bool] = ["tunnelActive": active]
        let url = URL(fileURLWithPath: sharedPath)
        do {
            let data = try PropertyListSerialization.data(fromPropertyList: dict, format: .xml, options: 0)
            try data.write(to: url)
            log("✅ 已写入 tunnelActive=\(active) 到 \(sharedPath)")
        } catch {
            log("❌ 写入失败: \(error.localizedDescription)")
        }
    }

    /// 读取当前共享状态（用于界面回显）
    func readTunnelActive() -> Bool {
        let url = URL(fileURLWithPath: sharedPath)
        guard let data = try? Data(contentsOf: url),
              let dict = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Bool] else {
            log("⚠️ 状态文件为空或不存在: \(sharedPath)")
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
