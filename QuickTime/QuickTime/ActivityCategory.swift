//
//  ActivityCategory.swift
//  QuickTime
//
//  Created by 최우진 on 4/7/26.
//

import Foundation

struct ActivityCategory: Identifiable, Codable {
    let id = UUID()
    let title: String
    let icon: String
    var isSelected: Bool

    enum CodingKeys: String, CodingKey {
        case title, icon, isSelected
    }
}
