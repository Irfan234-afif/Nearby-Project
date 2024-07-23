//
//  Payload.swift
//  Nearby Project
//
//  Created by irfan  Afifi on 16/02/24.
//

import Foundation
import NearbyConnections
struct Payload: Identifiable {
    let id: PayloadID
    var type: PayloadType
    var status: Status
    let isIncoming: Bool
    let cancellationToken: CancellationToken?

    enum PayloadType {
        case bytes, stream, file
    }
    enum Status {
        case inProgress(Progress), success, failure, canceled
    }
    
    // Properti computed untuk mengambil nilai Progress jika statusnya inProgress
        var progressValue: Progress? {
            switch status {
            case .inProgress(let progress):
                return progress
            default:
                return nil
            }
        }
}
