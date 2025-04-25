import SwiftUI

struct VerbTenseView: View {
    @Binding var isShowing: Bool

    var body: some View {
        ZStack {
            Color.grayDN
                .edgesIgnoringSafeArea(.all)

            ScrollView {
                Text("Verb tenses")
                    .font(.title3)
                    .foregroundColor(.greenUniversal)
                    .padding(.top)
                    .padding(.bottom, 20)

                VStack(alignment: .leading, spacing: 10) {
                    // swiftlint:disable line_length

                    Text("Ενεστώτας ")
                        .fontWeight(.bold)
                        .foregroundColor(.greenUniversal) +
                    Text("can express things that are happening now, things that happen regularly, or general truths. It's one of the basic tenses used to talk about what is true or happening right now.")

                    Text("Στιγμιαίος Μέλλοντας ")
                        .fontWeight(.bold)
                        .foregroundColor(.greenUniversal) +
                    Text("is used to express a single completed action that will happen in the future. It is similar to the Simple Future Tense in English.")

                    Text("Αόριστος ")
                        .fontWeight(.bold)
                        .foregroundColor(.greenUniversal) +
                    Text("is a past tense used to describe actions that were completed in the past, without indicating when exactly the action occurred or how long it lasted. This time it captures an event that has happened only once, an action that ended in the past. It's similar to the Simple Past Tense in English.")
                    // swiftlint:enable line_length
                }
                .foregroundColor(.blackDN)
                .padding(.horizontal)
            }
            .frame(maxHeight: .infinity)
            .padding(.horizontal)
        }
    }
}

#Preview {
    VerbTenseView(isShowing: .constant(true))
}
