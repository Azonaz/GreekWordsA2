import SwiftUI

struct ChooseTypeView: View {
    @StateObject var groupsViewModel = GroupsViewModel()
    @Environment(\.modelContext) private var modelContext
    @Environment(\.horizontalSizeClass) var sizeClass

    private var buttonHeight: CGFloat {
        sizeClass == .regular ? 80 : 60
    }

    private var topPadding: CGFloat {
        sizeClass == .regular ? 40 : 20
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.grayDN
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 30) {
                    Text("Greek Words A2")
                        .font(sizeClass == .regular ? .largeTitle : .title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.greenUniversal)
                        .padding(.top, topPadding)

                    Spacer()

                    VStack(spacing: 16) {
                        NavigationLink(destination: GroupsView(viewModel: groupsViewModel)) {
                            Text("Quiz: Words by groups")
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                                .foregroundColor(.blackDN)
                                .frame(height: buttonHeight)
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal, 12)
                                .background(Color.whiteDN)
                                .cornerRadius(16)
                                .shadow(color: .grayUniversal.opacity(0.5), radius: 5, x: 2, y: 2)
                                .font(sizeClass == .regular ? .title : .title3)
                        }

                        NavigationLink(destination: QuizView(viewModel: groupsViewModel, group: nil as GroupMeta?)) {
                            Text("Quiz: Random selection")
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                                .foregroundColor(.blackDN)
                                .frame(height: buttonHeight)
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal, 12)
                                .background(Color.whiteDN)
                                .cornerRadius(16)
                                .shadow(color: .grayUniversal.opacity(0.5), radius: 5, x: 2, y: 2)
                                .font(sizeClass == .regular ? .title : .title3)
                        }

                        NavigationLink(destination: QuizView(viewModel: groupsViewModel, group: nil)) {
                            Text("Quiz: reverse")
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                                .foregroundColor(.blackDN)
                                .frame(height: buttonHeight)
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal, 12)
                                .background(Color.whiteDN)
                                .cornerRadius(16)
                                .shadow(color: .grayUniversal.opacity(0.5), radius: 5, x: 2, y: 2)
                                .font(sizeClass == .regular ? .title : .title3)
                        }
                    }
                    .padding(.horizontal, 20)

                    NavigationLink(destination: TrainingView()) {
                        Text("Training")
                            .foregroundColor(.blackDN)
                            .frame(height: buttonHeight)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 12)
                            .background(Color.whiteDN)
                            .cornerRadius(16)
                            .shadow(color: .grayUniversal.opacity(0.5), radius: 5, x: 2, y: 2)
                            .font(sizeClass == .regular ? .title : .title3)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, topPadding)

                    NavigationLink(destination: VerbView()) {
                        Text("Check verbs")
                            .foregroundColor(.blackDN)
                            .frame(height: buttonHeight)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 12)
                            .background(Color.whiteDN)
                            .cornerRadius(16)
                            .shadow(color: .grayUniversal.opacity(0.5), radius: 5, x: 2, y: 2)
                            .font(sizeClass == .regular ? .title : .title3)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, topPadding)

                    NavigationLink(destination: WordDayGameView()) {
                        Text("Word of the day")
                            .foregroundColor(.blackDN)
                            .frame(height: buttonHeight)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 12)
                            .background(Color.whiteDN)
                            .cornerRadius(16)
                            .shadow(color: .grayUniversal.opacity(0.5), radius: 5, x: 2, y: 2)
                            .font(sizeClass == .regular ? .title : .title3)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, topPadding)

                    Spacer()
                }
                .padding()
            }
        }
        .task {
            await groupsViewModel.syncAndLoadGroups(modelContext: modelContext)
        }
    }
}

#Preview {
    ChooseTypeView()
}
