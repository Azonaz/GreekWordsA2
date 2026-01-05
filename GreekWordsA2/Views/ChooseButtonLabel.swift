import SwiftUI

struct ChooseButtonLabel: View {
    let title: String
    let height: CGFloat
    let font: Font

    var body: some View {
        Text(title)
            .multilineTextAlignment(.center)
            .lineLimit(2)
            .foregroundColor(.blackDN)
            .frame(height: height)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 12)
            .background(Color.whiteDN)
            .cornerRadius(16)
            .shadow(color: .grayUniversal.opacity(0.5), radius: 5, x: 2, y: 2)
            .font(font)
    }
}

struct ChooseIconButtonLabel: View {
    let systemName: String
    let height: CGFloat

    var body: some View {
        ChooseButtonLabel(title: "", height: height, font: .system(size: 1))
            .overlay(
                Image(systemName: systemName)
                    .font(.system(size: 24, weight: .regular))
                    .foregroundColor(.blackDN)
            )
    }
}
