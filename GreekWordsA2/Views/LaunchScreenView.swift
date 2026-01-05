import SwiftUI

struct LaunchScreenView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    var sizeLogo: CGFloat {
        sizeClass == .regular ? 250 : 150
    }

    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            VStack {
                Image(.launchLogo)
                    .resizable()
                    .frame(width: sizeLogo, height: sizeLogo)
            }
        }
    }
}
