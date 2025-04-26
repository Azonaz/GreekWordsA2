import SwiftUI

struct ChooseTypeView: View {
    @StateObject var groupsViewModel = GroupsViewModel()
    @StateObject var wordDayViewModel = WordsDayViewModel()
    @State private var showWord = false
    @State private var rotation: Double = 0
    @State private var isLabelVisible = true
    @State private var isWordAlreadySolvedForToday = false
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.horizontalSizeClass) var sizeClass

    private var circleDiameter: CGFloat {
        sizeClass == .regular ? 150 * 2.7 : 100 * 2.7
    }

    private var buttonHeight: CGFloat {
        sizeClass == .regular ? 80 : 60
    }

    private var buttonPaddingHorizontal: CGFloat {
        sizeClass == .regular ? 100 : 60
    }

    private var topPadding: CGFloat {
        sizeClass == .regular ? 40 : 20
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.grayDN
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 20) {
                    Text("Greek Words Quiz A2")
                        .font(sizeClass == .regular ? .largeTitle : .title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.greenUniversal)
                        .padding(.top, topPadding)

                    HStack(spacing: 16) {
                        NavigationLink(destination: QuizView(viewModel: groupsViewModel, group: nil)) {
                            Text("Random\nselection")
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                                .foregroundColor(.blackDN)
                                .frame(height: buttonHeight + 20)
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal, 12)
                                .background(Color.whiteDN)
                                .cornerRadius(16)
                                .shadow(color: .grayUniversal.opacity(0.5), radius: 5, x: 2, y: 2)
                                .font(sizeClass == .regular ? .title : .title3)
                        }

                        NavigationLink(destination: GroupsView(viewModel: groupsViewModel)) {
                            Text("Words by\ngroups")
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                                .foregroundColor(.blackDN)
                                .frame(height: buttonHeight + 20)
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal, 12)
                                .background(Color.whiteDN)
                                .cornerRadius(16)
                                .shadow(color: .grayUniversal.opacity(0.5), radius: 5, x: 2, y: 2)
                                .font(sizeClass == .regular ? .title : .title3)
                        }
                    }
                    .padding(.horizontal, 20)

                    Text("Verbs A2")
                        .font(sizeClass == .regular ? .largeTitle : .title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.greenUniversal)
                        .padding(.top, topPadding)

                    NavigationLink(destination: VerbView()) {
                        Text("Check verbs")
                            .foregroundColor(.blackDN)
                            .frame(height: buttonHeight)
                            .padding(.horizontal, buttonPaddingHorizontal)
                            .background(Color.whiteDN)
                            .cornerRadius(16)
                            .shadow(color: .grayUniversal.opacity(0.5), radius: 5, x: 2, y: 2)
                            .font(sizeClass == .regular ? .title : .title3)
                    }
                    Spacer()
                }
                .padding()

                HStack(spacing: 10) {
                    Image(systemName: "pencil.and.scribble")
                        .foregroundColor(.blackDN.opacity(0.4))
                        .font(.title)

                    Text("Word of the day")
                        .font(sizeClass == .regular ? .title : .title2)
                        .foregroundColor(.green)
                }
                .padding(.bottom, sizeClass == .regular ? 80 : 40)

                ZStack {
                    if showWord {
                        Circle()
                            .frame(width: circleDiameter, height: circleDiameter)
                            .foregroundColor(.whiteDN)
                            .shadow(color: .grayUniversal.opacity(0.5), radius: 5, x: 2, y: 2)
                            .overlay(
                                Text(wordDayViewModel.enWord)
                                    .font(.largeTitle)
                                    .tracking(3)
                                    .foregroundColor(.blackDN)
                            )
                            .transition(.opacity)
                            .rotation3DEffect(
                                .degrees(rotation + 180),
                                axis: (x: 0, y: 1, z: 0)
                            )
                            .animation(.spring(response: 0.6, dampingFraction: 0.8,
                                               blendDuration: 0.5), value: rotation)
                    }
                }
                .padding(.top, sizeClass == .regular ? 470 : 370)

                WordDayView(viewModel: wordDayViewModel, isWordAlreadySolvedForToday: $isWordAlreadySolvedForToday)
                    .onAppear {
                        wordDayViewModel.setWordForCurrentDate()
                    }
                    .onChange(of: scenePhase) { newPhase in
                        if newPhase == .active {
                            let today = wordDayViewModel.getCurrentDate()
                            wordDayViewModel.setWordForCurrentDate()
                            if today != UserDefaults.standard.string(forKey: "lastPlayedDate") {
                                isWordAlreadySolvedForToday = false
                            }
                        }
                    }
                    .opacity(showWord ? 0 : 1)
                    .rotation3DEffect(
                        .degrees(rotation),
                        axis: (x: 0, y: 1, z: 0)
                    )
                    .animation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0.5), value: rotation)

                if !isWordAlreadySolvedForToday && isLabelVisible {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Label("", systemImage: "questionmark.circle")
                                .foregroundColor(.blackDN.opacity(0.5))
                                .font(sizeClass == .regular ? .system(size: 36) : .largeTitle)
                                .padding(.bottom, sizeClass == .regular ? 100 : 50)
                                .padding(.trailing, sizeClass == .regular ? 60 : 10)
                                .onTapGesture {
                                    withAnimation {
                                        rotation += 180
                                        showWord.toggle()
                                        isLabelVisible = false
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                                        isLabelVisible = true
                                        withAnimation {
                                            rotation += 180
                                            showWord.toggle()
                                        }
                                    }
                                }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ChooseTypeView()
}
