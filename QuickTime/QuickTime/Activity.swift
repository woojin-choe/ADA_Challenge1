//
//  Activity.swift
//  QuickTime
//
//  Created by 최우진 on 4/7/26.
//

import Foundation
import CoreLocation

struct Activity: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let icon: String
    let requiredMinutes: Int
    let category: String
    let latitude: Double
    let longitude: Double

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    func distance(from userLocation: CLLocationCoordinate2D) -> Double {
        let from = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        let to = CLLocation(latitude: latitude, longitude: longitude)
        return from.distance(from: to)
    }

    func formattedDistance(from userLocation: CLLocationCoordinate2D) -> String {
        let d = distance(from: userLocation)
        return d < 1000 ? "\(Int(d))m" : String(format: "%.1fkm", d / 1000)
    }
}
