import SwiftUI
import SwiftData

struct GroupsView: View {
    @ObservedObject var viewModel: GroupsViewModel
    @Environment(\.modelContext) private var modelContext
    @Environment(\.horizontalSizeClass) private var sizeClass

    var body: some View {
        NavigationStack {
            ZStack {
                Color.grayDN
                    .edgesIgnoringSafeArea(.all)

                List {
                    ForEach(Array(viewModel.groups.enumerated()), id: \.element.id) { index, group in
                        NavigationLink {
                            QuizView(viewModel: viewModel, group: group)
                        } label: {
                            HStack {
                                Text(group.nameEn)
                                    .font(sizeClass == .regular ? .title : .title3)
                                Spacer()
                            }
                            .padding(.top, 4)
                        }
                        .listRowInsets(EdgeInsets(top: 10, leading: 8, bottom: 10, trailing: 16))
                        .listRowBackground(Color.whiteDN)
                        .listRowSeparator(.hidden)
                        .overlay(
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(
                                    index == viewModel.groups.indices.last
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
                    Text("Choose a group")
                        .font(sizeClass == .regular ? .largeTitle : .title)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .onAppear {
                Task { await viewModel.syncAndLoadGroups(modelContext: modelContext) }
            }
            .onSwipeDismiss()
        }
    }
}

#Preview {
    GroupsView(viewModel: GroupsViewModel())
        .modelContainer(for: [Word.self, GroupMeta.self, WordProgress.self], inMemory: true)
}
