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
                    Text("Ενεστώτας ").verbTitleStyle() + Text(Texts.present)

                    Text("Στιγμιαίος Μέλλοντας ").verbTitleStyle() + Text(Texts.future)

                    Text("Αόριστος ").verbTitleStyle() + Text(Texts.past)
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
