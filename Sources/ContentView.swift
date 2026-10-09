import SwiftUI

struct ContentView: View {
    @StateObject private var stateManager = TunnelStateManager.shared
    @State private var isGreenWiFiOn = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("状态栏绿WiFi Demo")
                    .font(.title2)
                    .bold()

                Text("no-sandbox权限 + 共享文件，由Tweak绘制状态栏图标")
                    .font(.caption)
                    .foregroundColor(.gray)

                HStack(spacing: 12) {
                    Button(isGreenWiFiOn ? "关闭绿色WiFi" : "开启绿色WiFi") {
                        if isGreenWiFiOn {
                            stateManager.setTunnelActive(false)
                        } else {
                            stateManager.setTunnelActive(true)
                        }
                        isGreenWiFiOn.toggle()
                    }
                    .padding()
                    .background(isGreenWiFiOn ? Color.red : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)

                    Button("读取状态") {
                        _ = stateManager.readTunnelActive()
                    }
                    .padding()
                    .background(.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }

                Divider()

                Text("App日志")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)

                ScrollView {
                    VStack(alignment: .leading, spacing: 4) {
                        if stateManager.logs.isEmpty {
                            Text("暂无日志")
                                .foregroundColor(.gray)
                                .font(.caption)
                        } else {
                            ForEach(Array(stateManager.logs.enumerated()), id: \.offset) { _, line in
                                Text(line)
                                    .font(.system(.caption, design: .monospaced))
                                    .foregroundColor(line.contains("❌") ? .red : (line.contains("✅") ? .green : .primary))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 120)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal)

                HStack(spacing: 12) {
                    Button("读取Tweak日志") {
                        stateManager.readTweakLog()
                    }
                    .padding()
                    .background(.orange)
                    .foregroundColor(.white)
                    .cornerRadius(8)

                    Button("清空App日志") {
                        stateManager.clearLogs()
                    }
                    .padding()
                    .background(.gray)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }

                Text("Tweak日志")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)

                ScrollView {
                    VStack(alignment: .leading, spacing: 4) {
                        if stateManager.tweakLogs.isEmpty {
                            Text("点击上方「读取Tweak日志」查看")
                                .foregroundColor(.gray)
                                .font(.caption)
                        } else {
                            ForEach(Array(stateManager.tweakLogs.enumerated()), id: \.offset) { _, line in
                                Text(line)
                                    .font(.system(.caption2, design: .monospaced))
                                    .foregroundColor(line.contains("失败") ? .red : (line.contains("成功") || line.contains("已设置") ? .green : .primary))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 150)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal)

                Text("共享路径: /var/jb/tmp/com.demo.greenwifi.state.plist")
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundColor(.gray)
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
