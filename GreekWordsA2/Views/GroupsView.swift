import SwiftUI

struct GroupsView: View {
    @State private var selectedGroup: VocabularyGroup?
    @ObservedObject var viewModel: GroupsViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                Color.grayDN
                    .edgesIgnoringSafeArea(.all)
                List(viewModel.groups) { group in
                    NavigationLink(destination: QuizView(viewModel: viewModel, group: group),
                                   tag: group, selection: $selectedGroup) {
                        HStack {
                            Text(group.name)
                            Spacer()
                        }
                    }
                    .listRowInsets(EdgeInsets(top: 10, leading: 8, bottom: 10, trailing: 16))
                    .listRowBackground(Color.whiteDN)
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
            .navigationTitle("Choose a group of words")
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: BackButton())
            .onChange(of: selectedGroup) { newGroup in
                viewModel.selectedGroup = newGroup
            }
            .onAppear {
                viewModel.load()
            }
        }
    }
}

#Preview {
    GroupsView(viewModel: GroupsViewModel())
}
