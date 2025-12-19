import SwiftUI
import SwiftData

struct GroupsView: View {
    @ObservedObject var viewModel: GroupsViewModel
    @Environment(\.horizontalSizeClass) private var sizeClass
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\GroupMeta.id, order: .forward)]) private var groups: [GroupMeta]
    @Query private var progress: [WordProgress]
    @Query private var words: [Word]
    let quizMode: QuizMode

    init(viewModel: GroupsViewModel, quizMode: QuizMode = .direct) {
        _viewModel = ObservedObject(wrappedValue: viewModel)
        self.quizMode = quizMode
    }

    private var isEnglish: Bool {
        Locale.preferredLanguages.first?.hasPrefix("en") == true
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.grayDN
                    .edgesIgnoringSafeArea(.all)

                List {
                    ForEach(Array(groups.enumerated()), id: \.element.id) { index, group in
                        NavigationLink {
                            QuizView(viewModel: viewModel, group: group, mode: quizMode)
                        } label: {
                            HStack {
                                formattedTitle(for: group)
                                    .font(sizeClass == .regular ? .title : .title3)
                                Spacer()
                            }
                            .padding(.top, 4)
                        }
                        .simultaneousGesture(
                            TapGesture().onEnded {
                                markGroupOpened(group)
                            }
                        )
                        .listRowInsets(EdgeInsets(top: 10, leading: 8, bottom: 10, trailing: 16))
                        .listRowBackground(Color.whiteDN)
                        .listRowSeparator(.hidden)
                        .overlay(
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(
                                    index == groups.indices.last
                                    ? Color.whiteDN
                                    : Color.greenUniversal.opacity(0.3)
                                )
                                .offset(y: 21)
                        )
                    }
                }
                .listStyle(.plain)
                .scrollIndicators(.hidden)
                .scrollContentBackground(.hidden)
                .padding(.horizontal)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.whiteDN)
                )
                .padding()
                .foregroundColor(.blackDN)
            }
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    BackButton()
                }
                ToolbarItem(placement: .principal) {
                    Text(Texts.categories)
                        .font(sizeClass == .regular ? .largeTitle : .title)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .onSwipeDismiss()
        }
    }

    private func formattedTitle(for group: GroupMeta) -> some View {
        let total = words.filter { $0.groupID == group.id }.count
        let seen = progress.filter { $0.compositeID.hasPrefix("\(group.id)_") && $0.seen }.count
        let name = isEnglish ? group.nameEn : group.nameRu
        return Text(name) + Text(" (\(seen)/\(total))").foregroundColor(.blackDN.opacity(0.6))
    }

    private func markGroupOpened(_ group: GroupMeta) {
        let targetID = group.id

        do {
            let descriptor = FetchDescriptor<GroupMeta>(
                predicate: #Predicate { $0.id == targetID }
            )

            if let meta = try modelContext.fetch(descriptor).first, !meta.opened {
                meta.opened = true
            }

            if modelContext.hasChanges {
                try modelContext.save()
            }
        } catch {
            print("Failed to mark group opened: \(error)")
        }
    }
}

#Preview {
    GroupsView(viewModel: GroupsViewModel())
        .modelContainer(for: [Word.self, GroupMeta.self, WordProgress.self], inMemory: true)
}
