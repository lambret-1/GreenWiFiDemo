import Foundation
import UIKit

// 仅越狱自用私有API，禁止AppStore上架
class StatusBarHelper {
    static let shared = StatusBarHelper()
    private init() {}

    private func getSpringBoardClass() -> AnyClass? {
        return objc_getClass("SBStatusBarDataManager") as? AnyClass
    }

    /// 通过IMP直接调用多参数OC类方法，规避Swift performSelector多参数限制
    private func callClassMethod(_ cls: AnyClass, _ sel: Selector, _ arg1: Any?, _ arg2: Any?) {
        guard let method = class_getClassMethod(cls, sel) else {
            print("❌ 方法获取失败: \(sel)")
            return
        }
        let imp = method_getImplementation(method)
        typealias Function = @convention(c) (AnyClass, Selector, Any?, Any?) -> Unmanaged<AnyObject>?
        let function = unsafeBitCast(imp, to: Function.self)
        _ = function(cls, sel, arg1, arg2)
    }

    func setGreenWiFi() {
        guard let cls = getSpringBoardClass() else {
            print("❌ SBStatusBarDataManager 类获取失败")
            return
        }
        let sel = NSSelectorFromString("setStatusBarImage:forIdentifier:")
        guard class_getClassMethod(cls, sel) != nil else {
            print("❌ setStatusBarImage 方法不存在")
            return
        }
        guard let img = UIImage(named: "greenWifi") else {
            print("❌ 图片缺失，请检查Assets内greenWifi")
            return
        }
        callClassMethod(cls, sel, img, "wifi")
        print("✅ 已调用setStatusBarImage")
    }

    func resetWiFiIcon() {
        guard let cls = getSpringBoardClass() else { return }
        let sel = NSSelectorFromString("setStatusBarImage:forIdentifier:")
        callClassMethod(cls, sel, nil, "wifi")
        print("✅ WiFi图标恢复原生")
    }
}
