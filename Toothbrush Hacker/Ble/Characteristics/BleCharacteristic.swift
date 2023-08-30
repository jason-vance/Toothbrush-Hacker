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
    
    func communicator(_ communicator: BleDeviceCommunicator, discovered cbCharacteristic: CBCharacteristic) {
        guard self.characteristic == nil else {
            fatalError("My characteristic was already discoverd")
        }
        self.characteristic = cbCharacteristic
        print("BleCharacteristic discovered characteristic: \(cbCharacteristic)")
        communicator.discoverDescriptors(for: self)
    }
    
    func communicator(_ communicator: BleDeviceCommunicator, discovered cbDescriptor: CBDescriptor, for cbCharacteristic: CBCharacteristic) {
        guard let descriptor = BleDescriptor.create(with: cbDescriptor) else { return }
        print("BleCharacteristic discovered descriptor: \(cbDescriptor)")
        descriptors.insert(descriptor)
        communicator.readValue(for: descriptor)
    }
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


