# GreenWiFiDemo

iOS 状态栏绿色 WiFi 图标方案（Dopamine rootless 越狱环境）。

## 架构

```
GreenWiFiDemo App (写入AppGroup标记)
        ↓ tunnelState.plist
GreenWiFiTweak (注入SpringBoard读取标记，绘制绿色WiFi图标)
```

- **App**：通过 AppGroup 共享 plist 写入 `tunnelActive=true/false`，界面内显示调试日志
- **Tweak**：注入 SpringBoard，500ms 轮询读取共享标记，true 时将状态栏 WiFi 图标替换为绿色，false 恢复原生

## AppGroup ID

`group.com.demo.greenwifi`

## 目录结构

```
GreenWiFiDemo/
├── project.yml              # XcodeGen配置
├── GreenWiFiDemo.entitlements  # AppGroup权限
├── Sources/
│   ├── GreenWiFiDemoApp.swift  # @main入口
│   ├── ContentView.swift       # 主界面（开关+日志）
│   ├── TunnelStateManager.swift # AppGroup状态读写
│   ├── StatusBarHelper.swift   # 私有API测试（已弃用，保留参考）
│   └── Info.plist
├── Assets.xcassets/
└── GreenWiFiTweak/             # Theos Tweak工程
    ├── control
    ├── Makefile
    ├── Tweak.x                 # SpringBoard注入代码
    └── layout/Library/Bundles/GreenWiFiTweak.bundle/
        ├── Contents.json
        ├── wifi@2x.png
        └── wifi@3x.png
```

## 构建 App（IPA）

```bash
xcodegen generate
xcodebuild archive -project GreenWiFiDemo.xcodeproj -scheme GreenWiFiDemo \
  -archivePath ./build/GreenWiFiDemo.xcarchive \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO
mkdir -p Payload
cp -R build/GreenWiFiDemo.xcarchive/Products/Applications/GreenWiFiDemo.app Payload/
zip -r GreenWiFiDemo-unsigned.ipa Payload
```

## 构建 Tweak（DEB）

```bash
cd GreenWiFiTweak
make package THEOS_PACKAGE_SCHEME=rootless
```

产物在 `GreenWiFiTweak/packages/` 目录。

## 安装测试

1. Sileo 安装 `GreenWiFiTweak_*.deb`，Respring
2. TrollStore 安装 `GreenWiFiDemo-unsigned.ipa`
3. 打开 App，点击「开启绿色WiFi」
4. 观察状态栏 WiFi 图标是否变绿
5. 点击「关闭绿色WiFi」恢复原生图标

## 环境要求

- iOS 16.0+
- Xcode 15.4+
- XcodeGen
- Theos（构建Tweak）
- Dopamine rootless 越狱设备

## CI/CD

- `build.yml`：自动构建未签名 IPA
- `build-tweak.yml`：自动构建 rootless DEB 包

## 免责声明

本项目使用私有 API 与 Tweak 注入，仅用于越狱设备个人测试，不可上架 App Store。
