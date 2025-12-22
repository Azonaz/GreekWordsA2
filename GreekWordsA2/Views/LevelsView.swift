import SwiftUI

struct LevelsView: View {
    @Environment(\.horizontalSizeClass) var sizeClass

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {

                LevelCard(
                    level: "A1",
                    title: "Greek Words — A1",
                    subtitle: Texts.a1Level,
                    appIconName: "a1",
                    appStoreURL: "https://apps.apple.com/cy/app/greek-words-a1/id6474042509",
                    isCurrent: false
                )

                LevelCard(
                    level: "A2",
                    title: "Greek Words — A2",
                    subtitle: Texts.a2Level,
                    appIconName: "a2",
                    appStoreURL: nil,
                    isCurrent: true
                )

                LevelCard(
                    level: "B1",
                    title: "Greek Words — B1",
                    subtitle: Texts.b1Level,
                    appIconName: "b1",
                    appStoreURL: "https://apps.apple.com/cy/app/greek-words-b1/id6754924042",
                    isCurrent: false
                )
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackButton()
            }
            ToolbarItem(placement: .principal) {
                Text(Texts.levels)
                    .font(sizeClass == .regular ? .largeTitle : .title)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .onSwipeDismiss()
        .background(Color.grayDN)
    }
}

struct LevelCard: View {
    let level: String
    let title: String
    let subtitle: String
    let appIconName: String
    let appStoreURL: String?
    let isCurrent: Bool

    var body: some View {
        Button {
            guard !isCurrent,
                  let appStoreURL,
                  let url = URL(string: appStoreURL) else { return }
            UIApplication.shared.open(url)
        } label: {
            HStack(spacing: 16) {

                Image(appIconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 56, height: 56)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                Color.black.opacity(isCurrent ? 0.1 : 0.2),
                                lineWidth: 1
                            )
                    )
                    .opacity(isCurrent ? 0.5 : 1.0)

                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Text(title)
                            .font(.headline)
                            .foregroundColor(.blackDN)

                        if isCurrent {
                            Text(Texts.here)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(
                                    Capsule().fill(Color.gray.opacity(0.15))
                                )
                                .foregroundColor(.secondary)
                        }
                    }

                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: isCurrent ? "checkmark.circle" : "arrow.up.right.square")
                    .foregroundColor(isCurrent ? .greenUniversal : .secondary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.whiteDN)
            )
        }
        .buttonStyle(.plain)
        .disabled(isCurrent)
    }
}
