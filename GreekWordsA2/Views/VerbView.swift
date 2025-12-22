import SwiftUI

struct VerbView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(\.verticalSizeClass) var vSizeClass
    @State private var verbs: [Verb] = []
    @State private var currentIndex: Int = 0
    @State private var showInfoSheet = false
    @State private var flippedStates: [Bool] = [false, false, false]
    @State var isEnglish: Bool = Locale.preferredLanguages.first?.hasPrefix("en") == true
    var currentVerb: Verb? {
        guard !verbs.isEmpty else { return nil }
        return verbs[currentIndex]
    }

    private var isPhoneLandscape: Bool {
        UIDevice.current.userInterfaceIdiom == .phone && vSizeClass == .compact
    }

    private var buttonHeight: CGFloat {
        sizeClass == .regular ? 90 : 60
    }

    var body: some View {
        ZStack {
            Color.grayDN
                .edgesIgnoringSafeArea(.all)

            if let currentVerb = currentVerb {
                content(for: currentVerb)
            } else {
                ProgressView()
                    .foregroundColor(.white)
            }
        }
        .onAppear {
            verbs = StatsService.verbsList()
            verbs.shuffle()
            markCurrentVerbSeen()
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(Texts.verbs)
                    .font(sizeClass == .regular ? .largeTitle : .title)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showInfoSheet.toggle()
                }, label: {
                    Image(systemName: "info.circle")
                        .foregroundColor(Color(.greenUniversal))
                        .font(sizeClass == .regular ? .title2 : .title3)
                })
            }
        }
        .sheet(isPresented: $showInfoSheet) {
            VerbTenseView(isShowing: $showInfoSheet)
                .presentationDetents(sizeClass == .regular ? [.height(550)] : [.height(350)])
                .presentationDragIndicator(.visible)
        }
    }

    private func markCurrentVerbSeen() {
        guard let currentVerb else { return }
        StatsService.markVerbSeen(id: currentVerb.id)
    }
}

private extension VerbView {
    func content(for verb: Verb) -> some View {
        Group {
            if isPhoneLandscape {
                HStack(spacing: 16) {
                    VStack(spacing: 80) {
                        translationView(for: verb)

                        nextButton
                    }
                    .frame(maxWidth: .infinity, alignment: .center)

                    VStack(spacing: 10) {
                        verbCards(for: verb)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            } else {
                VStack(spacing: 20) {
                    translationView(for: verb)
                        .padding(.top, sizeClass == .regular ? 90 : 40)

                    Spacer()

                    verbCards(for: verb)

                    Spacer()

                    nextButton
                        .padding(.horizontal)
                }
                .padding(.bottom, sizeClass == .regular ? 150 : 100)
                .padding(.horizontal, sizeClass == .regular ? 60 : 30)
            }
        }
    }

    @ViewBuilder
    func translationView(for verb: Verb) -> some View {
        Text(isEnglish ? verb.enWords : verb.ruWords)
            .font(sizeClass == .regular ? .largeTitle : .title2)
            .foregroundColor(.greenUniversal)
            .tracking(3)
            .shadow(color: .grayUniversal.opacity(0.3), radius: 1, x: 1, y: 1)
            .multilineTextAlignment(.center)
    }

    @ViewBuilder
    func verbCards(for verb: Verb) -> some View {
        VerbCardView(isFlipped: $flippedStates[0],
                     title: "Ενεστώτας",
                     content: verb.verb)
        VerbCardView(isFlipped: $flippedStates[1],
                     title: "Στιγμιαίος Μέλλοντας",
                     content: verb.future)
        VerbCardView(isFlipped: $flippedStates[2],
                     title: "Αόριστος",
                     content: verb.past)
    }

    var nextButton: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.3)) {
                flippedStates = [false, false, false]
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    if currentIndex < verbs.count - 1 {
                        currentIndex += 1
                    } else {
                        verbs.shuffle()
                        currentIndex = 0
                    }
                }
                markCurrentVerbSeen()
            }
        }, label: {
            HStack(spacing: 20) {
                Text(Texts.nextVerb)
                Image(systemName: "arrow.uturn.right")
            }
            .foregroundColor(.greenUniversal)
            .font(sizeClass == .regular ? .title : .title2)
            .padding()
            .frame(maxWidth: .infinity)
            .frame(height: buttonHeight)
            .background(Color.whiteDN)
            .cornerRadius(16)
            .shadow(color: .grayUniversal.opacity(0.3), radius: 5, x: 2, y: 2)
        })
    }
}
