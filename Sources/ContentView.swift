import SwiftUI

struct ContentView: View {
    @State private var isGreenWiFiOn = false

    var body: some View {
        VStack(spacing: 20) {
            Text("状态栏绿WiFi Demo")
                .font(.title)
            Button(isGreenWiFiOn ? "关闭绿色WiFi" : "开启绿色WiFi") {
                if isGreenWiFiOn {
                    StatusBarHelper.shared.resetWiFiIcon()
                } else {
                    StatusBarHelper.shared.setGreenWiFi()
                }
                isGreenWiFiOn.toggle()
            }
            .padding()
            .background(.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
