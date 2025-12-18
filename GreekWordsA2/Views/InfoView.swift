import SwiftUI

struct InfoView: View {
    var body: some View {
        ZStack {
            Color.grayDN
                .ignoresSafeArea()

            Text("Info")
                .font(.title2)
                .foregroundColor(.blackDN)
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .navigationTitle("Info")
    }
}

#Preview {
    InfoView()
}
