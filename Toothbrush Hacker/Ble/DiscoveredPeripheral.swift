//
//  DiscoveredPeripheral.swift
//  Toothbrush Hacker
//
//  Created by Jason Vance on 8/28/23.
//

import Foundation
import CoreBluetooth

struct DiscoveredPeripheral: Identifiable {
    var id: UUID { peripheral.identifier }
    let peripheral: CBPeripheral
    let advertisementData: [String: Any]
    let rssi: NSNumber
}

extension DiscoveredPeripheral: Equatable {
    
    static func == (lhs: DiscoveredPeripheral, rhs: DiscoveredPeripheral) -> Bool {
        lhs.peripheral == rhs.peripheral
    }
}

extension DiscoveredPeripheral: Hashable {
    
    var hashValue: Int { peripheral.hashValue }
    
    func hash(into hasher: inout Hasher) {
        peripheral.hash(into: &hasher)
    }
}
