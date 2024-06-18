import Foundation

struct AlertModel {
    let title: String?
    let message: String
    let button1Text: String
    let button2Text: String?
    let completion1: () -> Void
    let completion2: (() -> Void)?

    init(title: String?, message: String, button1Text: String, completion1: @escaping () -> Void, 
         button2Text: String? = nil, completion2: (() -> Void)? = nil) {
        self.title = title
        self.message = message
        self.button1Text = button1Text
        self.completion1 = completion1
        self.button2Text = button2Text
        self.completion2 = completion2
    }
}
