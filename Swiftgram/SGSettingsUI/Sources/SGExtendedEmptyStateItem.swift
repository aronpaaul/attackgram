import Foundation
import UIKit
import Display
import TelegramPresentationData
import ItemListUI

final class SGExtendedEmptyStateItem: ItemListControllerEmptyStateItem {
    let theme: PresentationTheme
    let text: String

    init(theme: PresentationTheme, text: String) {
        self.theme = theme
        self.text = text
    }

    func isEqual(to: ItemListControllerEmptyStateItem) -> Bool {
        if let other = to as? SGExtendedEmptyStateItem {
            return self.theme === other.theme && self.text == other.text
        }
        return false
    }

    func node(current: ItemListControllerEmptyStateItemNode?) -> ItemListControllerEmptyStateItemNode {
        if let current = current as? SGExtendedEmptyStateItemNode {
            current.update(theme: self.theme, text: self.text)
            return current
        }
        let node = SGExtendedEmptyStateItemNode()
        node.update(theme: self.theme, text: self.text)
        return node
    }
}
