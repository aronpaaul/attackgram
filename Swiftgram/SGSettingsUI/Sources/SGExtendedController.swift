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
import SGStrings

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
        openIgnored: {
            pushControllerImpl?(sgIgnoredController(context: context))
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
        },
        toggleFakeBalance: { value in
            SGSimpleSettings.shared.fakeBalanceEnabled = value
            statePromise.set(true)
        },
        updateFakeStars: { value in
            SGSimpleSettings.shared.fakeStarsBalance = value.trimmingCharacters(in: .whitespacesAndNewlines).filter { $0.isNumber }
        },
        updateFakeTon: { value in
            SGSimpleSettings.shared.fakeTonBalance = value.trimmingCharacters(in: .whitespacesAndNewlines).filter { $0.isNumber }
        },
        toggleFakeGifts: { value in
            SGSimpleSettings.shared.fakeGiftsEnabled = value
            statePromise.set(true)
        }
    )

    let signal = combineLatest(context.sharedContext.presentationData, statePromise.get(), searchPromise.get())
    |> map { presentationData, _, searchQuery -> (ItemListControllerState, (ItemListNodeState, Any)) in
        let strings = presentationData.strings
        let lang = strings.baseLanguageCode
        var entries: [SGExtendedEntry] = []
        entries.append(.search(strings.Common_Search, searchQuery))

        var items: [SGExtendedEntry] = []
        items.append(.unlimitedPins("Attack.Extended.UnlimitedPins".i18n(lang), SGSimpleSettings.shared.unlimitedPinnedChats))
        items.append(.themes("Attack.Extended.Themes".i18n(lang)))
        items.append(.invisibleMode("Attack.Extended.InvisibleMode".i18n(lang), SGSimpleSettings.shared.invisibleMode))
        items.append(.hideOnline("Attack.Extended.HideOnline".i18n(lang), SGSimpleSettings.shared.hideOnlineStatus))
        items.append(.hideTyping("Attack.Extended.HideTyping".i18n(lang), SGSimpleSettings.shared.hideTypingStatus))
        items.append(.dontSendRead("Attack.Extended.DontSendRead".i18n(lang), SGSimpleSettings.shared.dontSendReadReceipts))
        items.append(.voiceVideoReceipts("Attack.Extended.VoiceVideoReceipts".i18n(lang), SGSimpleSettings.shared.dontSendVoiceVideoReceipts))
        items.append(.ignoredList("Attack.Extended.IgnoredList".i18n(lang)))
        items.append(.saveEditHistory("Attack.Extended.SaveEditHistory".i18n(lang), SGSimpleSettings.shared.saveEditHistory))
        items.append(.saveDeleted("Attack.Extended.SaveDeleted".i18n(lang), SGSimpleSettings.shared.saveDeletedMessages))
        if SGSimpleSettings.shared.saveDeletedMessages {
            items.append(.saveDeletedBots("Attack.Extended.SaveDeletedBots".i18n(lang), SGSimpleSettings.shared.saveDeletedFromBots))
            items.append(.saveDeletedSelf("Attack.Extended.SaveDeletedSelf".i18n(lang), SGSimpleSettings.shared.saveDeletedFromSelf))
        }
        items.append(.clearDeleted("Attack.Extended.ClearDeleted".i18n(lang)))
        items.append(.clearEdited("Attack.Extended.ClearEdited".i18n(lang)))
        items.append(.fakeBalance("Attack.Extended.FakeBalance".i18n(lang), SGSimpleSettings.shared.fakeBalanceEnabled))
        if SGSimpleSettings.shared.fakeBalanceEnabled {
            items.append(.fakeStars("Attack.Extended.FakeStars".i18n(lang), SGSimpleSettings.shared.fakeStarsBalance))
            items.append(.fakeTon("Attack.Extended.FakeTon".i18n(lang), SGSimpleSettings.shared.fakeTonBalance))
            items.append(.fakeGifts("Attack.Extended.FakeGifts".i18n(lang), SGSimpleSettings.shared.fakeGiftsEnabled))
        }

        let trimmedQuery = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !trimmedQuery.isEmpty {
            items = items.filter { $0.searchableTitle.lowercased().contains(trimmedQuery) }
        }
        entries.append(contentsOf: items)

        let controllerState = ItemListControllerState(presentationData: ItemListPresentationData(presentationData), title: .text("Attack.Extended.Title".i18n(lang)), leftNavigationButton: nil, rightNavigationButton: nil, backNavigationButton: ItemListBackButton(title: presentationData.strings.Common_Back))
        let listState = ItemListNodeState(presentationData: ItemListPresentationData(presentationData), entries: entries, style: .blocks)
        return (controllerState, (listState, arguments))
    }

    let controller = ItemListController(context: context, state: signal)
    pushControllerImpl = { [weak controller] c in
        (controller?.navigationController as? NavigationController)?.pushViewController(c)
    }
    return controller
}
