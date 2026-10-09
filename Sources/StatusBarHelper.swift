import Foundation
import UIKit

// 仅越狱自用私有API，禁止AppStore上架
class StatusBarHelper: ObservableObject {
    static let shared = StatusBarHelper()
    private init() {}

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

    /// 通过IMP直接调用多参数OC类方法
    private func callClassMethod(_ cls: AnyClass, _ sel: Selector, _ arg1: Any?, _ arg2: Any?) {
        guard let method = class_getClassMethod(cls, sel) else {
            log("❌ 类方法获取失败: \(sel)")
            return
        }
        let imp = method_getImplementation(method)
        typealias Function = @convention(c) (AnyClass, Selector, Any?, Any?) -> Unmanaged<AnyObject>?
        let function = unsafeBitCast(imp, to: Function.self)
        _ = function(cls, sel, arg1, arg2)
    }

    /// 方案1: SBStatusBarDataManager.setStatusBarImage:forIdentifier:
    private func trySBStatusBarDataManager(_ img: UIImage?) {
        guard let cls = objc_getClass("SBStatusBarDataManager") as? AnyClass else {
            log("❌ [方案1] SBStatusBarDataManager 类不存在")
            return
        }
        let sel = NSSelectorFromString("setStatusBarImage:forIdentifier:")
        guard class_getClassMethod(cls, sel) != nil else {
            log("❌ [方案1] setStatusBarImage:forIdentifier: 方法不存在")
            return
        }
        callClassMethod(cls, sel, img, "wifi")
        log("✅ [方案1] 已调用 SBStatusBarDataManager.setStatusBarImage")
    }

    /// 方案2: UIApplication 私有 setStatusBarImage:forIdentifier:
    private func tryUIApplication(_ img: UIImage?) {
        let sel = NSSelectorFromString("setStatusBarImage:forIdentifier:")
        guard UIApplication.shared.responds(to: sel) else {
            log("❌ [方案2] UIApplication.setStatusBarImage 不存在")
            return
        }
        UIApplication.shared.perform(sel, with: img, with: "wifi")
        log("✅ [方案2] 已调用 UIApplication.setStatusBarImage")
    }

    /// 方案3: SBStatusBarController 实例方法
    private func trySBStatusBarController(_ img: UIImage?) {
        guard let cls = objc_getClass("SBStatusBarController") as? AnyClass else {
            log("❌ [方案3] SBStatusBarController 类不存在")
            return
        }
        let sel = NSSelectorFromString("setStatusBarImage:forIdentifier:")
        guard class_getInstanceMethod(cls, sel) != nil else {
            log("❌ [方案3] 实例方法 setStatusBarImage 不存在")
            return
        }
        // 尝试获取共享实例
        let sharedSel = NSSelectorFromString("sharedInstance")
        guard let instance = (cls as AnyObject).perform(sharedSel)?.takeUnretainedValue() else {
            log("❌ [方案3] sharedInstance 获取失败")
            return
        }
        instance.perform(sel, with: img, with: "wifi")
        log("✅ [方案3] 已调用 SBStatusBarController.setStatusBarImage")
    }

    func setGreenWiFi() {
        log("—— 开始设置绿色WiFi ——")
        guard let img = UIImage(named: "greenWifi") else {
            log("❌ 图片缺失：Assets中未找到greenWifi")
            return
        }
        log("📷 图片加载成功，尺寸: \(img.size)")
        trySBStatusBarDataManager(img)
        tryUIApplication(img)
        trySBStatusBarController(img)
        log("—— 全部方案执行完毕，请观察状态栏 ——")
    }

    func resetWiFiIcon() {
        log("—— 恢复原生WiFi ——")
        trySBStatusBarDataManager(nil)
        tryUIApplication(nil)
        trySBStatusBarController(nil)
        log("—— 恢复命令已发送 ——")
    }

    func clearLogs() {
        logs.removeAll()
    }
}
