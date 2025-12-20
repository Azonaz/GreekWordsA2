import StoreKit
import SwiftUI
import Combine

@MainActor
final class PurchaseManager: ObservableObject {
    @Published var products: [Product] = []
    @Published var purchasedProductIDs: Set<String> = []

    init() {
        Task {
            await loadProducts()
            await observeTransactions()
        }
    }

    func loadProducts() async {
        do {
            let ids = ["training_access_unlock"]
            let storeProducts = try await Product.products(for: ids)
            products = storeProducts

            // Checking already purchased items
            for await result in Transaction.currentEntitlements {
                if let transaction = try? result.payloadValue {
                    purchasedProductIDs.insert(transaction.productID)
                }
            }

        } catch {
            print("Error loading products: \(error)")
        }
    }

    func purchase(_ product: Product) async -> Bool {
        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                if let transaction = try? verification.payloadValue {
                    purchasedProductIDs.insert(transaction.productID)
                    await transaction.finish()
                    return true
                }
                return false

            case .userCancelled, .pending:
                return false

            default:
                return false
            }

        } catch {
            print("Purchase error:", error)
            return false
        }
    }

    func observeTransactions() async {
        for await result in Transaction.updates {
            if let transaction = try? result.payloadValue {
                purchasedProductIDs.insert(transaction.productID)
                await transaction.finish()
            }
        }
    }
}
