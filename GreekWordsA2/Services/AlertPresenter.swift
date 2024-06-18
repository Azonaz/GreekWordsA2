import UIKit

final class AlertPresenter {
    weak var viewController: UIViewController?

    init(viewController: UIViewController?) {
        self.viewController = viewController
    }

    func showResultAlert(with model: AlertModel) {
        let alert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert
        )
        let action1 = UIAlertAction(title: model.button1Text, style: .default) { _ in
            model.completion1()
        }
        alert.addAction(action1)
        if let button2Text = model.button2Text, let completion2 = model.completion2 {
            let action2 = UIAlertAction(title: button2Text, style: .default) { _ in
                completion2()
            }
            alert.addAction(action2)
        }
        viewController?.present(alert, animated: true, completion: nil)
    }

    func showErrorAlert(model: AlertModel) {
        let alert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert)
        guard let viewController = viewController else {return}
        let action = UIAlertAction(title: model.button1Text, style: .default) { _ in
            model.completion1()
        }
        alert.addAction(action)
        viewController.present(alert, animated: true)
    }
}
