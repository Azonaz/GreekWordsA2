import SwiftUI

struct VerbView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(\.dismiss) private var dismiss
    // mok data
    let verbs: [Verb] = [
        Verb(verb: "γράφω", translation: "write", future: "θα γράψω", past: "έγραψα"),
        Verb(verb: "διαβάζω", translation: "read", future: "θα διαβάσω", past: "διάβασα"),
        Verb(verb: "πηγαίνω", translation: "go", future: "θα πάω", past: "πήγα")
    ]
    @State private var currentIndex: Int = 0
    @State private var resetTrigger = false
    var currentVerb: Verb {
        verbs[currentIndex]
    }

    var body: some View {
        ZStack {
            Color.grayDN
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                HStack(spacing: 8) {
                    Text(currentVerb.translation)
                    Image(systemName: "book.pages")
                }
                .font(sizeClass == .regular ? .largeTitle : .title)
                .foregroundColor(.greenUniversal)
                .tracking(2)
                .shadow(color: .grayUniversal.opacity(0.3), radius: 1, x: 1, y: 1)
                .multilineTextAlignment(.center)
                .padding(.top, sizeClass == .regular ? 90 : 50)

                Spacer()

                FlipCardView(title: "Ενεστώτας", content: currentVerb.verb, resetTrigger: resetTrigger)
                FlipCardView(title: "Στιγμιαίος Μέλλοντας", content: currentVerb.future, resetTrigger: resetTrigger)
                FlipCardView(title: "Αόριστος", content: currentVerb.past, resetTrigger: resetTrigger)

                Spacer()

                Button(action: {
                    if currentIndex < verbs.count - 1 {
                        currentIndex += 1
                    } else {
                        currentIndex = 0
                    }
                    resetTrigger.toggle()
                }, label: {
                    HStack(spacing: 20) {
                        Text("Next verb")
                        Image(systemName: "arrowshape.bounce.forward")
                    }
                    .foregroundColor(.greenUniversal)
                    .font(sizeClass == .regular ? .title2 : .title3)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: .grayUniversal.opacity(0.3), radius: 5, x: 2, y: 2)
                })
                .padding(.horizontal)
            }
           .padding(.bottom, sizeClass == .regular ? 150 : 100)
           .padding(.horizontal, sizeClass == .regular ? 60 : 30)
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: HStack {
            BackButton()
            Text("Check yourself")
                .font(sizeClass == .regular ? .largeTitle : .title)
                .fontWeight(.semibold)
        })
    }
}

struct FlipCardView: View {
    let title: String
    let content: String
    var resetTrigger: Bool

    @State private var isFlipped = false
    @Environment(\.horizontalSizeClass) var sizeClass

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.whiteDN)
                .frame(height: sizeClass == .regular ? 150 : 100)
                .shadow(color: .grayUniversal.opacity(0.5), radius: 5, x: 2, y: 2)
                .overlay(
                    Text(isFlipped ? content : title)
                        .font(sizeClass == .regular ? .title : .title2)
                        .foregroundColor(.blackDN)
                        .multilineTextAlignment(.center)
                        .padding()
                        .rotation3DEffect(
                            .degrees(isFlipped ? 180 : 0),
                            axis: (x: 0, y: 1, z: 0)
                        )
                )
        }
        .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
        .onTapGesture {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                isFlipped.toggle()
            }
        }
        .onChange(of: resetTrigger) { _ in
            isFlipped = false
        }
        .padding(.horizontal)
    }
}

#Preview {
    VerbView()
}
