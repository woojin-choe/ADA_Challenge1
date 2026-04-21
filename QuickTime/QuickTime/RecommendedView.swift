//
//  RecommendedView.swift
//  QuickTime
//
//  Created by 최우진 on 4/7/26.
//

import SwiftUI
import MapKit
import CoreLocation

struct RecommendedView: View {
    let selectedCategories: [ActivityCategory]
    let minutes: Int
    var userLocation: CLLocationCoordinate2D? = nil

    // MARK: - Activities Data
    @State private var allActivities: [Activity] = []
    @State private var selectedActivity: Activity?  // 탭한 카드 → 경로 sheet

    private func loadActivities() -> [Activity] {
        guard let url = Bundle.main.url(forResource: "activities", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let result = try? JSONDecoder().decode([Activity].self, from: data)
        else {
            return [
                .init(id: UUID(), title: "풋살", description: "포항스틸야드 보조경기장에서 뛰어요", icon: "figure.soccer", requiredMinutes: 120, category: "운동", latitude: 36.0102, longitude: 129.3600),
                .init(id: UUID(), title: "헬스", description: "포항시민체육관에서 근력을 키워요", icon: "dumbbell.fill", requiredMinutes: 60, category: "운동", latitude: 36.0188, longitude: 129.3480),
                .init(id: UUID(), title: "환호공원 산책", description: "환호공원을 천천히 걸어요", icon: "figure.walk", requiredMinutes: 30, category: "산책", latitude: 36.0328, longitude: 129.3847),
                .init(id: UUID(), title: "도서관 독서", description: "포항시립중앙도서관에서 책을 읽어요", icon: "book.closed", requiredMinutes: 30, category: "공부", latitude: 36.0317, longitude: 129.3652),
                .init(id: UUID(), title: "스트레칭", description: "환호스포츠파크에서 몸을 풀어요", icon: "figure.mind.and.body", requiredMinutes: 15, category: "요가", latitude: 36.0328, longitude: 129.3847),
                .init(id: UUID(), title: "영일대 카페", description: "영일대 카페거리에서 커피 한 잔 해요", icon: "cup.and.saucer", requiredMinutes: 30, category: "휴식", latitude: 36.0571, longitude: 129.3791)
            ]
        }
        return result
    }

    // MARK: - 필터링
    private var recommendedActivities: [Activity] {
        let selectedTitles = selectedCategories.map { $0.title }
        return allActivities.filter {
            selectedTitles.contains($0.category) && $0.requiredMinutes <= minutes
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {

                // MARK: 활동 위치 지도
                activityMap
                    .frame(height: 250)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 16)

                // 추천 타이틀
                Text("당신을 위한 추천")
                    .font(.title2).bold()
                    .foregroundStyle(Color.darkBlue)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)

                // 카드 리스트
                if recommendedActivities.isEmpty {
                    Text("시간 내에 할 수 있는 활동이 없어요 😢")
                        .foregroundStyle(.gray)
                        .padding()
                } else {
                    ForEach(recommendedActivities) { activity in
                        Button {
                            selectedActivity = activity
                        } label: {
                            ActivityCardView(activity: activity, userLocation: userLocation)
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 12)
                    }
                }
            }
            .padding(.top)
        }
        .navigationTitle("추천 활동")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            allActivities = loadActivities()
        }
        .sheet(item: $selectedActivity) { activity in
            if let loc = userLocation {
                RouteMapView(activity: activity, userLocation: loc)
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "location.slash")
                        .font(.system(size: 40))
                        .foregroundStyle(.gray)
                    Text("위치를 먼저 설정해주세요")
                        .font(.system(size: 16))
                        .foregroundStyle(.gray)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }

    // MARK: - 활동 위치 지도
    @ViewBuilder
    private var activityMap: some View {
        let center: CLLocationCoordinate2D = recommendedActivities.first?.coordinate
            ?? CLLocationCoordinate2D(latitude: 36.0190, longitude: 129.3435)

        Map(initialPosition: .region(MKCoordinateRegion(
            center: center,
            span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
        ))) {
            // 내 위치 핀
            if let loc = userLocation {
                Annotation("내 위치", coordinate: loc) {
                    VStack(spacing: 2) {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 28, height: 28)
                                .shadow(color: .black.opacity(0.2), radius: 3, y: 1)
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 18, height: 18)
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                                .frame(width: 18, height: 18)
                        }
                        Text("내 위치")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(.blue)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(Color.white.opacity(0.85))
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                }
            }

            // 활동 핀
            ForEach(recommendedActivities) { activity in
                Annotation(activity.title, coordinate: activity.coordinate) {
                    Image(systemName: activity.icon)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(7)
                        .background(Color.darkBlue)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.2), radius: 2, y: 1)
                }
            }
        }
        .mapControls {
            MapCompass()
        }
    }
}

