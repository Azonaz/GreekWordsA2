import SwiftUI

struct InfoView: View {
    var body: some View {
        ZStack {
            Color.grayDN
                .ignoresSafeArea()

            Text(Texts.information)
                .font(.title2)
                .foregroundColor(.blackDN)
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .navigationTitle(Texts.information)
    }
}

#Preview {
    InfoView()
}
