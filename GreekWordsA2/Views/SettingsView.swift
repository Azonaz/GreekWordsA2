import SwiftUI
import StoreKit

struct SettingsView: View {
    @State private var currentLanguage = Locale.current.language.languageCode?.identifier ?? "en"
    @Environment(\.horizontalSizeClass) var sizeClass
    @AppStorage("isBlurEnabled") private var isBlurEnabled = false
    @AppStorage("dailyNewWordsLimit") private var dailyNewWordsLimit: Int = 20
    @AppStorage("shouldShowRateButton") private var shouldShowRateButton = false

    @EnvironmentObject var trainingAccess: TrainingAccessManager
    @EnvironmentObject var purchaseManager: PurchaseManager

    @State private var restoring = false
    @State private var restoreMessage: String?
    @State private var restoreSucceeded: Bool?
    @State private var showOtherLevels = false
    @State private var showTrainingPaywall = false

    private let appRate = "https://apps.apple.com/cy/app/greek-words-a2/id6736978135?action=write-review"

    private var rows: [SettingsRow] {
        var base: [SettingsRow] = [.language, .blur, .limit, .trainingAccess, .restore, .otherLevels]
        if shouldShowRateButton {
            base.append(.rateApp)
        }
        return base
    }

    private var rowHeight: CGFloat {
        sizeClass == .regular ? 80 : 60
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
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(Texts.settings)
                    .font(sizeClass == .regular ? .largeTitle : .title)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .onAppear {
            updateLanguage()
        }
        .navigationDestination(isPresented: $showOtherLevels) {
            LevelsView()
        }
        .navigationDestination(isPresented: $showTrainingPaywall) {
            TrainingPaywallView()
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

    private func restorePurchases() async -> Bool {
        var restored = false

        for await result in Transaction.currentEntitlements {
            if let transaction = try? result.payloadValue {
                purchaseManager.purchasedProductIDs.insert(transaction.productID)
                await transaction.finish()
                trainingAccess.setUnlocked()
                restored = true
            }
        }

        return restored
    }
}

private extension SettingsView {
    @ViewBuilder
    private func rowView(for row: SettingsRow) -> some View {
        switch row {
        case .language:
            languageRow()
        case .blur:
            blurRow()
        case .limit:
            limitRow()
        case .restore:
            restoreRow()
        case .otherLevels:
            otherLevelsRow()
        case .trainingAccess:
            trainingAccessRow()
        case .rateApp:
            rateRow()
        }
    }

    @ViewBuilder
    private func languageRow() -> some View {
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
    }

    @ViewBuilder
    private func blurRow() -> some View {
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
    }

    @ViewBuilder
    private func limitRow() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 14) {
                Image(systemName: "character.book.closed")
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

    @ViewBuilder
    private func restoreRow() -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 14) {
                Image(systemName: "lock.open")
                    .font(.body)
                    .imageScale(.large)
                    .foregroundColor(.primary)

                Text(Texts.restore)
                    .font(.body)
                    .foregroundColor(.primary)

                Spacer()

                if restoring {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                } else if restoreSucceeded == true {
                    Image(systemName: "checkmark")
                        .font(.body)
                        .imageScale(.large)
                        .foregroundColor(.primary)
                }
            }
            .padding(.vertical, 8)
            .contentShape(Rectangle())
            .onTapGesture {
                Task {
                    await MainActor.run {
                        restoring = true
                        restoreMessage = nil
                        restoreSucceeded = nil
                    }

                    let restored = await restorePurchases()

                    await MainActor.run {
                        restoring = false
                        restoreMessage = restored ? Texts.purchaseRestored : Texts.noPurchase
                        restoreSucceeded = restored
                    }
                }
            }

            if let restoreMessage {
                Text(restoreMessage)
                    .foregroundColor(.secondary)
                    .font(.footnote)
            }
        }
        .disabled(restoring)
    }

    @ViewBuilder
    private func otherLevelsRow() -> some View {
        HStack(spacing: 14) {
            Image(systemName: "graduationcap")
                .imageScale(.large)
                .foregroundColor(.primary)

            Text(Texts.otherLevels)
                .font(.body)
                .foregroundColor(.primary)

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.primary)
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapGesture {
            showOtherLevels = true
        }
    }

    @ViewBuilder
    private func rateRow() -> some View {
        HStack(spacing: 14) {
            Image(systemName: "star.fill")
                .font(.body)
                .imageScale(.large)
                .foregroundColor(.primary)

            Text(Texts.rateApp)
                .font(.body)
                .foregroundColor(.primary)

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.primary)
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapGesture {
            if let url = URL(string: appRate) {
                UIApplication.shared.open(url)
            }
            shouldShowRateButton = false
        }
    }

    @ViewBuilder
    private func trainingAccessRow() -> some View {
        let isPurchased = trainingAccess.hasAccess && !trainingAccess.isInTrial

        Button {
            if isPurchased { return }
            showTrainingPaywall = true
        } label: {
            HStack(spacing: 14) {
                Image(systemName: trainingAccess.hasAccess ? "lock.open" : "lock")
                    .imageScale(.large)
                    .foregroundColor(.primary)

                Text(Texts.trainingAccess)
                    .font(.body)
                    .foregroundColor(.primary)

                Spacer()

                if isPurchased {
                    Text(Texts.unlocked)
                        .foregroundColor(.secondary)
                } else if trainingAccess.isInTrial {
                    Text(Texts.trialDaysShort(trainingAccess.daysLeft ?? 0))
                        .foregroundColor(.secondary)
                } else {
                    Text(Texts.locked)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 8)
        }
        .disabled(isPurchased)
    }
}

private enum SettingsRow {
    case language
    case blur
    case limit
    case restore
    case otherLevels
    case trainingAccess
    case rateApp
}
