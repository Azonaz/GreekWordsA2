import SwiftUI
import SwiftData

struct GroupsView: View {
    @ObservedObject var viewModel: GroupsViewModel
    @Environment(\.horizontalSizeClass) private var sizeClass
    @Query(sort: [SortDescriptor(\GroupMeta.id, order: .forward)]) private var groups: [GroupMeta]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.grayDN
                    .edgesIgnoringSafeArea(.all)

                List {
                    ForEach(Array(groups.enumerated()), id: \.element.id) { index, group in
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
                    Text("Choose a group")
                        .font(sizeClass == .regular ? .largeTitle : .title)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .onSwipeDismiss()
        }
    }
}

#Preview {
    GroupsView(viewModel: GroupsViewModel())
        .modelContainer(for: [Word.self, GroupMeta.self, WordProgress.self], inMemory: true)
}
