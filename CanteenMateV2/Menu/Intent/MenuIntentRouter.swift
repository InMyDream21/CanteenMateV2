//
//  MenuIntentRouter.swift
//  CanteenMateV2
//
//  Created by Ahmed Nizhan Haikal on 18/05/25.
//
import Foundation

class MenuIntentRouter: ObservableObject {
    static let shared = MenuIntentRouter()

    @Published var triggerAddMenu: Bool = false
}
