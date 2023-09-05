//
//  BatteryService.swift
//  Toothbrush Hacker
//
//  Created by Jason Vance on 8/27/23.
//

import Foundation
import CoreBluetooth

class BatteryService: BleService {
    
    static let uuid = CBUUID(string: "180F")

    var batteryLevelPublisher: Published<Int?>.Publisher { batteryLevelCharacteristic.$value }
    
    private let batteryLevelCharacteristic: BatteryLevelCharacteristic
    
    init(communicator: BlePeripheralCommunicator_Published) {
        batteryLevelCharacteristic = BatteryLevelCharacteristic(communicator: communicator)
        super.init(
            uuid: Self.uuid,
            bleCharacteristics: [batteryLevelCharacteristic],
            communicator: communicator
        )
    }
}
