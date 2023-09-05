//
//  PnpIdCharacteristic.swift
//  Toothbrush Hacker
//
//  Created by Jason Vance on 8/30/23.
//

import Foundation
import CoreBluetooth

class PnpIdCharacteristic: BleCharacteristic<Int> {
    
    static let uuid = CBUUID(string: "2A50")
    
    init(communicator: BlePeripheralCommunicator_Published) {
        super.init(
            uuid: Self.uuid,
            communicator: communicator,
            readValueOnDiscover: true)
    }
}
