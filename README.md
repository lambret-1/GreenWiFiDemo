# GreenWiFiDemo

iOS 状态栏自定义绿色 WiFi 图标测试工程（Dopamine rootless 越狱环境）。

## 用途

测试 `SBStatusBarDataManager.setStatusBarImage:forIdentifier:` 私有 API 在当前 iOS + rootless 环境下是否可用。

- 点击「开启绿色WiFi」→ 尝试将状态栏 WiFi 图标替换为绿色
- 点击「关闭绿色WiFi」→ 恢复原生黑色 WiFi 图标

## 环境要求

- iOS 16.0+
- Xcode 15.4+
- XcodeGen
- Dopamine rootless 越狱设备（TrollStore Lite 侧载安装）

## 构建

```bash
xcodegen generate
xcodebuild archive -project GreenWiFiDemo.xcodeproj -scheme GreenWiFiDemo -archivePath ./build/GreenWiFiDemo.xcarchive
```

## 资源

将绿色 WiFi 透明 PNG 放入 `Assets.xcassets/greenWifi.imageset/`：
- `wifi@2x.png`（40×40px）
- `wifi@3x.png`（60×60px）

## 测试判断

| 结果 | 结论 |
|---|---|
| 状态栏 WiFi 变绿 | 私有 API 可用，问题在主项目逻辑 |
| 控制台打印 `SBStatusBarDataManager 类获取失败` | 当前环境该私有 API 已失效，改用 LiveActivity 方案 |

## 免责声明

本项目使用私有 API，仅用于越狱设备个人测试，不可上架 App Store。
