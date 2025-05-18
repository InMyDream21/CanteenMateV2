//
//  Utility.swift
//  CanteenMateV2
//
//  Created by Ahmed Nizhan Haikal on 16/05/25.
//

import Foundation

func formatToIdr(_ amount: Int) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.groupingSeparator = "."
    return formatter.string(from: NSNumber(value: abs(amount))) ?? "\(abs(amount))"
}

func indexAddMenuActivity() {
    let activity = NSUserActivity(activityType: "com.hikaru.CanteenMateV2")
    activity.title = "Add Menu"
    activity.isEligibleForSearch = true
    activity.isEligibleForPrediction = true
    activity.persistentIdentifier = NSUserActivityPersistentIdentifier("com.hikaru.CanteenMateV2")
    activity.becomeCurrent()  // This tells the system to index this activity now
}
