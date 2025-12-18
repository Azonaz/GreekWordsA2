import SwiftUI

struct SettingsView: View {
    var body: some View {
        ZStack {
            Color.grayDN
                .ignoresSafeArea()

            Text("Settings")
                .font(.title2)
                .foregroundColor(.blackDN)
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    SettingsView()
}
