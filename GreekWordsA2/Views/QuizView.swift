import SwiftUI

struct QuizView: View {
    let group: VocabularyGroup
    let width = UIScreen.main.bounds.width - 120
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.grayDN
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    Text("1/10")
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.trailing, 20)
                    Spacer()
                    Text("")
                        .foregroundColor(.blackDN)
                        .font(.title2)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.whiteDN)
                                .frame(width: width, height: 150)
                                .padding(.horizontal, 20)
                        )
                    Spacer()
                    Button(action: {
                        
                    }, label: {
                        Text("")
                            .foregroundColor(.blackDN)
                            .frame(width: width, height: 60)
                            .background(Color.whiteDN)
                            .cornerRadius(16)
                            .font(.title3)
                    })
                    Button(action: {
                        
                    }, label: {
                        Text("")
                            .foregroundColor(.blackDN)
                            .frame(width: width, height: 60)
                            .background(Color.whiteDN)
                            .cornerRadius(16)
                            .font(.title3)
                    })
                    Button(action: {
                        
                    }, label: {
                        Text("")
                            .foregroundColor(.blackDN)
                            .frame(width: width, height: 60)
                            .background(Color.whiteDN)
                            .cornerRadius(16)
                            .font(.title3)
                    })
                    Spacer()
                }
                .navigationTitle(group.name)
                .navigationBarBackButtonHidden(true)
                .navigationBarItems(leading: BackButton())
            }
        }
    }
}
