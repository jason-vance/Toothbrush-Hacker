//
//  BatteryLevelCharacteristic.swift
//  Toothbrush Hacker
//
//  Created by Jason Vance on 8/27/23.
//

import Foundation
import CoreBluetooth

class BatteryLevelCharacteristic: BleCharacteristic<Int> {
    
    static let uuid = CBUUID(string: "2A19")
    
    init() {
        super.init(uuid: Self.uuid, readValueOnDiscover: true, setToNotify: true)
    }
}
