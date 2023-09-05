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

    let deviceCommunicator: BlePeripheralCommunicator_Published
    let unknownToothbrushService0001: UnknownToothbrushService
    let unknownToothbrushService0002: UnknownToothbrushService
    let unknownToothbrushService0003: UnknownToothbrushService

    var subs: Set<AnyCancellable> = []
    
    init(device: CBPeripheral) {
        deviceCommunicator = BlePeripheralCommunicator_Published.getOrCreate(from: device)
        unknownToothbrushService0001 = UnknownToothbrushService(
            uuid: UnknownToothbrushService.uuid0001,
            communicator: deviceCommunicator)
        unknownToothbrushService0002 = UnknownToothbrushService(
            uuid: UnknownToothbrushService.uuid0002,
            communicator: deviceCommunicator)
        unknownToothbrushService0003 = UnknownToothbrushService(
            uuid: UnknownToothbrushService.uuid0003,
            communicator: deviceCommunicator)

        Task {
            await deviceCommunicator.register(bleServices: [
                unknownToothbrushService0001,
                unknownToothbrushService0002,
                unknownToothbrushService0003
            ])
        }
    }
}
