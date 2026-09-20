import Foundation
import Display
import SwiftSignalKit
import Postbox
import TelegramCore
import TelegramPresentationData
import ItemListUI
import PresentationDataUtils
import AccountContext
import SGSimpleSettings

private final class SGIgnoredArguments {
    let removeIgnored: (String) -> Void

    init(removeIgnored: @escaping (String) -> Void) {
        self.removeIgnored = removeIgnored
    }
}

private enum SGIgnoredEntry: ItemListNodeEntry {
    case info(String)
    case user(Int32, String, String)

    var section: ItemListSectionId {
        return 0
    }

    var stableId: Int32 {
        switch self {
        case .info: return 0
        case let .user(index, _, _): return index + 1
        }
    }

    static func <(lhs: SGIgnoredEntry, rhs: SGIgnoredEntry) -> Bool {
        return lhs.stableId < rhs.stableId
    }

    func item(presentationData: ItemListPresentationData, arguments: Any) -> ListViewItem {
        let arguments = arguments as! SGIgnoredArguments
        switch self {
        case let .info(text):
            return ItemListTextItem(presentationData: presentationData, text: .plain(text), sectionId: self.section)
        case let .user(_, key, name):
            return ItemListActionItem(presentationData: presentationData, title: name, kind: .destructive, alignment: .natural, sectionId: self.section, style: .blocks, action: {
                arguments.removeIgnored(key)
            })
        }
    }
}

public func sgIgnoredController(context: AccountContext) -> ViewController {
    let statePromise = ValuePromise(true, ignoreRepeated: false)

    let arguments = SGIgnoredArguments(removeIgnored: { key in
        var ids = SGSimpleSettings.shared.ignoredPeerIds
        ids.removeAll(where: { $0 == key })
        SGSimpleSettings.shared.ignoredPeerIds = ids
        statePromise.set(true)
    })

    let signal = combineLatest(context.sharedContext.presentationData, statePromise.get())
    |> mapToSignal { presentationData, _ -> Signal<(ItemListControllerState, (ItemListNodeState, Any)), NoError> in
        let keys = SGSimpleSettings.shared.ignoredPeerIds
        let peerIds = keys.compactMap { Int64($0) }.map { PeerId($0) }
        return context.engine.data.get(EngineDataList(peerIds.map { TelegramEngine.EngineData.Item.Peer.Peer(id: $0) }))
        |> map { peers -> (ItemListControllerState, (ItemListNodeState, Any)) in
            var entries: [SGIgnoredEntry] = []
            if keys.isEmpty {
                entries.append(.info("Список игнора пуст. Зажмите сообщение пользователя и выберите «Игнорировать пользователя»."))
            } else {
                entries.append(.info("Нажмите на пользователя, чтобы убрать из игнора."))
                for (index, key) in keys.enumerated() {
                    var name = key
                    if index < peers.count, let peer = peers[index] {
                        name = peer.displayTitle(strings: presentationData.strings, displayOrder: presentationData.nameDisplayOrder)
                    }
                    entries.append(.user(Int32(index), key, name))
                }
            }
            let controllerState = ItemListControllerState(presentationData: ItemListPresentationData(presentationData), title: .text("Игнор-лист"), leftNavigationButton: nil, rightNavigationButton: nil, backNavigationButton: ItemListBackButton(title: presentationData.strings.Common_Back))
            let listState = ItemListNodeState(presentationData: ItemListPresentationData(presentationData), entries: entries, style: .blocks)
            return (controllerState, (listState, arguments))
        }
    }

    return ItemListController(context: context, state: signal)
}
