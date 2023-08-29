//
//  BatteryLevelCharacteristic.swift
//  Toothbrush Hacker
//
//  Created by Jason Vance on 8/27/23.
//

import Foundation
import CoreBluetooth

class BatteryLevelCharacteristic: BleCharacteristic {
    
    static let uuid = CBUUID(string: "2A19")
    
    init() {
        super.init(uuid: Self.uuid)
    }
}
