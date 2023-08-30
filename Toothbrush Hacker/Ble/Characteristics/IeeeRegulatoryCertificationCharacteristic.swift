//
//  IeeeRegulatoryCertificationCharacteristic.swift
//  Toothbrush Hacker
//
//  Created by Jason Vance on 8/30/23.
//

import Foundation
import CoreBluetooth

class IeeeRegulatoryCertificationCharacteristic: BleCharacteristic<String> {
    
    static let uuid = CBUUID(string: "2A2A")
    
    init() {
        super.init(uuid: Self.uuid, readValueOnDiscover: true)
    }
}
