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

    let deviceCommunicator: BleDeviceCommunicator
    let unknownToothbrushService = UnknownToothbrushService()
    
    var subs: Set<AnyCancellable> = []
    
    init(device: CBPeripheral) {
        let communicator = BleDeviceCommunicator.getOrCreate(from: device)
        communicator.add(services: [unknownToothbrushService])
        deviceCommunicator = communicator
    }
}
