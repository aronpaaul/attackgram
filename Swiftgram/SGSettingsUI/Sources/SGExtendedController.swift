import Foundation
import UIKit
import Display
import SwiftSignalKit
import TelegramCore
import TelegramPresentationData
import ItemListUI
import PresentationDataUtils
import AccountContext

private enum SGExtendedEntry: ItemListNodeEntry {
    case placeholder

    var section: ItemListSectionId {
        return 0
    }

    var stableId: Int32 {
        return 0
    }

    static func <(lhs: SGExtendedEntry, rhs: SGExtendedEntry) -> Bool {
        return false
    }

    func item(presentationData: ItemListPresentationData, arguments: Any) -> ListViewItem {
        preconditionFailure()
    }
}

public func sgExtendedController(context: AccountContext) -> ViewController {
    let signal = context.sharedContext.presentationData
    |> map { presentationData -> (ItemListControllerState, (ItemListNodeState, Any)) in
        let controllerState = ItemListControllerState(presentationData: ItemListPresentationData(presentationData), title: .text("Extended"), leftNavigationButton: nil, rightNavigationButton: nil, backNavigationButton: ItemListBackButton(title: presentationData.strings.Common_Back))
        let emptyItem = SGExtendedEmptyStateItem(theme: presentationData.theme, text: "Здесь появятся расширенные модули AttackGram.\nПока их нет.")
        let listState = ItemListNodeState(presentationData: ItemListPresentationData(presentationData), entries: [] as [SGExtendedEntry], style: .blocks, emptyStateItem: emptyItem)
        return (controllerState, (listState, ()))
    }
    return ItemListController(context: context, state: signal)
}
