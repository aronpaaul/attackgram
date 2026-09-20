import Foundation
import UIKit
import Display
import SwiftSignalKit
import TelegramCore
import TelegramPresentationData
import ItemListUI
import PresentationDataUtils
import AccountContext
import SGSimpleSettings

public func sgExtendedController(context: AccountContext) -> ViewController {
    let statePromise = ValuePromise(true, ignoreRepeated: false)

    let arguments = SGExtendedArguments(
        toggleUnlimitedPins: { value in
            SGSimpleSettings.shared.unlimitedPinnedChats = value
            statePromise.set(true)
        },
        toggleInvisibleMode: { value in
            SGSimpleSettings.shared.invisibleMode = value
            statePromise.set(true)
        },
        toggleHideOnline: { value in
            SGSimpleSettings.shared.hideOnlineStatus = value
            statePromise.set(true)
        },
        toggleHideTyping: { value in
            SGSimpleSettings.shared.hideTypingStatus = value
            statePromise.set(true)
        },
        toggleDontSendRead: { value in
            SGSimpleSettings.shared.dontSendReadReceipts = value
            statePromise.set(true)
        },
        toggleVoiceVideoReceipts: { value in
            SGSimpleSettings.shared.dontSendVoiceVideoReceipts = value
            statePromise.set(true)
        },
        toggleSaveEditHistory: { value in
            SGSimpleSettings.shared.saveEditHistory = value
            statePromise.set(true)
        },
        toggleSaveDeleted: { value in
            SGSimpleSettings.shared.saveDeletedMessages = value
            statePromise.set(true)
        },
        toggleSaveDeletedBots: { value in
            SGSimpleSettings.shared.saveDeletedFromBots = value
            statePromise.set(true)
        },
        toggleSaveDeletedSelf: { value in
            SGSimpleSettings.shared.saveDeletedFromSelf = value
            statePromise.set(true)
        }
    )

    let signal = combineLatest(context.sharedContext.presentationData, statePromise.get())
    |> map { presentationData, _ -> (ItemListControllerState, (ItemListNodeState, Any)) in
        var entries: [SGExtendedEntry] = []
        entries.append(.unlimitedPins(SGSimpleSettings.shared.unlimitedPinnedChats))
        entries.append(.invisibleMode(SGSimpleSettings.shared.invisibleMode))
        entries.append(.hideOnline(SGSimpleSettings.shared.hideOnlineStatus))
        entries.append(.hideTyping(SGSimpleSettings.shared.hideTypingStatus))
        entries.append(.dontSendRead(SGSimpleSettings.shared.dontSendReadReceipts))
        entries.append(.voiceVideoReceipts(SGSimpleSettings.shared.dontSendVoiceVideoReceipts))
        entries.append(.saveEditHistory(SGSimpleSettings.shared.saveEditHistory))
        entries.append(.saveDeleted(SGSimpleSettings.shared.saveDeletedMessages))
        if SGSimpleSettings.shared.saveDeletedMessages {
            entries.append(.saveDeletedBots(SGSimpleSettings.shared.saveDeletedFromBots))
            entries.append(.saveDeletedSelf(SGSimpleSettings.shared.saveDeletedFromSelf))
        }

        let controllerState = ItemListControllerState(presentationData: ItemListPresentationData(presentationData), title: .text("Extended"), leftNavigationButton: nil, rightNavigationButton: nil, backNavigationButton: ItemListBackButton(title: presentationData.strings.Common_Back))
        let emptyItem: ItemListControllerEmptyStateItem? = entries.isEmpty ? SGExtendedEmptyStateItem(theme: presentationData.theme, text: "Здесь появятся расширенные модули AttackGram.\nПока их нет.") : nil
        let listState = ItemListNodeState(presentationData: ItemListPresentationData(presentationData), entries: entries, style: .blocks, emptyStateItem: emptyItem)
        return (controllerState, (listState, arguments))
    }

    return ItemListController(context: context, state: signal)
}
