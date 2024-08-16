import SwiftUI

struct ChooseTypeView: View {
    @StateObject var groupsViewModel = GroupsViewModel()
    @StateObject var wordDayViewModel = WordsDayViewModel()

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
                            .shadow(color: .black.opacity(0.2), radius: 5, x: 2, y: 2)
                            .font(.title3)
                    }

                    NavigationLink(destination: GroupsView(viewModel: groupsViewModel)) {
                        Text("Words by groups")
                            .foregroundColor(.blackDN)
                            .frame(height: 60)
                            .padding(.horizontal, 60)
                            .background(Color.whiteDN)
                            .cornerRadius(16)
                            .shadow(color: .black.opacity(0.2), radius: 5, x: 2, y: 2)
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

                WordDayView(viewModel: wordDayViewModel)
                    .onAppear {
                        wordDayViewModel.setWordForCurrentDate()
                    }
            }
        }
    }
}

#Preview {
    ChooseTypeView()
}
