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

    private var cornerRadius: CGFloat {
        sizeClass == .regular ? 50 : 40
    }

    private var horizontalPadding: CGFloat {
        sizeClass == .regular ? 100 : 60
    }

    var body: some View {
        ZStack {
            Color.gray.opacity(0.05)
                .ignoresSafeArea()

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
                                    .foregroundColor(.primary)

                                Text(product.displayPrice)
                                    .font(sizeClass == .regular ? .largeTitle : .title)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                            }
                            .frame(maxWidth: .infinity)
//                            .glassCard(height: buttonHeight, cornerRadius: cornerRadius)
                        }
                        .disabled(purchasing)

                    } else {
                        ProgressView(Texts.loadPrice)
                            .frame(maxWidth: .infinity)
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
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(Texts.trainingAccess)
                    .font(sizeClass == .regular ? .largeTitle : .title2)
                    .foregroundColor(.primary)
            }
        }
        .onReceive(purchaseManager.$products) { products in
            product = products.first(where: { $0.id == "training_access_unlock" })
        }
    }
}
