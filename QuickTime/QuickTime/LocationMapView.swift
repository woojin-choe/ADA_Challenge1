//
//  LocationMapView.swift
//  QuickTime
//
//  Created by 최우진 on 4/15/26.
//

import SwiftUI
import MapKit
import CoreLocation
import Combine

// CLLocationCoordinate2D는 원래 비교가 불가능한 타입 .onChange(of:) 에서 "값이 바뀌었는지" 비교하려면 Equatable이 필요해서 직접 구현
extension CLLocationCoordinate2D: @retroactive Equatable { //익스텐션을 만들겠다
    // ==을 사용했을때를 정의할건데
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool { //두 좌표가 같으면 true 리턴 아니면 false리턴
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude // 위도/경도 둘 다 같으면 같은 좌표
    }
}

// LocationManager는 iOS한테 GPS 권한을 받고 내 위치 좌표 가져와서 View에 전달해주는 중간관리 함수
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()

    @Published var userLocation: CLLocationCoordinate2D?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        if manager.authorizationStatus == .authorizedWhenInUse ||
           manager.authorizationStatus == .authorizedAlways {
            manager.startUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations.last?.coordinate
        manager.stopUpdatingLocation()
    }
}

// MARK: - Location Map View
struct LocationMapView: View {
    @Binding var userLocation: CLLocationCoordinate2D? // sheet 열때 현재 위치값 받고
    @Binding var locationName: String                  // 선택된 장소 이름을 HomeView로 돌려줄 변수

