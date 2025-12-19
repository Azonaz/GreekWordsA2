import SwiftUI

struct VerbTenseView: View {
    @Binding var isShowing: Bool
    @Environment(\.horizontalSizeClass) var sizeClass
    var isLargeScreen: Bool {
        UIDevice.current.userInterfaceIdiom == .pad || sizeClass == .regular
    }

    var body: some View {
        ZStack {
            Color.grayDN
                .edgesIgnoringSafeArea(.all)

            ScrollView {
                Text("Verb tenses")
                    .font(isLargeScreen ? .title : .title3)
                    .foregroundColor(.greenUniversal)
                    .padding(.top)
                    .padding(.bottom, 20)

                VStack(alignment: .leading, spacing: 10) {
                    // swiftlint:disable line_length
                    Text("Ενεστώτας ").verbTitleStyle() +
                    Text("shows what is happening now, what happens often, or what is always true. It is like Simple Present in English.")

                    Text("Στιγμιαίος Μέλλοντας ").verbTitleStyle() +
                    Text("shows something that will happen once in the future and be finished. It's like Simple Future in English.")

                    Text("Αόριστος ").verbTitleStyle() +
                    Text("shows something that happened once in the past and is finished. It doesn't say when or how long. It's like Simple Past in English.")
                    // swiftlint:enable line_length
                }
                .foregroundColor(.blackDN)
                .font(isLargeScreen ? .title2 : .body)
                .padding(.horizontal)
            }
            .frame(maxHeight: .infinity)
            .padding(.horizontal)
        }
    }
}
