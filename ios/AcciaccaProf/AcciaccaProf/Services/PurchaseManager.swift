import Foundation
import StoreKit

@MainActor
final class PurchaseManager: ObservableObject {
    static let shared = PurchaseManager()

    private let productId = "it.semproxlab.acciaccaprof.personalizzazioni"
    @Published private(set) var product: Product?
    @Published private(set) var unlocked = false
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private var updatesTask: Task<Void, Never>?

    private init() {
        updatesTask = Task { [weak self] in
            for await _ in Transaction.updates {
                await self?.refreshEntitlements()
            }
        }
        Task {
            await refreshProducts()
            await refreshEntitlements()
        }
    }

    func refreshProducts() async {
        do {
            let products = try await Product.products(for: [productId])
            product = products.first
            if product == nil {
                errorMessage = "Prodotto non disponibile. Controlla StoreKit Configuration."
            }
        } catch {
            errorMessage = "Impossibile caricare il prodotto."
        }
    }

    func purchase() async {
        guard let product else {
            errorMessage = "Prodotto non disponibile."
            return
        }
        isLoading = true
        defer { isLoading = false }
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                if case .verified(let transaction) = verification {
                    await transaction.finish()
                    await refreshEntitlements()
                }
            default:
                break
            }
        } catch {
            errorMessage = "Acquisto non riuscito."
        }
    }

    func restore() async {
        isLoading = true
        defer { isLoading = false }
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result, transaction.productID == productId {
                unlocked = true
            }
        }
    }

    func refreshEntitlements() async {
        unlocked = false
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result, transaction.productID == productId {
                unlocked = true
                break
            }
        }
    }
}
