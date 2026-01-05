import Foundation
import FSRS

extension Rating {
    var localized: String {
        NSLocalizedString("rating.\(self.stringValue)", comment: "")
    }
}
