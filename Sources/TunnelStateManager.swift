import Foundation

/// 隧道状态管理器：no-sandbox权限下直接读写共享文件，与Tweak通信
class TunnelStateManager: ObservableObject {
    static let shared = TunnelStateManager()
    private init() {}

    /// rootless全局可写路径，no-sandbox后App可直接写入，SpringBoard/Tweak可读
    private let sharedPath = "/var/jb/tmp/com.demo.greenwifi.state.plist"
    private let tweakLogPath = "/var/jb/tmp/greenwifi_tweak.log"

    @Published var logs: [String] = []
    @Published var tweakLogs: [String] = []

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

    /// 读取当前共享状态
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

    /// 读取Tweak侧日志文件
    func readTweakLog() {
        let url = URL(fileURLWithPath: tweakLogPath)
        guard let content = try? String(contentsOf: url, encoding: .utf8) else {
            tweakLogs = ["⚠️ Tweak日志文件不存在，Tweak可能未加载或未安装"]
            return
        }
        tweakLogs = content.components(separatedBy: .newlines).filter { !$0.isEmpty }
    }

    func clearTweakLogs() {
        tweakLogs.removeAll()
    }
}
