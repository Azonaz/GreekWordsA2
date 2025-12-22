import SwiftUI
import StoreKit

struct TrainingPaywallView: View {
    @EnvironmentObject var purchaseManager: PurchaseManager
    @EnvironmentObject var trainingAccess: TrainingAccessManager
    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(\.dismiss) var dismiss

    @State private var purchasing = false
    @State private var errorMessage: String?
    @State private var product: Product?

    private var buttonHeight: CGFloat {
        sizeClass == .regular ? 120 : 90
    }

    private var horizontalPadding: CGFloat {
        sizeClass == .regular ? 100 : 60
    }

    var body: some View {
        ZStack {
            Color.grayDN
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 40) {
                Text(Texts.accessExpired)
                    .font(sizeClass == .regular ? .largeTitle : .title)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 32)
                    .padding(.top, 32)

                Text(Texts.unlockAccess)
                    .font(sizeClass == .regular ? .headline : .subheadline)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                Group {
                    if let product {
                        Button {
                            Task {
                                purchasing = true
                                let success = await purchaseManager.purchase(product)
                                purchasing = false

                                if success {
                                    trainingAccess.setUnlocked()
                                    dismiss()
                                } else {
                                    errorMessage = Texts.errorPurchase
                                }
                            }
                        } label: {
                            VStack(spacing: 4) {
                                Text(Texts.unlockFor)
                                    .font(sizeClass == .regular ? .title2 : .title3)
                                    .foregroundColor(.blackDN)

                                Text(product.displayPrice)
                                    .font(sizeClass == .regular ? .largeTitle : .title)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.blackDN)
                            }
                            .modifier(PaywallButtonStyle(height: buttonHeight))
                        }
                        .disabled(purchasing)

                    } else {
                        ProgressView(Texts.loadPrice)
                            .foregroundColor(.blackDN)
                            .modifier(PaywallButtonStyle(height: buttonHeight))
                    }
                }
                .padding(.horizontal, horizontalPadding)
                .animation(nil, value: purchasing)

                if let errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.footnote)
                }

            }
            .frame(maxHeight: .infinity, alignment: .center)
            .offset(y: -40)
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(Texts.trainingAccess)
                    .font(sizeClass == .regular ? .largeTitle : .title)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .onReceive(purchaseManager.$products) { products in
            product = products.first(where: { $0.id == "unlock_training_access" })
        }
    }
}

private struct PaywallButtonStyle: ViewModifier {
    let height: CGFloat

    func body(content: Content) -> some View {
        content
            .multilineTextAlignment(.center)
            .frame(height: height)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 12)
            .background(Color.whiteDN)
            .cornerRadius(16)
            .shadow(color: .grayUniversal.opacity(0.5), radius: 5, x: 2, y: 2)
    }
}
