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
    
    init(communicator: BlePeripheralCommunicator_Published) {
        super.init(
            uuid: Self.uuid,
            communicator: communicator,
            readValueOnDiscover: true
        )
    }
}
