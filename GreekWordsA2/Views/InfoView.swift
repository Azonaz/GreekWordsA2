import SwiftUI

struct InfoView: View {
    @Environment(\.horizontalSizeClass) var sizeClass

    var body: some View {
        ZStack {
            Color.grayDN
                .edgesIgnoringSafeArea(.all)

            List {
                Section(header:
                    Text(Texts.quizInfo)
                        .font(sizeClass == .regular ? .title2 : .headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .padding(.bottom, 4)
                ) {
                    Text(Texts.quizHelp)
                        .font(.body)
                        .multilineTextAlignment(.leading)
                        .padding(.vertical, 4)
                }

                Section(header:
                    Text(Texts.reverseQuizInfo)
                        .font(sizeClass == .regular ? .title2 : .headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .padding(.bottom, 4)
                ) {
                    Text(Texts.reverseQuizHelp)
                        .font(.body)
                        .multilineTextAlignment(.leading)
                        .padding(.vertical, 4)
                }

                Section(header:
                    Text(Texts.trainingInfo)
                        .font(sizeClass == .regular ? .title2 : .headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .padding(.bottom, 4)
                ) {
                    Text(Texts.trainingHelp)
                        .font(.body)
                        .multilineTextAlignment(.leading)
                        .padding(.vertical, 4)
                }

                Section(header:
                    Text(Texts.verbInfo)
                        .font(sizeClass == .regular ? .title2 : .headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .padding(.bottom, 4)
                ) {
                    Text(Texts.verbHelp)
                        .font(.body)
                        .multilineTextAlignment(.leading)
                        .padding(.vertical, 4)
                }

                Section(header:
                    Text(Texts.wordDay)
                        .font(sizeClass == .regular ? .title2 : .headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .padding(.bottom, 4)
                ) {
                    Text(Texts.wordDayHelp)
                        .font(.body)
                        .multilineTextAlignment(.leading)
                        .padding(.vertical, 4)
                }
            }
            .listStyle(.insetGrouped)
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(Texts.information)
                    .font(sizeClass == .regular ? .largeTitle : .title)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }
}
