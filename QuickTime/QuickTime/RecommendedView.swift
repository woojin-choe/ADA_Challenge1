//
//  RecommendedView.swift
//  QuickTime
//
//  Created by 최우진 on 4/7/26.
//

import SwiftUI

struct RecommendedView: View {
    let selectedCategories: [ActivityCategory]
    let minutes: Int
    
    var body: some View {
        // 받은 데이터로 UI 구성
        VStack {
            Text("\(minutes)분")
            ForEach(selectedCategories) { category in
                Text(category.title)
            }
        }
    }
}

#Preview {
    RecommendedView(
        selectedCategories: [
            ActivityCategory(title: "운동", icon: "dumbbell.fill", isSelected: true)
        ],
        minutes: 45
    )
}
