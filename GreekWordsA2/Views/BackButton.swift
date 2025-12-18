import SwiftUI

struct BackButton: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var sizeClass

    var body: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "chevron.left")
                .foregroundColor(.greenUniversal)
                .font(sizeClass == .regular ? .title2 : .title3)
        }
    }
}

#Preview {
    BackButton()
}
