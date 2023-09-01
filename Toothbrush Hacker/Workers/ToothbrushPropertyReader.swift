//
//  ToothbrushPropertyReader.swift
//  Toothbrush Hacker
//
//  Created by Jason Vance on 8/30/23.
//

import Foundation
import CoreBluetooth
import Combine

class ToothbrushPropertyReader {

    let deviceCommunicator: BlePeripheralCommunicator
    let unknownToothbrushService0001 = UnknownToothbrushService(uuid: UnknownToothbrushService.uuid0001)
    let unknownToothbrushService0002 = UnknownToothbrushService(uuid: UnknownToothbrushService.uuid0002)
    let unknownToothbrushService0003 = UnknownToothbrushService(uuid: UnknownToothbrushService.uuid0003)

    var subs: Set<AnyCancellable> = []
    
    init(device: CBPeripheral) {
        let communicator = BlePeripheralCommunicator.getOrCreate(from: device)
        communicator.add(bleServices: [
            unknownToothbrushService0001,
            unknownToothbrushService0002,
            unknownToothbrushService0003
        ])
        deviceCommunicator = communicator
    }
}
