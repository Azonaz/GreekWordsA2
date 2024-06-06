import SwiftUI

struct ChooseTypeView: View {
    var body: some View {
        ZStack {
            Color.grayDN
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                Text("Greek Words A2")
                    .font(.title3)
                    .padding(.bottom, 16)

                Button(action: {

                }, label: {
                    Text("Random selection")
                        .foregroundColor(.blackDN)
                        .frame(height: 60)
                        .padding(.horizontal, 60)
                        .background(Color.whiteDN)
                        .cornerRadius(16)
                })

                Button(action: {

                }, label: {
                    Text("Words by groups")
                        .foregroundColor(.black)
                        .frame(height: 60)
                        .padding(.horizontal, 60)
                        .background(Color.whiteDN)
                        .cornerRadius(16)
                })

                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    ChooseTypeView()
}
