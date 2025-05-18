//
//  AddMenuIntent.swift
//  CanteenMateV2
//
//  Created by Ahmed Nizhan Haikal on 18/05/25.
//

import AppIntents

struct AddMenuIntent: AppIntent {
    static var title: LocalizedStringResource = "Add Menu"

    static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        MenuIntentRouter.shared.triggerAddMenu = true
        return .result()
    }
}
