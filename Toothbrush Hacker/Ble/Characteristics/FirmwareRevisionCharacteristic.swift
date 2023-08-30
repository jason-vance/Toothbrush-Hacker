//
//  FirmwareRevisionCharacteristic.swift
//  Toothbrush Hacker
//
//  Created by Jason Vance on 8/30/23.
//

import Foundation
import CoreBluetooth

class FirmwareRevisionCharacteristic: BleCharacteristic<String> {
    
    static let uuid = CBUUID(string: "2A26")
    
    init() {
        super.init(uuid: Self.uuid, readValueOnDiscover: true)
    }
}
