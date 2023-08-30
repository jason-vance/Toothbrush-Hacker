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
    private(set) var descriptors: [CBUUID:BleDescriptor] = [:]
    private(set) var characteristic: CBCharacteristic? = nil
    
    @Published var valueBytes: [UInt8]? = nil
    
    init(uuid: CBUUID) {
        self.uuid = uuid
    }
    
    func communicator(_ communicator: BleDeviceCommunicator, discovered cbCharacteristic: CBCharacteristic) {
        guard self.characteristic == nil else {
            print("My characteristic was already discoverd")
            return
        }
        self.characteristic = cbCharacteristic
        print("BleCharacteristic discovered characteristic: \(cbCharacteristic)")
        communicator.discoverDescriptors(for: self)
        communicator.readValue(for: self)
    }
    
    func communicator(_ communicator: BleDeviceCommunicator, discovered cbDescriptor: CBDescriptor, for cbCharacteristic: CBCharacteristic) {
        guard let descriptor = BleDescriptor.create(with: cbDescriptor) else { return }
        print("BleCharacteristic discovered descriptor: \(cbDescriptor)")
        
        descriptors[descriptor.uuid] = descriptor
        communicator.readValue(for: descriptor)
    }
    
    func communicator(_ communicator: BleDeviceCommunicator, receivedValueUpdateFor cbCharacteristic: CBCharacteristic) {
        guard let data = cbCharacteristic.value else { return }
        valueBytes = [UInt8](data)
        //TODO: Format this value using the format descriptor (maybe just the exponent
        // self.formattedValue = formattedValue
        print("BleCharacteristic.receivedValueUpdateFor \(cbCharacteristic) value: \(valueBytes!)")
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


