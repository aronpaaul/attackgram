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
    let searchPromise = ValuePromise<String>("", ignoreRepeated: true)
    var pushControllerImpl: ((ViewController) -> Void)?

    let arguments = SGExtendedArguments(
        updateSearch: { value in
            searchPromise.set(value)
        },
        toggleUnlimitedPins: { value in
            SGSimpleSettings.shared.unlimitedPinnedChats = value
            statePromise.set(true)
        },
        openThemes: {
            pushControllerImpl?(sgThemesController(context: context))
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
        },
        clearDeleted: {
            let _ = sgClearDeletedMessages(account: context.account).start()
            statePromise.set(true)
        },
        clearEdited: {
            let _ = sgClearEditHistory(account: context.account).start()
            statePromise.set(true)
        }
    )

    let signal = combineLatest(context.sharedContext.presentationData, statePromise.get(), searchPromise.get())
    |> map { presentationData, _, searchQuery -> (ItemListControllerState, (ItemListNodeState, Any)) in
        let strings = presentationData.strings
        var entries: [SGExtendedEntry] = []
        entries.append(.search(strings.Common_Search, searchQuery))

        var items: [SGExtendedEntry] = []
        items.append(.unlimitedPins("Безлимитный закреп чатов", SGSimpleSettings.shared.unlimitedPinnedChats))
        items.append(.themes("Готовые темы"))
        items.append(.invisibleMode("Невидимый режим", SGSimpleSettings.shared.invisibleMode))
        items.append(.hideOnline("Скрывать статус «в сети»", SGSimpleSettings.shared.hideOnlineStatus))
        items.append(.hideTyping("Скрывать «печатает…»", SGSimpleSettings.shared.hideTypingStatus))
        items.append(.dontSendRead("Не отправлять прочтение", SGSimpleSettings.shared.dontSendReadReceipts))
        items.append(.voiceVideoReceipts("Не отправлять «прослушано/просмотрено»", SGSimpleSettings.shared.dontSendVoiceVideoReceipts))
        items.append(.saveEditHistory("Сохранять историю правок", SGSimpleSettings.shared.saveEditHistory))
        items.append(.saveDeleted("Сохранять удалённые сообщения", SGSimpleSettings.shared.saveDeletedMessages))
        if SGSimpleSettings.shared.saveDeletedMessages {
            items.append(.saveDeletedBots("Удалённые в ботах", SGSimpleSettings.shared.saveDeletedFromBots))
            items.append(.saveDeletedSelf("Удалённые от себя", SGSimpleSettings.shared.saveDeletedFromSelf))
        }
        items.append(.clearDeleted("Очистить историю удалённых"))
        items.append(.clearEdited("Очистить историю правок"))

        let trimmedQuery = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !trimmedQuery.isEmpty {
            items = items.filter { $0.searchableTitle.lowercased().contains(trimmedQuery) }
        }
        entries.append(contentsOf: items)

        let controllerState = ItemListControllerState(presentationData: ItemListPresentationData(presentationData), title: .text("Extended"), leftNavigationButton: nil, rightNavigationButton: nil, backNavigationButton: ItemListBackButton(title: presentationData.strings.Common_Back))
        let listState = ItemListNodeState(presentationData: ItemListPresentationData(presentationData), entries: entries, style: .blocks)
        return (controllerState, (listState, arguments))
    }

    let controller = ItemListController(context: context, state: signal)
    pushControllerImpl = { [weak controller] c in
        (controller?.navigationController as? NavigationController)?.pushViewController(c)
    }
    return controller
}
