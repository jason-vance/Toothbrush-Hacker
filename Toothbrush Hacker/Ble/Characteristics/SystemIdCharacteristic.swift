//
//  SystemIdCharacteristic.swift
//  Toothbrush Hacker
//
//  Created by Jason Vance on 8/30/23.
//

import Foundation
import CoreBluetooth

class SystemIdCharacteristic: BleCharacteristic<Int> {
    
    static let uuid = CBUUID(string: "2A23")
    
    init() {
        super.init(uuid: Self.uuid, readValueOnDiscover: true)
    }
}
