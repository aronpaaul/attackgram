import Foundation
import UIKit
import AsyncDisplayKit
import Display
import TelegramPresentationData
import ItemListUI

final class SGExtendedEmptyStateItemNode: ItemListControllerEmptyStateItemNode {
    private let duckNode: ImmediateTextNode
    private let textNode: ImmediateTextNode

    override init() {
        self.duckNode = ImmediateTextNode()
        self.duckNode.textAlignment = .center
        self.duckNode.attributedText = NSAttributedString(string: "🦆", font: Font.regular(110.0), textColor: .black, paragraphAlignment: .center)

        self.textNode = ImmediateTextNode()
        self.textNode.maximumNumberOfLines = 0
        self.textNode.textAlignment = .center

        super.init()

        self.addSubnode(self.duckNode)
        self.addSubnode(self.textNode)
    }

    func update(theme: PresentationTheme, text: String) {
        self.textNode.attributedText = NSAttributedString(string: text, font: Font.regular(16.0), textColor: theme.list.freeTextColor, paragraphAlignment: .center)
    }

    override func updateLayout(layout: ContainerViewLayout, navigationBarHeight: CGFloat, transition: ContainedViewLayoutTransition) {
        let contentWidth = layout.size.width - 60.0
        let duckSize = self.duckNode.updateLayout(CGSize(width: contentWidth, height: 220.0))
        let textSize = self.textNode.updateLayout(CGSize(width: contentWidth, height: .greatestFiniteMagnitude))
        let spacing: CGFloat = 24.0
        let totalHeight = duckSize.height + spacing + textSize.height
        let originY = navigationBarHeight + floor((layout.size.height - navigationBarHeight - totalHeight) / 2.0)

        let duckFrame = CGRect(origin: CGPoint(x: floor((layout.size.width - duckSize.width) / 2.0), y: originY), size: duckSize)
        transition.updateFrame(node: self.duckNode, frame: duckFrame)

        let textFrame = CGRect(origin: CGPoint(x: floor((layout.size.width - textSize.width) / 2.0), y: duckFrame.maxY + spacing), size: textSize)
        transition.updateFrame(node: self.textNode, frame: textFrame)
    }
}
