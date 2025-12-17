import SwiftUI
import SwiftData

@main
struct GreekWordsA2App: App {
    @State private var showLaunchScreen = true
    private let container: ModelContainer

    init() {
        do {
            let schema = Schema([
                Word.self,
                GroupMeta.self,
                WordProgress.self
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
                ChooseTypeView()
            }
        }
        .modelContainer(container)
    }
}
