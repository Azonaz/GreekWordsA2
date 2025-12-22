import SwiftUI
import SwiftData
import UIKit

@main
struct GreekWordsA2App: App {
    @State private var showLaunchScreen = true
    @StateObject private var trainingAccess = TrainingAccessManager()
    @StateObject private var purchaseManager = PurchaseManager()
    private let container: ModelContainer

    init() {
        let navTint = UIColor(named: "GreenUniversal") ?? UIColor(Color.greenUniversal)

        let backImage = UIImage(systemName: "chevron.backward")?
            .withTintColor(navTint, renderingMode: .alwaysOriginal)

        let appearance = UINavigationBarAppearance()
        if let backImage {
            appearance.setBackIndicatorImage(backImage, transitionMaskImage: backImage)
        }

        UINavigationBar.appearance().tintColor = navTint
        UIBarButtonItem.appearance().tintColor = navTint
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().compactScrollEdgeAppearance = appearance

        do {
            let schema = Schema([
                Word.self,
                GroupMeta.self,
                WordProgress.self,
                QuizStats.self
            ])
            container = try ModelContainer(for: schema)
        } catch {
            fatalError("SwiftData container init failed: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            if showLaunchScreen {
                LaunchScreenView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            withAnimation { showLaunchScreen = false }
                        }
                    }
            } else {
                NavigationStack {
                    ChooseTypeView()
                }
                .environmentObject(trainingAccess)
                .environmentObject(purchaseManager)
            }
        }
        .modelContainer(container)
    }
}
