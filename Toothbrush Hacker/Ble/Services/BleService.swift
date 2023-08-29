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
    //TODO: I should probably make this a map instead of a set
    let characteristics: Set<BleCharacteristic>
    private(set) var service: CBService? = nil
    
    init(uuid: CBUUID, characteristics: Set<BleCharacteristic>) {
        self.uuid = uuid
        self.characteristics = characteristics
    }
    
    func communicator(_ communicator: BleDeviceCommunicator, discovered cbService: CBService) {
        guard self.service == nil else {
            fatalError("My service was already discoverd")
        }
        self.service = cbService
        print("BleService discovered service: \(cbService)")
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
