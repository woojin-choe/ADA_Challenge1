//
//  HomeView.swift
//  QuickTime
//
//  Created by 최우진 on 3/30/26.
//

import SwiftUI
import MapKit

struct HomeView: View {
    //네비게이션에 쓸 변수
    @State private var navigateToRecommend = false

    //카테고리 담을 변수
    @State var categories: [ActivityCategory] = []

    // 위치 sheet
    @State private var showLocationSheet = false
    @State private var selectedLocation: CLLocationCoordinate2D?
    @State private var showLocationAlert = false
    @State private var alertMessage: (icon: String, title: String, body: String) = ("", "", "")
    
    
    //선택된 카테고리 체크
    private var selectedCategories: [ActivityCategory] {
        var result: [ActivityCategory] = []
        for category in categories {
            if category.isSelected {
                result.append(category)
            }
        }
        return result
    }
    
    

    // MARK: - Categories Data
    private func loadCategories() -> [ActivityCategory] {
        return [
            .init(title: "운동", icon: "dumbbell.fill", isSelected: true),
            .init(title: "산책", icon: "figure.walk", isSelected: true),
            .init(title: "공부", icon: "book.closed", isSelected: false),
            .init(title: "요가", icon: "figure.mind.and.body", isSelected: false),
            .init(title: "휴식", icon: "cup.and.saucer", isSelected: false)
        ]
    }
    
    @State private var text: String = ""
    
    //원형 슬라이더 변수
    @State private var currentMinutes: Double = 45 // 선택을 눌렀을 때 navigation으로 넘길 변수
    let totalMinutes: Double = 180
    let size: Double = 300
    let progressLineWidth: Double = 10
    let backgroundLineWidth: Double = 2
    private var progress: Double {
        currentMinutes / totalMinutes
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
    } //여기까지 원형 슬라이더 관련
    
    var body: some View {
        NavigationStack {
            VStack{
                Text("남는 시간")
                    .font(.title)
                    .fontWeight(.light)

                Spacer().frame(height: 20)

                Button{
                    showLocationSheet = true
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
                        .foregroundStyle(Color("DarkBlue"))
                }
                .frame(width: size, height: size) //여기 까지 원형슬라이더
                
                
                Spacer().frame(height: 50)
                
                Text("<추천 활동>")
                    .font(.title2)
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                
                
                Spacer().frame(height: 20)
                
                if categories.count >= 5 {
                    VStack(spacing: 12){
                        HStack(spacing: 12){
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
                        HStack(spacing: 12){
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
                }
                
                Spacer()

                //선택 버튼
                Button{
                    if selectedLocation == nil || selectedCategories.isEmpty {
                        alertMessage = selectedLocation == nil
                            ? (icon: "location.slash.fill",
                               title: "위치를 먼저 설정해주세요",
                               body: "상단 검색창에서 현재 위치를 선택하면\n추천 활동을 확인할 수 있어요")
                            : (icon: "hand.tap.fill",
                               title: "활동을 선택해주세요",
                               body: "하고 싶은 활동을 하나 이상\n선택한 후 다시 눌러주세요")
                        withAnimation(.spring(duration: 0.4)) {
                            showLocationAlert = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                            withAnimation(.spring(duration: 0.4)) {
                                showLocationAlert = false
                            }
                        }
                    } else {
                        navigateToRecommend = true
                    }
                } label: {
                    Text("선택")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.white)
                        .frame(width: 310, height: 55)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(selectedLocation == nil || selectedCategories.isEmpty ? Color.darkBlue.opacity(0.45) : Color.darkBlue)
                                .shadow(color: selectedLocation == nil || selectedCategories.isEmpty ? .clear : Color.darkBlue.opacity(0.4), radius: 10, y: 4)
                        )
                }
                Spacer()
                
                
            } //가장 큰 Vstack end
            .padding(.horizontal, 16)
            .onAppear {
                categories = loadCategories()
            }
            .sheet(isPresented: $showLocationSheet) {
                LocationMapView(
                    userLocation: $selectedLocation,
                    locationName: $text
                )
            }
            .navigationDestination(isPresented: $navigateToRecommend) {
                RecommendedView(
                    selectedCategories: selectedCategories,
                    minutes: Int(currentMinutes),
                    userLocation: selectedLocation
                )
            }
        .overlay {
                if showLocationAlert {
                    VStack(spacing: 14) {
                        Image(systemName: alertMessage.icon)
                            .font(.system(size: 28))
                            .foregroundStyle(.primary)
                        Text(alertMessage.title)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.primary)
                        Text(alertMessage.body)
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 28)
                    .padding(.vertical, 28)
                    .frame(width: 280)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.4), lineWidth: 0.8))
                    .shadow(color: .black.opacity(0.12), radius: 24, y: 8)
                    .transition(.scale(scale: 0.9).combined(with: .opacity))
                }
            }
        } //navigation end
        
        
    }
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
                .foregroundStyle(isSelected ? .white : .black)
                .frame(width: 95, height: 48)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(isSelected ? Color.darkBlue : Color.white)
                        .shadow(
                            color: isSelected ? Color.darkBlue.opacity(0.3) : Color.black.opacity(0.08),
                            radius: isSelected ? 6 : 3,
                            y: isSelected ? 3 : 2
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(isSelected ? Color.clear : Color.gray.opacity(0.25), lineWidth: 1)
                )
                .scaleEffect(isSelected ? 1.05 : 1.0)
                .animation(.spring(duration: 0.2), value: isSelected)
            }
            
            
            
        }
    }


#Preview {
    HomeView()
}
