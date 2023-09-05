//
//  ModelNumberCharacteristic.swift
//  Toothbrush Hacker
//
//  Created by Jason Vance on 8/29/23.
//

import Foundation
import CoreBluetooth
import Combine

class ModelNumberCharacteristic: BleCharacteristic<String> {
    
    static let uuid = CBUUID(string: "2A24")
    
    init(communicator: BlePeripheralCommunicator_Published) {
        super.init(
            uuid: Self.uuid,
            communicator: communicator,
            readValueOnDiscover: true
        )
    }
}
