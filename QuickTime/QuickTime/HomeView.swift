//
//  HomeView.swift
//  QuickTime
//
//  Created by 최우진 on 3/30/26.
//

import SwiftUI

struct HomeView: View {
    @State var categories: [ActivityCategory] = [
        .init(title: "운동", icon: "dumbbell.fill", isSelected: true),
        .init(title: "산책", icon: "figure.walk", isSelected: true),
        .init(title: "공부", icon: "book.closed", isSelected: false),
        .init(title: "요가", icon: "figure.mind.and.body", isSelected: false),
        .init(title: "휴식", icon: "cup.and.saucer", isSelected: false)
    ]
    
    var body: some View {
        VStack{
            Text("남는 시간")
                .font(.title2)
                .fontWeight(.light)
            Image("TextField")
            Image("TimeSet")
            
            Text("추천 활동")
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack{
                
//                CategoryChipView(title: "운동", icon: "dumbbell.fill", isSelected: true)
//                CategoryChipView(title: "산책", icon: "figure.walk", isSelected: true)
//                CategoryChipView(title: "공부", icon: "figure.walk", isSelected: true)
            }
                
            }
        .padding(.horizontal, 16)
    }
}

struct ActivityCategory: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    var isSelected: Bool
}

struct CategoryChipView: View {
    let title: String
    let icon: String
    @Binding var isSelected: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
            Text(title)
                .font(.system(size: 14, weight: .medium))
        }
        .foregroundColor(isSelected ? .white : .black)
        .frame(width: 95, height: 48)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(isSelected ? Color.darkBlue : Color.white)
        )
        
        
    }
}

#Preview {
    HomeView()
}
