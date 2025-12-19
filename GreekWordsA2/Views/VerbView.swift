import SwiftUI

struct VerbView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    @State private var verbs: [Verb] = []
    @State private var currentIndex: Int = 0
    @State private var showInfoSheet = false
    @State private var flippedStates: [Bool] = [false, false, false]
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
                        .font(sizeClass == .regular ? .largeTitle : .title2)
                        .foregroundColor(.greenUniversal)
                        .tracking(3)
                        .shadow(color: .grayUniversal.opacity(0.3), radius: 1, x: 1, y: 1)
                        .multilineTextAlignment(.center)
                        .padding(.top, sizeClass == .regular ? 90 : 40)

                    Spacer()

                    VerbCardView(isFlipped: $flippedStates[0],
                                 title: "Ενεστώτας",
                                 content: currentVerb.verb)
                    VerbCardView(isFlipped: $flippedStates[1],
                                 title: "Στιγμιαίος Μέλλοντας",
                                 content: currentVerb.future)
                    VerbCardView(isFlipped: $flippedStates[2],
                                 title: "Αόριστος",
                                 content: currentVerb.past)

                    Spacer()

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
                        .frame(height: sizeClass == .regular ? 90 : 60)
                        .background(Color.whiteDN)
                        .cornerRadius(16)
                        .shadow(color: .grayUniversal.opacity(0.3), radius: 5, x: 2, y: 2)
                    })
                    .padding(.horizontal)
                }
                .padding(.bottom, sizeClass == .regular ? 150 : 100)
                .padding(.horizontal, sizeClass == .regular ? 60 : 30)
            } else {
                ProgressView()
                    .foregroundColor(.white)
            }
        }
        .onAppear {
            verbs = loadVerbs()
            verbs.shuffle()
        }
        .onSwipeDismiss()
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackButton()
            }
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

    func loadVerbs() -> [Verb] {
        guard let url = Bundle.main.url(forResource: "verbs", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([Verb].self, from: data) else {
            return []
        }
        return decoded
    }
}
