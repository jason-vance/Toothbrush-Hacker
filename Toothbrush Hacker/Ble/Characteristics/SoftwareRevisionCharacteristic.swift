//
//  SoftwareRevisionCharacteristic.swift
//  Toothbrush Hacker
//
//  Created by Jason Vance on 8/30/23.
//

import Foundation
import CoreBluetooth

class SoftwareRevisionCharacteristic: BleCharacteristic<String> {
    
    static let uuid = CBUUID(string: "2A28")
    
    init() {
        super.init(uuid: Self.uuid, readValueOnDiscover: true)
    }
}
