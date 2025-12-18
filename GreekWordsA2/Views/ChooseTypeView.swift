import SwiftUI

struct ChooseTypeView: View {
    @StateObject var groupsVM = GroupsViewModel()
    @Environment(\.modelContext) private var modelContext
    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.scenePhase) private var scenePhase

    private var bHeight: CGFloat {
        sizeClass == .regular ? 80 : 60
    }

    private var topPadding: CGFloat {
        sizeClass == .regular ? 40 : 20
    }

    private var bFont: Font {
        sizeClass == .regular ? .title : .title3
    }

    var body: some View {
        GeometryReader { proxy in
            let isLandscape = proxy.size.width > proxy.size.height
            let isLandscapePhone = (UIDevice.current.userInterfaceIdiom == .phone) && isLandscape

            NavigationStack {
                ZStack {
                    Color.grayDN
                        .edgesIgnoringSafeArea(.all)

                    VStack(spacing: 30) {
                        Text("Greek Words A2")
                            .font(sizeClass == .regular ? .largeTitle : .title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.greenUniversal)

                        if !isLandscapePhone { Spacer() }

                        if isLandscape {
                            HStack(alignment: .top, spacing: 24) {
                                VStack(spacing: 16) {
                                    NavigationLink(destination: GroupsView(viewModel: groupsVM)) {
                                        ChooseButtonLabel(title: "Quiz: Words by groups", height: bHeight, font: bFont)
                                    }

                                    NavigationLink(destination: QuizView(viewModel: groupsVM,
                                                                         group: nil as GroupMeta?)) {
                                        ChooseButtonLabel(title: "Quiz: Random selection", height: bHeight, font: bFont)
                                    }

                                    NavigationLink(destination: QuizView(viewModel: groupsVM, group: nil)) {
                                        ChooseButtonLabel(title: "Quiz: reverse", height: bHeight, font: bFont)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .top)

                                VStack(spacing: 16) {
                                    NavigationLink(destination: TrainingView()) {
                                        ChooseButtonLabel(title: "Training", height: bHeight, font: bFont)
                                    }

                                    NavigationLink(destination: VerbView()) {
                                        ChooseButtonLabel(title: "Check verbs", height: bHeight, font: bFont)
                                    }

                                    NavigationLink(destination: WordDayGameView()) {
                                        ChooseButtonLabel(title: "Word of the day", height: bHeight, font: bFont)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .top)
                            }
                            .padding(.horizontal, 20)
                        } else {
                            VStack(spacing: 16) {
                                NavigationLink(destination: GroupsView(viewModel: groupsVM)) {
                                    ChooseButtonLabel(title: "Quiz: Words by groups", height: bHeight, font: bFont)
                                }

                                NavigationLink(destination: QuizView(viewModel: groupsVM, group: nil as GroupMeta?)) {
                                    ChooseButtonLabel(title: "Quiz: Random selection", height: bHeight, font: bFont)
                                }

                                NavigationLink(destination: QuizView(viewModel: groupsVM, group: nil)) {
                                    ChooseButtonLabel(title: "Quiz: reverse", height: bHeight, font: bFont)
                                }
                            }
                            .padding(.horizontal, 20)

                            VStack(spacing: 16) {
                                NavigationLink(destination: TrainingView()) {
                                    ChooseButtonLabel(title: "Training", height: bHeight, font: bFont)
                                }

                                NavigationLink(destination: VerbView()) {
                                    ChooseButtonLabel(title: "Check verbs", height: bHeight, font: bFont)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, topPadding)

                            NavigationLink(destination: WordDayGameView()) {
                                ChooseButtonLabel(title: "Word of the day", height: bHeight, font: bFont)
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, topPadding)
                        }

                        if !isLandscapePhone { Spacer() }

                        HStack(spacing: 16) {
                            NavigationLink(destination: InfoView()) {
                                ChooseIconButtonLabel(systemName: "info.circle", height: 50)
                            }

                            NavigationLink(destination: StatisticsView()) {
                                ChooseIconButtonLabel(systemName: "chart.pie", height: 50)
                            }

                            NavigationLink(destination: SettingsView()) {
                                ChooseIconButtonLabel(systemName: "gear", height: 50)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 12)
                    }
                    .padding()
                }
            }
            .task { await syncVocabulary() }
            .onChange(of: scenePhase) { _, phase in
                if phase == .active {
                    Task { await syncVocabulary() }
                }
            }
        }
    }

    @MainActor
    private func syncVocabulary() async {
        guard let url = URL(string: WordService().dictionaryUrl) else { return }

        do {
            let service = VocabularySyncService(context: modelContext, remoteURL: url)
            try await service.syncVocabulary()
        } catch {
            print("Synchronisation error: \(error)")
        }
    }
}

#Preview {
    ChooseTypeView()
}
