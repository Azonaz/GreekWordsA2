import SwiftUI

struct GroupsView: View {
    @State private var selectedGroup: VocabularyGroup?
    @ObservedObject var viewModel: GroupsViewModel
    @Environment(\.horizontalSizeClass) var sizeClass

    var body: some View {
        NavigationStack {
            ZStack {
                Color.grayDN
                    .edgesIgnoringSafeArea(.all)
                List {
                    ForEach(viewModel.groups.indices, id: \.self) { index in
                        let group = viewModel.groups[index]
                        NavigationLink(destination: QuizView(viewModel: viewModel, group: group),
                                       tag: group, selection: $selectedGroup) {
                            HStack {
                                Text(group.name)
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
                                            .foregroundColor(index == viewModel.groups.indices.last ?
                                                             Color.whiteDN : Color.greenUniversal.opacity(0.3))
                                            .offset(y: 21)
                                       )
                    }
                }
                .listStyle(PlainListStyle())
                .scrollIndicators(.hidden)
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
            .onChange(of: selectedGroup) { newGroup in
                viewModel.selectedGroup = newGroup
            }
            .onAppear {
                viewModel.load()
            }
            .onSwipeDismiss()
        }
    }
}

#Preview {
    GroupsView(viewModel: GroupsViewModel())
}
