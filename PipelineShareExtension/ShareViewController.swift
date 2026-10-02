import Social
import UIKit

final class ShareViewController: SLComposeServiceViewController {
    override func isContentValid() -> Bool {
        true
    }

    override func didSelectPost() {
        extensionContext?.completeRequest(returningItems: nil)
    }

    override func configurationItems() -> [Any]! {
        []
    }
}
