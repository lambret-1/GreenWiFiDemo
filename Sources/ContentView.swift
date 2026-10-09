import SwiftUI

struct ContentView: View {
    @StateObject private var helper = StatusBarHelper.shared
    @State private var isGreenWiFiOn = false

    var body: some View {
        VStack(spacing: 16) {
            Text("状态栏绿WiFi Demo")
                .font(.title2)
                .bold()

            HStack(spacing: 12) {
                Button(isGreenWiFiOn ? "关闭绿色WiFi" : "开启绿色WiFi") {
                    if isGreenWiFiOn {
                        helper.resetWiFiIcon()
                    } else {
                        helper.setGreenWiFi()
                    }
                    isGreenWiFiOn.toggle()
                }
                .padding()
                .background(isGreenWiFiOn ? Color.red : Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)

                Button("清空日志") {
                    helper.clearLogs()
                }
                .padding()
                .background(.gray)
                .foregroundColor(.white)
                .cornerRadius(8)
            }

            Divider()

            Text("调试日志")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

            ScrollView {
                VStack(alignment: .leading, spacing: 4) {
                    if helper.logs.isEmpty {
                        Text("暂无日志，点击上方按钮开始测试")
                            .foregroundColor(.gray)
                            .font(.caption)
                    } else {
                        ForEach(Array(helper.logs.enumerated()), id: \.offset) { _, line in
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
            .background(Color(.systemGray6))
            .cornerRadius(8)
            .padding(.horizontal)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
