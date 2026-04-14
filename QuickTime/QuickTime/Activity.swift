//
//  Activity.swift
//  QuickTime
//
//  Created by 최우진 on 4/7/26.
//

import Foundation

struct Activity: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    let requiredMinutes: Int
    let category: String
}
