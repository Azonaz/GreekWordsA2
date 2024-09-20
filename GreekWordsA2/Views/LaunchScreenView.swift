//
import SwiftUI

struct LaunchScreenView: View {
    var body: some View {
            ZStack {
                Color.white
                    .ignoresSafeArea()
                VStack {
                    Image(.launchLogo)
                        .resizable()
                        .frame(width: 150, height: 150)
                }
            }
        }
}

#Preview {
    LaunchScreenView()
}
