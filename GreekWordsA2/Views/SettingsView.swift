import SwiftUI

struct SettingsView: View {
    @State private var currentLanguage = Locale.current.language.languageCode?.identifier ?? "en"
    @Environment(\.horizontalSizeClass) var sizeClass
    @AppStorage("isBlurEnabled") private var isBlurEnabled = false
    @AppStorage("dailyNewWordsLimit") private var dailyNewWordsLimit: Int = 20
    private let rows: [SettingsRow] = [.language, .blur, .limit]

    private var rowHeight: CGFloat {
        sizeClass == .regular ? 60 : 60
    }

    var body: some View {
        ZStack {
            Color.grayDN
                .edgesIgnoringSafeArea(.all)

            List {
                ForEach(Array(rows.enumerated()), id: \.offset) { index, row in
                    rowView(for: row)
                        .frame(height: rowHeight, alignment: .leading)
                        .listRowInsets(EdgeInsets(top: 10, leading: 8, bottom: 10, trailing: 16))
                        .listRowBackground(Color.whiteDN)
                        .listRowSeparator(.hidden)
                        .overlay(alignment: .bottom) {
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(
                                    index == rows.indices.last
                                    ? Color.whiteDN
                                    : Color.greenUniversal.opacity(0.3)
                                )
                                .offset(y: 8)
                        }
                }
            }
            .listStyle(.plain)
            .scrollIndicators(.hidden)
            .scrollContentBackground(.hidden)
            .padding(.horizontal)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.whiteDN)
            )
            .padding()
            .foregroundColor(.blackDN)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackButton()
            }
            ToolbarItem(placement: .principal) {
                Text(Texts.settings)
                    .font(sizeClass == .regular ? .largeTitle : .title)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .onSwipeDismiss()
        .onAppear {
            updateLanguage()
        }
    }

    private func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }

    private func updateLanguage() {
        currentLanguage = Locale.current.language.languageCode?.identifier ?? "en"
    }

    private func displayName(for code: String) -> String {
        switch code {
        case "ru": return "Русский"
        case "en": return "English"
        default: return code.uppercased()
        }
    }

    @ViewBuilder
    private func rowView(for row: SettingsRow) -> some View {
        switch row {
        case .language:
            Button {
                openAppSettings()
            } label: {
                HStack(spacing: 14) {
                    Image(systemName: "globe")
                        .font(.body)
                        .imageScale(.large)
                        .foregroundColor(.primary)

                    Text(Texts.language)
                        .font(.body)
                        .foregroundColor(.primary)

                    Spacer()

                    Text(displayName(for: currentLanguage))
                        .font(.body)
                        .foregroundColor(.secondary)

                    Image(systemName: "chevron.right")
                        .foregroundColor(.primary)
                }
                .padding(.vertical, 8)
            }
        case .blur:
            Toggle(isOn: $isBlurEnabled) {
                HStack(spacing: 14) {
                    Image(systemName: "circle.lefthalf.filled")
                        .font(.body)
                        .imageScale(.large)
                        .foregroundColor(.primary)

                    Text(isBlurEnabled ? Texts.blurOn : Texts.blurOff)
                        .font(.body)
                        .foregroundColor(.primary)
                }
                .padding(.vertical, 4)
            }
        case .limit:
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 14) {
                    Image(systemName: "number")
                        .font(.body)
                        .imageScale(.large)
                        .foregroundColor(.primary)

                    Text(Texts.newWordsNumber)
                        .font(.body)
                        .foregroundColor(.primary)
                }

                Picker("", selection: $dailyNewWordsLimit) {
                    Text("10").tag(10)
                    Text("20").tag(20)
                    Text("30").tag(30)
                }
                .pickerStyle(.segmented)
            }
        }
    }
}

private enum SettingsRow {
    case language
    case blur
    case limit
}

#Preview {
    SettingsView()
}
