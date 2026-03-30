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
    
    @State private var text: String = ""
    
    @State private var currentMinutes: Double = 45
        
        let totalMinutes: Double = 180
        
        let size: CGFloat = 300
        let progressLineWidth: CGFloat = 10
        let backgroundLineWidth: CGFloat = 2
        
        private var progress: Double {
            currentMinutes / totalMinutes
        }
    
    var body: some View {
        VStack{
            Text("남는 시간")
                .font(.title)
                .fontWeight(.light)
            
            Spacer().frame(height: 20)
            
            Button{
                //navigation 처리
            }label: {
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 22, weight: .regular))
                        .foregroundColor(Color(.systemGray))
                    
                    if text==""{
                        Text("지금 어디에 있나요?")
                           .font(.system(size: 18, weight: .regular))
                            .foregroundColor(.gray.opacity(0.7))
                    }
                    else{
                        Text(text)
                           .font(.system(size: 18, weight: .regular))
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .frame(width: 342, height: 55)
                .background(
                    RoundedRectangle(cornerRadius: 32)
                        .fill(Color.gray.opacity(0.1))
                )
            }
            
            Spacer().frame(height: 50)
            
            
            //원형 슬라이더
            ZStack {
                        // 바깥 연한 원
                        Circle()
                            .stroke(Color.blue.opacity(0.12), lineWidth: backgroundLineWidth)
                            .frame(width: size, height: size)
                        
                        // 12시, 3시, 6시, 9시 방향 눈금
                        ForEach(0..<4) { i in
                            Rectangle()
                                .fill(Color.gray.opacity(0.22))
                                .frame(width: 3, height: 18)
                                .offset(y: -(size / 2) + 12)
                                .rotationEffect(.degrees(Double(i) * 90))
                        }
                        
                        // 진행 링
                        Circle()
                            .trim(from: 0, to: progress)
                            .stroke(
                                Color("DarkBlue"),
                                style: StrokeStyle(
                                    lineWidth: progressLineWidth,
                                    lineCap: .round
                                )
                            )
                            .frame(width: size - 8, height: size - 8)
                            .rotationEffect(.degrees(-90))
                        
                        // 드래그 손잡이
                        Circle()
                            .fill(Color("DarkBlue"))
                            .frame(width: 22, height: 22)
                            .offset(y: -((size - 8) / 2))
                            .rotationEffect(.degrees(progress * 360))
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { drag in
                                        updateSlider(location: drag.location)
                                    }
                            )
                        
                        // 가운데 텍스트
                        Text("\(Int(currentMinutes))분")
                            .font(.system(size: 56, weight: .bold))
                            .foregroundColor(Color("DarkBlue"))
                    }
                    .frame(width: size, height: size)
            
            
            Spacer().frame(height: 50)
            
            Text("<추천 활동>")
                .font(.title2)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity, alignment: .center)
                
                
            
            Spacer().frame(height: 20)
            
            VStack{
                HStack{
                    CategoryChipView(
                        title:categories[0].title,
                        icon: categories[0].icon,
                        isSelected: $categories[0].isSelected
                    )
                    CategoryChipView(
                        title:categories[1].title,
                        icon: categories[1].icon,
                        isSelected: $categories[1].isSelected
                    )
                    CategoryChipView(
                        title:categories[2].title,
                        icon: categories[2].icon,
                        isSelected: $categories[2].isSelected
                    )
                }//Hstack end
                HStack{
                    CategoryChipView(
                        title:categories[3].title,
                        icon: categories[3].icon,
                        isSelected: $categories[3].isSelected
                    )
                    CategoryChipView(
                        title:categories[4].title,
                        icon: categories[4].icon,
                        isSelected: $categories[4].isSelected
                    )
                    
                    
                } //Hstack end
            } //Vstack end
            
            Spacer()
            
            //선택 버튼
            Button{
                //이제 선택한 추천활동 찾아서 다음 뷰로 넘기면 됨
            } label: {
                Text("선택")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(Color.white)
                    .frame(width: 310, height: 55)
                    .background(
                        RoundedRectangle(cornerRadius: 30)
                            .fill(Color.darkBlue)
                    )
            }
            Spacer()
            
            
        } //가장 큰 Vstack end
        .padding(.horizontal, 16)
    }
    private func updateSlider(location: CGPoint) {
            let center = CGPoint(x: size / 2, y: size / 2)
            
            let dx = location.x - center.x
            let dy = location.y - center.y
            
            var angle = atan2(dy, dx) * 180 / .pi
            
            angle += 90
            
            if angle < 0 {
                angle += 360
            }
            
            let newProgress = angle / 360
            let rawMinutes = newProgress * totalMinutes
            
            currentMinutes = rawMinutes.rounded()
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
        Button{
            if isSelected==true{
                isSelected=false
            }
            else{
                isSelected=true
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
                Text(title)
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundColor(isSelected ? .white : .black)
            .frame(width: 95, height: 48)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(isSelected ? Color.darkBlue : Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(isSelected ? Color.clear : Color.black, lineWidth: 0.5)
            )
        }
        
        
        
    }
}


#Preview {
    HomeView()
}
