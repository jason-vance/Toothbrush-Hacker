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
    let unknownToothbrushService = UnknownToothbrushService()
    
    var subs: Set<AnyCancellable> = []
    
    init(device: CBPeripheral) {
        let communicator = BlePeripheralCommunicator.getOrCreate(from: device)
        communicator.add(bleServices: [unknownToothbrushService])
        deviceCommunicator = communicator
    }
}
