import SwiftUI

struct ChooseTypeView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color.grayDN
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 20) {
                    Text("Greek Words A2")
                        .font(.title2)
                        .padding(.bottom, 16)

                    Button(action: {

                    }, label: {
                        Text("Random selection")
                            .foregroundColor(.blackDN)
                            .frame(height: 60)
                            .padding(.horizontal, 60)
                            .background(Color.whiteDN)
                            .cornerRadius(16)
                            .font(.title3)
                    })

                    NavigationLink(destination: GroupsView()) {
                        Text("Words by groups")
                            .foregroundColor(.black)
                            .frame(height: 60)
                            .padding(.horizontal, 60)
                            .background(Color.whiteDN)
                            .cornerRadius(16)
                            .font(.title3)
                    }
                    Spacer()
                }
                .padding()
            }
        }
    }
}

#Preview {
    ChooseTypeView()
}
