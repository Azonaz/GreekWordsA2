import SwiftUI

struct ChooseTypeView: View {
    @StateObject var groupsViewModel = GroupsViewModel()
    @StateObject var wordDayViewModel = WordsDayViewModel()
    @State private var showWord = false
    @State private var rotation: Double = 0
    @State private var isLabelVisible = true
    @State private var isWordAlreadySolvedForToday = false
    private let circleDiameter: CGFloat = 100 * 2.7

    var body: some View {
        NavigationStack {
            ZStack {
                Color.grayDN
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 20) {
                    Text("Greek Words A2")
                        .font(.title2)
                        .foregroundColor(.greenUniversal)
                        .padding(.bottom, 16)

                    NavigationLink(destination: QuizView(viewModel: groupsViewModel, group: nil)) {
                        Text("Random selection")
                            .foregroundColor(.blackDN)
                            .frame(height: 60)
                            .padding(.horizontal, 60)
                            .background(Color.whiteDN)
                            .cornerRadius(16)
                            .shadow(color: .grayUniversal.opacity(0.5), radius: 5, x: 2, y: 2)
                            .font(.title3)
                    }

                    NavigationLink(destination: GroupsView(viewModel: groupsViewModel)) {
                        Text("Words by groups")
                            .foregroundColor(.blackDN)
                            .frame(height: 60)
                            .padding(.horizontal, 61)
                            .background(Color.whiteDN)
                            .cornerRadius(16)
                            .shadow(color: .grayUniversal.opacity(0.5), radius: 5, x: 2, y: 2)
                            .font(.title3)
                    }
                    Spacer()
                }
                .padding()

                HStack(spacing: 10) {
                    Image(systemName: "pencil.and.scribble")
                        .foregroundColor(.blackDN.opacity(0.4))
                        .font(.title)

                    Text("Word of the day")
                        .font(.title2)
                        .foregroundColor(.green)
                }
                .padding(.bottom, 40)

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
                .padding(.top, 350)

                WordDayView(viewModel: wordDayViewModel, isWordAlreadySolvedForToday: $isWordAlreadySolvedForToday)
                    .onAppear {
                        wordDayViewModel.setWordForCurrentDate()
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
                                .font(.largeTitle)
                                .padding(.bottom, 50)
                                .padding(.trailing, 10)
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
