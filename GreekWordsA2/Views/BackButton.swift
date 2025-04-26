import SwiftUI

struct BackButton: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.horizontalSizeClass) var sizeClass

    var body: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }, label: {
            Image(systemName: "chevron.left")
                .foregroundColor(Color(.greenUniversal))
                .font(sizeClass == .regular ? .title2 : .title3)
        })
    }
}

#Preview {
    BackButton()
}
