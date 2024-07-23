//
//  PhoneStatus.swift
//  Nearby Project
//
//  Created by irfan  Afifi on 16/02/24.
//

import Foundation

struct PhoneStatus: Decodable {
    enum Category: String, Decodable {
        case swift, combine, debugging, xcode
    }

    let kind: String
    var endpointID :String?
    var endpointName : String?
    var battery_level : String?
    var batteryIcon : String?
    var isCharging : Bool?
    var signalLength : Double?
    func copyWith(endpointID: String? = nil,
                      endpointName: String? = nil,
                      battery_level: String? = nil,
                      batteryIcon: String? = nil,
                      isCharging: Bool? = nil,
                  signalLength: Double? = nil) -> PhoneStatus {
            return PhoneStatus(
                kind: kind,
                endpointID: endpointID ?? self.endpointID,
                endpointName: endpointName ?? self.endpointName,
                battery_level: battery_level ?? self.battery_level,
                batteryIcon: batteryIcon ?? self.batteryIcon,
                isCharging: isCharging ?? self.isCharging,
                signalLength: signalLength ?? self.signalLength
            )
        }
}
