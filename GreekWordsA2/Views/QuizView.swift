import SwiftUI

struct QuizView: View {
    @ObservedObject var viewModel: GroupsViewModel
    @State var greekWord: String = ""
    @State var enWords: [String] = []
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
                    Text(greekWord)
                        .foregroundColor(.blackDN)
                        .font(.title2)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.whiteDN)
                                .frame(width: width, height: 150)
                                .padding(.horizontal, 20)
                        )
                    Spacer()
                    if enWords.count == 3 {
                        ForEach(0..<enWords.count, id: \.self) { index in
                            Button(action: {
                                // Handle button action
                            }, label: {
                                Text(enWords[index])
                                    .foregroundColor(.blackDN)
                                    .frame(width: width, height: 60)
                                    .background(Color.whiteDN)
                                    .cornerRadius(16)
                                    .font(.title3)
                            })
                        }
                    } else {
                        Text("Loading options...")
                    }
                    Spacer()
                }
                .navigationTitle(group.name)
                .navigationBarBackButtonHidden(true)
                .navigationBarItems(leading: BackButton())
            }
        }
        .onAppear {
            viewModel.getWords {
                greekWord = viewModel.setRandomWord()
                enWords = viewModel.setRandomValuesForWord()
            }
        }
    }
}
