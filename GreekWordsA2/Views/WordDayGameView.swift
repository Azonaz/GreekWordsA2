import SwiftUI

struct WordDayGameView: View {
    @StateObject private var viewModel = WordsDayViewModel()
    @State private var isWordAlreadySolvedForToday = false
    @State private var showWord = false
    @State private var rotation: Double = 0
    @State private var isLabelVisible = true
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.horizontalSizeClass) private var sizeClass
    @Environment(\.verticalSizeClass) private var vSizeClass

    private var circleDiameter: CGFloat {
        sizeClass == .regular ? 180 * 2.7 : 260
    }

    private var isPhoneLandscape: Bool {
        UIDevice.current.userInterfaceIdiom == .phone && vSizeClass == .compact
    }

    var body: some View {
        ZStack {
            Color.grayDN
                .edgesIgnoringSafeArea(.all)

            VStack {
                Spacer()

                ZStack {
                    if showWord {
                        Circle()
                            .frame(width: circleDiameter, height: circleDiameter)
                            .foregroundColor(.whiteDN)
                            .shadow(color: .grayUniversal.opacity(0.5), radius: 5, x: 2, y: 2)
                            .overlay(
                                Text(viewModel.enWord)
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

                    WordDayView(viewModel: viewModel, isWordAlreadySolvedForToday: $isWordAlreadySolvedForToday)
                        .opacity(showWord ? 0 : 1)
                        .rotation3DEffect(
                            .degrees(rotation),
                            axis: (x: 0, y: 1, z: 0)
                        )
                        .animation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0.5),
                                   value: rotation)
                }
                .frame(maxWidth: isPhoneLandscape ? circleDiameter : .infinity)
                .frame(height: sizeClass == .regular ? 520 : 420)
                .padding(.horizontal)
                .overlay(alignment: isPhoneLandscape ? Alignment(horizontal: .trailing, vertical: .center)
                         : .bottomTrailing) {
                    if !isWordAlreadySolvedForToday && isLabelVisible {
                        Label("", systemImage: "questionmark.circle")
                            .foregroundColor(.greenUniversal.opacity(0.5))
                            .font(sizeClass == .regular ? .system(size: 36) : .largeTitle)
                            .padding(.bottom, isPhoneLandscape ? 0 : (sizeClass == .regular ? 30 : 10))
                            .padding(.trailing, isPhoneLandscape ? 0 : (sizeClass == .regular ? 10 : 0))
                            .offset(x: isPhoneLandscape ? 100 : 0, y: isPhoneLandscape ? 80 : 0)
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

                Spacer()
            }
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(Texts.wordDay)
                    .font(sizeClass == .regular ? .largeTitle : .title)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .onAppear {
            viewModel.setWordForCurrentDate()
        }
        .onChange(of: scenePhase) {
            guard scenePhase == .active else { return }

            viewModel.setWordForCurrentDate()
            let today = viewModel.getCurrentDate()
            isWordAlreadySolvedForToday = StatsService.isWordDayCompleted(dateString: today)
        }
    }
}