    @StateObject private var locationManager = LocationManager()
    @State private var cameraPosition: MapCameraPosition = .region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 36.0190, longitude: 129.3435),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    ))
    @State private var searchText = ""
    @State private var searchResults: [MKMapItem] = []
    @State private var selectedPin: CLLocationCoordinate2D?
    @State private var selectedName: String = "" // 선택된 장소 이름 임시 보관
    @State private var isDraggingPin = false
    @State private var isShowingResults = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {

                // MARK: 지도 + 드래그 가능한 핀 오버레이
                MapReader { proxy in
                    ZStack {
                        Map(position: $cameraPosition) {
                            UserAnnotation()
                        } //Map end
                        .mapControls {
                            MapCompass()
                            MapScaleView()
                        }
                        .onTapGesture { screenPoint in
                            if let coord = proxy.convert(screenPoint, from: .local) {
                                withAnimation(.spring(duration: 0.2)) {
                                    selectedPin = coord
                                }
                                getNearbyName(for: coord) // 탭한 좌표 근처 장소명 가져오기
                                isShowingResults = false
                                hideKeyboard()
                            }
                        }
                        .onAppear {
                            locationManager.requestPermission()
                        }
                        .onChange(of: locationManager.userLocation) { _, newLocation in
                            if let coord = newLocation {
                                withAnimation {
                                    cameraPosition = .region(MKCoordinateRegion(
                                        center: coord,
                                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                                    ))
                                }
                            }
                        }

                        // 드래그 가능한 핀
                        if let pin = selectedPin,
                           let screenPoint = proxy.convert(pin, to: .local) {
                            draggablePin
                                .position(x: screenPoint.x, y: screenPoint.y - 24)
                                .gesture(
                                    DragGesture(minimumDistance: 0)
                                        .onChanged { value in
                                            isDraggingPin = true
                                            let adjustedPoint = CGPoint(
                                                x: value.location.x,
                                                y: value.location.y + 24
                                            )
                                            if let coord = proxy.convert(adjustedPoint, from: .local) {
                                                selectedPin = coord
                                            }
                                        }
                                        .onEnded { _ in
                                            isDraggingPin = false
                                        }
                                )
                        } //draggablePin end

                    } //ZStack(지도+핀) end
                } //MapReader end
                .ignoresSafeArea(edges: .bottom)

                // MARK: 검색바 + 결과 목록
                VStack(spacing: 4) {
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.gray)
                        TextField("장소 검색", text: $searchText)
                            .submitLabel(.search)
                            .onSubmit { searchLocation() }
                            .onChange(of: searchText) { _, newValue in
                                if newValue.isEmpty {
                                    searchResults = []
                                    isShowingResults = false
                                }
                            }
                        if !searchText.isEmpty {
                            Button {
                                searchText = ""
                                searchResults = []
                                isShowingResults = false
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.gray)
                            }
                        }
                    } //HStack(검색바) end
                    .padding(12)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: .gray.opacity(0.25), radius: 4, y: 2)
                    .padding(.horizontal, 16)
                    .padding(.top, 12)

                    if isShowingResults && !searchResults.isEmpty {
                        ScrollView {
                            VStack(spacing: 0) {
                                ForEach(searchResults, id: \.self) { item in
                                    Button {
                                        selectResult(item)
                                    } label: {
                                        HStack(spacing: 12) {
                                            Image(systemName: "mappin.circle")
                                                .font(.system(size: 18))
                                                .foregroundStyle(Color.darkBlue)
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(item.name ?? "알 수 없는 장소")
                                                    .font(.system(size: 14, weight: .medium))
                                                    .foregroundStyle(.black)
                                            } //VStack(장소명) end
                                            Spacer()
                                        } //HStack(검색결과 행) end
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 10)
                                    }
                                    Divider().padding(.leading, 48)
                                }
                            } //VStack(검색결과 목록) end
                        } //ScrollView end
                        .frame(maxHeight: 240)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: .gray.opacity(0.2), radius: 4, y: 2)
                        .padding(.horizontal, 16)
                    } //검색결과 if end

                } //VStack(검색바+결과) end

                // MARK: 내 위치 버튼
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            if let coord = locationManager.userLocation {
                                withAnimation {
                                    cameraPosition = .region(MKCoordinateRegion(
                                        center: coord,
                                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                                    ))
                                }
                            } else {
                                locationManager.requestPermission()
                            }
                        } label: {
                            Image(systemName: "location.fill")
                                .font(.system(size: 18))
                                .foregroundStyle(Color.darkBlue)
                                .padding(12)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(color: .gray.opacity(0.3), radius: 4, y: 2)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, selectedPin != nil ? 100 : 40)
                    } //HStack(내 위치 버튼) end
                } //VStack(내 위치 버튼) end

                // MARK: 위치 선택 완료 버튼
                if selectedPin != nil && !isDraggingPin {
                    VStack {
                        Spacer()
                        Button {
                            userLocation = selectedPin
                            locationName = selectedName // 장소명 HomeView로 전달
                            dismiss()
                        } label: {
                            Text("이 위치로 설정")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.darkBlue)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 36)
                    } //VStack(완료 버튼) end
                } //완료 버튼 if end

                // MARK: 권한 거부 안내
                if locationManager.authorizationStatus == .denied ||
                   locationManager.authorizationStatus == .restricted {
                    VStack {
                        Spacer().frame(height: 80)
                        VStack(spacing: 6) {
                            Text("위치 권한이 필요해요")
                                .font(.system(size: 14, weight: .semibold))
                            Text("설정 > 개인 정보 보호에서 위치 접근을 허용해주세요")
                                .font(.system(size: 12))
                                .foregroundStyle(.gray)
                                .multilineTextAlignment(.center)
                        } //VStack(안내 텍스트) end
                        .padding()
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: .gray.opacity(0.2), radius: 4)
                        .padding(.horizontal, 24)
                        Spacer()
                    } //VStack(권한 거부 안내) end
                } //권한 거부 if end

            } //ZStack(가장 큰) end
            .navigationTitle("위치 찾기")
            .navigationBarTitleDisplayMode(.inline)
        } //NavigationStack end
    }

    // MARK: - Pin View
    private var draggablePin: some View {
        VStack(spacing: 0) {
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.15))
                    .frame(width: isDraggingPin ? 56 : 0)
                    .animation(.easeOut(duration: 0.15), value: isDraggingPin)

                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(.red)
                    .scaleEffect(isDraggingPin ? 1.3 : 1.0)
                    .animation(.spring(duration: 0.2), value: isDraggingPin)
            } //ZStack(핀 아이콘) end

            Image(systemName: "arrowtriangle.down.fill")
                .font(.system(size: 10))
                .foregroundStyle(.red)
                .offset(y: -5)
        } //VStack(핀) end
        .shadow(color: .black.opacity(isDraggingPin ? 0.3 : 0.15), radius: isDraggingPin ? 8 : 4, y: 2)
    }

    // MARK: - Helpers

    // 탭한 좌표 근처 장소 이름 찾기 (PDF에서 배운 MKLocalSearch 활용)
    private func getNearbyName(for coord: CLLocationCoordinate2D) {
        let request = MKLocalPointsOfInterestRequest(
            center: coord,
            radius: 300 // 300m 반경 안에서 가장 가까운 장소 찾기
        )
        MKLocalSearch(request: request).start { response, _ in
            if let item = response?.mapItems.first {
                selectedName = item.name ?? "선택된 위치"
            } else {
                selectedName = "선택된 위치"
            }
        }
    }

    private func searchLocation() {
        guard !searchText.isEmpty else { return }
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        if let userCoord = locationManager.userLocation {
            request.region = MKCoordinateRegion(
                center: userCoord,
                span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            )
        }
        MKLocalSearch(request: request).start { response, _ in
            if let items = response?.mapItems {
                searchResults = items
                isShowingResults = true
            }
        }
    }

    private func selectResult(_ item: MKMapItem) {
        // item.location은 CLLocation? 타입 → .coordinate로 좌표 꺼냄 (PDF에서 배운 방식)
        // ?? 뒤는 혹시 nil일 때 기본값 (위도0 경도0) — 실제로는 거의 안 생김
        let coord = item.location.coordinate // PDF에서 배운 방식 그대로
        selectedPin = coord
        isShowingResults = false
        searchText = item.name ?? ""
        selectedName = item.name ?? "선택된 위치" // 검색 결과 장소명
        withAnimation {
            cameraPosition = .region(MKCoordinateRegion(
                center: coord,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            ))
        }
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
