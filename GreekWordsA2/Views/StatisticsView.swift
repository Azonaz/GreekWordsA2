import SwiftUI

struct StatisticsView: View {
    var body: some View {
        ZStack {
            Color.grayDN
                .ignoresSafeArea()

            Text("Statistics")
                .font(.title2)
                .foregroundColor(.blackDN)
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .navigationTitle("Statistics")
    }
}

#Preview {
    StatisticsView()
}