// MARK: - Activity Card View
struct ActivityCardView: View {
    let activity: Activity
    var userLocation: CLLocationCoordinate2D? = nil

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.15))
                .frame(width: 80, height: 80)
                .overlay(
                    Image(systemName: activity.icon)
                        .font(.system(size: 30))
                        .foregroundStyle(Color.darkBlue)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(activity.title)
                    .font(.system(size: 16, weight: .semibold))
                Text(activity.description)
                    .font(.system(size: 14))
                    .foregroundStyle(.gray)
                    .lineLimit(2)
                HStack(spacing: 8) {
                    Text("\(activity.requiredMinutes)분 소요")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.darkBlue)
                    if let loc = userLocation {
                        Text("·")
                            .font(.system(size: 12))
                            .foregroundStyle(.gray)
                        Text(activity.formattedDistance(from: loc))
                            .font(.system(size: 12))
                            .foregroundStyle(.gray)
                    }
                }
            }

            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .gray.opacity(0.15), radius: 4, y: 2)
        )
    }
}

// MARK: - Route Map View
struct RouteMapView: View {
    let activity: Activity
    let userLocation: CLLocationCoordinate2D

    @State private var walkingRoute: MKRoute?
    @State private var drivingRoute: MKRoute?
    @State private var cameraPosition: MapCameraPosition = .automatic

    // 도보·차량은 MKDirections 결과, 자전거는 도보 경로 거리 ÷ 15km/h로 추정
    private func minutes(from route: MKRoute?) -> String? {
        guard let route else { return nil }
        return "\(Int((route.expectedTravelTime / 60).rounded(.up)))분"
    }

    private var cyclingMinutes: String? {
        guard let route = walkingRoute else { return nil }
        let mins = Int((route.distance / 1000 / 15 * 60).rounded(.up))  // 15 km/h 기준
        return "\(mins)분"
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {

                // MARK: 지도 + 경로 선
                Map(position: $cameraPosition) {
                    UserAnnotation()

                    Annotation(activity.title, coordinate: activity.coordinate) {
                        Image(systemName: activity.icon)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(.white)
                            .padding(7)
                            .background(Color.darkBlue)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.2), radius: 2, y: 1)
                    }

                    // 도보 경로 (실선)
                    if let route = walkingRoute {
                        MapPolyline(route.polyline)
                            .stroke(Color.darkBlue, style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
                    }
                }
                .mapControls {
                    MapCompass()
                    MapScaleView()
                }
                .ignoresSafeArea(edges: .bottom)

                // MARK: 하단 정보 카드
                VStack(spacing: 12) {
                    Text(activity.title)
                        .font(.system(size: 18, weight: .semibold))

                    HStack(spacing: 0) {
                        travelCell(
                            icon: "figure.walk",
                            label: "도보",
                            value: minutes(from: walkingRoute)
                        )
                        Divider().frame(height: 36)
                        travelCell(
                            icon: "bicycle",
                            label: "자전거",
                            value: cyclingMinutes
                        )
                        Divider().frame(height: 36)
                        travelCell(
                            icon: "car",
                            label: "차량",
                            value: minutes(from: drivingRoute)
                        )
                    }
                }
                .padding(.vertical, 20)
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.horizontal, 16)
                .padding(.bottom, 36)

            } // ZStack end
            .navigationTitle("경로")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            fitCamera()
            calculateRoute(type: .walking)    { walkingRoute = $0 }
            calculateRoute(type: .automobile) { drivingRoute = $0 }
        }
    }

    // 이동수단별 셀
    private func travelCell(icon: String, label: String, value: String?) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(Color.darkBlue)
            Text(label)
                .font(.system(size: 11))
                .foregroundStyle(.gray)
            if let value {
                Text(value)
                    .font(.system(size: 14, weight: .semibold))
            } else {
                ProgressView().scaleEffect(0.7)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func fitCamera() {
        let minLat = min(userLocation.latitude, activity.coordinate.latitude)
        let maxLat = max(userLocation.latitude, activity.coordinate.latitude)
        let minLon = min(userLocation.longitude, activity.coordinate.longitude)
        let maxLon = max(userLocation.longitude, activity.coordinate.longitude)
        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )
        let span = MKCoordinateSpan(
            latitudeDelta: max((maxLat - minLat) * 1.6, 0.01),
            longitudeDelta: max((maxLon - minLon) * 1.6, 0.01)
        )
        cameraPosition = .region(MKCoordinateRegion(center: center, span: span))
    }

    // transport 타입별로 MKDirections 요청 (같은 패턴, 타입만 다름)
    private func calculateRoute(type: MKDirectionsTransportType, completion: @escaping (MKRoute) -> Void) {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: userLocation))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: activity.coordinate))
        request.transportType = type
        MKDirections(request: request).calculate { response, _ in
            if let r = response?.routes.first {
                completion(r)
            }
        }
    }
}

#Preview("RecommendedView") {
    RecommendedView(
        selectedCategories: [
            ActivityCategory(title: "운동", icon: "dumbbell.fill", isSelected: true),
            ActivityCategory(title: "산책", icon: "figure.walk", isSelected: true)
        ],
        minutes: 60
    )
}
