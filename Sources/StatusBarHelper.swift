import Foundation
import UIKit

// 仅越狱自用私有API，禁止AppStore上架
class StatusBarHelper {
    static let shared = StatusBarHelper()
    private init() {}

    private func getSpringBoardClass() -> AnyClass? {
        return objc_getClass("SBStatusBarDataManager")
    }

    func setGreenWiFi() {
        guard let cls = getSpringBoardClass() else {
            print("❌ SBStatusBarDataManager 类获取失败")
            return
        }
        let sel = NSSelectorFromString("setStatusBarImage:forIdentifier:")
        guard cls.responds(to: sel) else {
            print("❌ setStatusBarImage 方法不存在")
            return
        }
        guard let img = UIImage(named: "greenWifi") else {
            print("❌ 图片缺失，请检查Assets内greenWifi")
            return
        }
        _ = cls.perform(sel, with: img, with: "wifi")
        print("✅ 已调用setStatusBarImage")
    }

    func resetWiFiIcon() {
        guard let cls = getSpringBoardClass() else { return }
        let sel = NSSelectorFromString("setStatusBarImage:forIdentifier:")
        _ = cls.perform(sel, with: nil, with: "wifi")
        print("✅ WiFi图标恢复原生")
    }
}
