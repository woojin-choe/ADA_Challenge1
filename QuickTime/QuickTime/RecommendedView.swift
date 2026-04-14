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
    
    // 전체 활동 데이터
    let allActivities: [Activity] = [
        .init(title: "풋살", description: "친구들과 함께 뛰어요", icon: "figure.soccer", requiredMinutes: 120, category: "운동"),
        .init(title: "헬스", description: "근력을 키워보세요", icon: "dumbbell.fill", requiredMinutes: 60, category: "운동"),
        .init(title: "줄넘기", description: "가볍게 땀 흘리기", icon: "figure.jumprope", requiredMinutes: 20, category: "운동"),
        .init(title: "공원 산책", description: "가까운 공원을 걸어요", icon: "figure.walk", requiredMinutes: 30, category: "산책"),
        .init(title: "한강 산책", description: "한강변을 따라 걸어요", icon: "figure.walk", requiredMinutes: 60, category: "산책"),
        .init(title: "유튜브 강의", description: "짧게 하나만 들어요", icon: "play.rectangle", requiredMinutes: 15, category: "공부"),
        .init(title: "독서", description: "책 한 챕터 읽기", icon: "book.closed", requiredMinutes: 30, category: "공부"),
        .init(title: "스트레칭", description: "몸을 가볍게 풀어요", icon: "figure.mind.and.body", requiredMinutes: 15, category: "요가"),
        .init(title: "명상", description: "마음을 비워보세요", icon: "figure.mind.and.body", requiredMinutes: 20, category: "요가"),
        .init(title: "낮잠", description: "잠깐 눈을 붙여요", icon: "bed.double", requiredMinutes: 20, category: "휴식"),
        .init(title: "카페 멍때리기", description: "커피 한 잔의 여유", icon: "cup.and.saucer", requiredMinutes: 30, category: "휴식"),
    ]
    
    // 필터링
    private var recommendedActivities: [Activity] {
        let selectedTitles = selectedCategories.map { $0.title }
        var result: [Activity] = []
        for activity in allActivities {
            if selectedTitles.contains(activity.category) && activity.requiredMinutes <= minutes {
                result.append(activity)
            }
        }
        return result
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                
                // 지도 영역 placeholder
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.gray.opacity(0.15))
                    .frame(height: 200)
                    .overlay(
                        Text("📍 지도")
                            .foregroundColor(.gray)
                    )
                    .padding(.horizontal, 16)
                    .padding(.vertical, 20)
                
                // 추천 타이틀
                Text("당신을 위한 추천")
                    .font(.title2).bold()
                    .foregroundColor(Color.darkBlue)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
                
                // 카드 리스트
                if recommendedActivities.isEmpty {
                    Text("시간 내에 할 수 있는 활동이 없어요 😢")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ForEach(recommendedActivities) { activity in
                        ActivityCardView(activity: activity)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 12)
                    }
                }
            }
            .padding(.top)
        }
        .navigationTitle("추천 활동")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ActivityCardView: View {
    let activity: Activity
    
    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.15))
                .frame(width: 80, height: 80)
                .overlay(
                    Image(systemName: activity.icon)
                        .font(.system(size: 30))
                        .foregroundColor(Color.darkBlue)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(activity.title)
                    .font(.system(size: 16, weight: .semibold))
                Text(activity.description)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .lineLimit(2)
                Text("\(activity.requiredMinutes)분 소요")
                    .font(.system(size: 12))
                    .foregroundColor(Color.darkBlue)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .gray.opacity(0.15), radius: 4, y: 2)
        )
        .padding(.horizontal)
    }
}

#Preview {
    RecommendedView(
        selectedCategories: [
            ActivityCategory(title: "운동", icon: "dumbbell.fill", isSelected: true),
            ActivityCategory(title: "산책", icon: "figure.walk", isSelected: true)
        ],
        minutes: 45
    )
}
