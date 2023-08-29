//
//  BleCharacteristic.swift
//  Toothbrush Hacker
//
//  Created by Jason Vance on 8/29/23.
//

import Foundation
import CoreBluetooth

class BleCharacteristic {
    
    let uuid: CBUUID
    //TODO: I should probably make this a map instead of a set
    private(set) var descriptors: Set<BleDescriptor> = []
    private(set) var characteristic: CBCharacteristic? = nil
    
    init(uuid: CBUUID) {
        self.uuid = uuid
    }
    
    func communicator(_ communicator: BleDeviceCommunicator, discovered characteristic: CBCharacteristic) {
        guard self.characteristic == nil else {
            fatalError("My characteristic was already discoverd")
        }
        self.characteristic = characteristic
        print("BleCharacteristic discovered characteristic: \(characteristic)")
//        communicator.discoverDescriptors(for: self)
    }
    
//    func communicator(_ communicator: BleDeviceCommunicator, discovered descriptor: BleDescriptor, for characteristic: CBCharacteristic) {
//        guard self.service == nil else {
//            fatalError("My service was already discoverd")
//        }
//        self.service = service
//        print("BleService discovered service: \(service)")
//        communicator.discoverCharacteristics(for: self)
//    }
}

extension BleCharacteristic: Equatable {
    static func == (lhs: BleCharacteristic, rhs: BleCharacteristic) -> Bool {
        lhs.uuid == rhs.uuid
    }
}

extension BleCharacteristic: Hashable {
    var hashValue: Int { uuid.hashValue }
    
    func hash(into hasher: inout Hasher) {
        uuid.hash(into: &hasher)
    }
}


