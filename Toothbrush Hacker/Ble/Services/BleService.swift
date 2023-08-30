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
    let characteristics: [CBUUID:BleCharacteristic]
    private(set) var service: CBService? = nil
    
    init(uuid: CBUUID, characteristics: [CBUUID:BleCharacteristic]) {
        self.uuid = uuid
        self.characteristics = characteristics
    }
    
    func communicator(_ communicator: BleDeviceCommunicator, discovered cbService: CBService) {
        guard self.service == nil else {
            return
        }
        self.service = cbService
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
