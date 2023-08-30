//
//  HardwareRevisionCharacteristic.swift
//  Toothbrush Hacker
//
//  Created by Jason Vance on 8/30/23.
//

import Foundation
import CoreBluetooth

class HardwareRevisionCharacteristic: BleCharacteristic<String> {
    
    static let uuid = CBUUID(string: "2A27")
    
    init() {
        super.init(uuid: Self.uuid, readValueOnDiscover: true)
    }
}
