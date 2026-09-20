import Foundation
import Display
import SwiftSignalKit
import TelegramCore
import TelegramPresentationData
import TelegramUIPreferences
import ItemListUI
import PresentationDataUtils
import AccountContext

private enum SGThemesSection: Int32 {
    case light
    case dark
}

private final class SGThemesArguments {
    let selectTheme: (Int32) -> Void

    init(selectTheme: @escaping (Int32) -> Void) {
        self.selectTheme = selectTheme
    }
}

private enum SGThemeEntry: ItemListNodeEntry {
    case theme(Int32, Int32, String, Int32)

    var section: ItemListSectionId {
        switch self {
        case let .theme(_, sectionValue, _, _):
            return sectionValue
        }
    }

    var stableId: Int32 {
        switch self {
        case let .theme(stableValue, _, _, _):
            return stableValue
        }
    }

    static func <(lhs: SGThemeEntry, rhs: SGThemeEntry) -> Bool {
        return lhs.stableId < rhs.stableId
    }

    func item(presentationData: ItemListPresentationData, arguments: Any) -> ListViewItem {
        let arguments = arguments as! SGThemesArguments
        switch self {
        case let .theme(_, _, title, rawValue):
            return ItemListActionItem(presentationData: presentationData, title: title, kind: .neutral, alignment: .natural, sectionId: self.section, style: .blocks, action: {
                arguments.selectTheme(rawValue)
            })
        }
    }
}

private func applyBuiltinTheme(context: AccountContext, rawValue: Int32) {
    guard let builtin = PresentationBuiltinThemeReference(rawValue: rawValue) else {
        return
    }
    let reference = PresentationThemeReference.builtin(builtin)
    let _ = updatePresentationThemeSettingsInteractively(accountManager: context.sharedContext.accountManager, { current in
        if builtin == .night || builtin == .nightAccent {
            var updatedAutomaticThemeSwitchSetting = current.automaticThemeSwitchSetting
            updatedAutomaticThemeSwitchSetting.theme = reference
            return current.withUpdatedTheme(reference).withUpdatedAutomaticThemeSwitchSetting(updatedAutomaticThemeSwitchSetting)
        } else {
            return current.withUpdatedTheme(reference)
        }
    }).start()
}

public func sgThemesController(context: AccountContext) -> ViewController {
    let arguments = SGThemesArguments(selectTheme: { rawValue in
        applyBuiltinTheme(context: context, rawValue: rawValue)
    })

    let signal = context.sharedContext.presentationData
    |> map { presentationData -> (ItemListControllerState, (ItemListNodeState, Any)) in
        var entries: [SGThemeEntry] = []
        entries.append(.theme(0, SGThemesSection.light.rawValue, "Классическая", PresentationBuiltinThemeReference.dayClassic.rawValue))
        entries.append(.theme(1, SGThemesSection.light.rawValue, "Дневная", PresentationBuiltinThemeReference.day.rawValue))
        entries.append(.theme(2, SGThemesSection.dark.rawValue, "Ночная", PresentationBuiltinThemeReference.night.rawValue))
        entries.append(.theme(3, SGThemesSection.dark.rawValue, "Ночная синяя", PresentationBuiltinThemeReference.nightAccent.rawValue))

        let controllerState = ItemListControllerState(presentationData: ItemListPresentationData(presentationData), title: .text("Готовые темы"), leftNavigationButton: nil, rightNavigationButton: nil, backNavigationButton: ItemListBackButton(title: presentationData.strings.Common_Back))
        let listState = ItemListNodeState(presentationData: ItemListPresentationData(presentationData), entries: entries, style: .blocks)
        return (controllerState, (listState, arguments))
    }

    return ItemListController(context: context, state: signal)
}
