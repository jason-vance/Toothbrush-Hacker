//
//  SerialNumberCharacteristic.swift
//  Toothbrush Hacker
//
//  Created by Jason Vance on 8/29/23.
//

import Foundation
import CoreBluetooth

class SerialNumberCharacteristic: BleCharacteristic<String> {
    
    static let uuid = CBUUID(string: "2A25")
    
    init() {
        super.init(uuid: Self.uuid, readValueOnDiscover: true)
    }
}
