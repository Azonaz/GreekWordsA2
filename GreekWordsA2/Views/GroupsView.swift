import SwiftUI

struct GroupsView: View {
    @StateObject var groupsViewModel = GroupsViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Color.grayDN
                    .edgesIgnoringSafeArea(.all)
                List(groupsViewModel.groups) { group in
                    NavigationLink(destination: Text("Detail View for \(group.name)")) {
                        HStack {
                            Text(group.name)
                            Spacer()
                        }
                    }
                    .listRowInsets(EdgeInsets(top: 10, leading: 8, bottom: 10, trailing: 16))
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
            .onAppear {
                groupsViewModel.load()
            }
        }
    }
}

#Preview {
    GroupsView()
}
