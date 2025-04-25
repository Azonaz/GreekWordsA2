import SwiftUI

struct VerbView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(\.dismiss) private var dismiss
    @State private var verbs: [Verb] = []
    @State private var currentIndex: Int = 0
    @State private var resetTrigger = false
    @State private var showInfoSheet = false
    var currentVerb: Verb? {
        guard !verbs.isEmpty else { return nil }
        return verbs[currentIndex]
    }

    var body: some View {
        ZStack {
            Color.grayDN
                .edgesIgnoringSafeArea(.all)

            if let currentVerb = currentVerb {
                VStack(spacing: 20) {
                    Text(currentVerb.translation)
                        .font(sizeClass == .regular ? .largeTitle : .title)
                        .foregroundColor(.greenUniversal)
                        .tracking(3)
                        .shadow(color: .grayUniversal.opacity(0.3), radius: 1, x: 1, y: 1)
                        .multilineTextAlignment(.center)
                        .padding(.top, sizeClass == .regular ? 90 : 50)

                    Spacer()

                    VerbCardView(title: "Ενεστώτας", content: currentVerb.verb, resetTrigger: resetTrigger)
                    VerbCardView(title: "Στιγμιαίος Μέλλοντας", content: currentVerb.future, resetTrigger: resetTrigger)
                    VerbCardView(title: "Αόριστος", content: currentVerb.past, resetTrigger: resetTrigger)

                    Spacer()

                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            if currentIndex < verbs.count - 1 {
                                currentIndex += 1
                            } else {
                                verbs.shuffle()
                                currentIndex = 0
                            }
                            resetTrigger.toggle()
                        }
                    }, label: {
                        HStack(spacing: 20) {
                            Text("Next verb")
                            Image(systemName: "arrow.uturn.right")
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
            } else {
                ProgressView("Loading...")
                    .foregroundColor(.white)
            }
        }
        .onAppear {
            verbs = loadVerbs()
            verbs.shuffle()
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackButton()
            }
            ToolbarItem(placement: .principal) {
                Text("Check yourself")
                    .font(sizeClass == .regular ? .largeTitle : .title)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showInfoSheet.toggle()
                }, label: {
                    Image(systemName: "info.bubble")
                        .foregroundColor(Color(.greenUniversal))
                })
            }
        }
        .sheet(isPresented: $showInfoSheet) {
            VerbTenseView(isShowing: $showInfoSheet)
                .presentationDetents([.height(500)])
                .presentationDragIndicator(.visible)
        }
    }

    func loadVerbs() -> [Verb] {
        guard let url = Bundle.main.url(forResource: "verbs", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([Verb].self, from: data) else {
            return []
        }
        return decoded
    }
}

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
                    .padding(.bottom, 10)

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
    VerbView()
}
