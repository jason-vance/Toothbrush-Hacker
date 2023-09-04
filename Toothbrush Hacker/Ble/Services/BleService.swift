//
//  BleService.swift
//  Toothbrush Hacker
//
//  Created by Jason Vance on 8/29/23.
//

import Foundation
import CoreBluetooth

class BleService {
    
    let uuid: CBUUID
    let bleCharacteristics: [CBUUID:BleCharacteristicProtocol]
    private(set) var cbService: CBService? = nil
    
    init(uuid: CBUUID, bleCharacteristicUuids: [BleCharacteristicProtocol]) {
        var bleCharacteristics: [CBUUID:BleCharacteristicProtocol] = [:]
        bleCharacteristicUuids.forEach {
            bleCharacteristics[$0.uuid] = $0
        }

        self.uuid = uuid
        self.bleCharacteristics = bleCharacteristics
    }
    
    func communicator(_ communicator: BlePeripheralCommunicator, discovered cbService: CBService) {
        guard self.cbService == nil else {
            return
        }
        self.cbService = cbService
        communicator.discoverCharacteristics(for: self)
    }
}

extension BleService: Equatable {
    static func == (lhs: BleService, rhs: BleService) -> Bool {
        lhs.uuid == rhs.uuid
    }
}

extension BleService: Hashable {
    var hashValue: Int { uuid.hashValue }
    
    func hash(into hasher: inout Hasher) {
        uuid.hash(into: &hasher)
    }
}
