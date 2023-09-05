//
//  ManufacturerNameCharacteristic.swift
//  Toothbrush Hacker
//
//  Created by Jason Vance on 8/29/23.
//

import Foundation
import CoreBluetooth

class ManufacturerNameCharacteristic: BleCharacteristic<String> {
    
    static let uuid = CBUUID(string: "2A29")
    
    init(communicator: BlePeripheralCommunicator_Published) {
        super.init(
            uuid: Self.uuid,
            communicator: communicator,
            readValueOnDiscover: true
        )
    }
}
