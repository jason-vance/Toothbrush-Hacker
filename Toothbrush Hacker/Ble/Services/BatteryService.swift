//
//  BatteryService.swift
//  Toothbrush Hacker
//
//  Created by Jason Vance on 8/27/23.
//

import Foundation
import CoreBluetooth

class BatteryService: BleService, DeviceBatteryMonitor {
    
    static let uuid = CBUUID(string: "180F")
    static let characteristics: [CBUUID:BleCharacteristic] = [
        BatteryLevelCharacteristic.uuid: BatteryLevelCharacteristic()
    ]
    
    @Published var currentBatteryLevel: Float = 0
    var currentBatteryLevelPublisher: Published<Float>.Publisher { $currentBatteryLevel }
    
    init() {
        super.init(uuid: Self.uuid, characteristics: Self.characteristics)
    }
}
