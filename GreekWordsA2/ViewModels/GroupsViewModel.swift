import Foundation

final class GroupsViewModel: ObservableObject {
    @Published var groups = [VocabularyGroup]()
    @Published var selectedIndexPath: IndexPath?
    private let wordService = WordService()

    func load() {
        wordService.getGroups { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let groups):
                    self.groups = groups
                case .failure(let error):
                    print("Failed to load groups: \(error)")
                }
            }
        }
    }
}
