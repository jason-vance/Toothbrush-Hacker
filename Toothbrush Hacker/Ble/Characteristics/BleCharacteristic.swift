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
    let readValueOnDiscover: Bool
    let setToNotify: Bool
    
    @Published var valueBytes: [UInt8]? = nil
    
    init(uuid: CBUUID, readValueOnDiscover: Bool = false, setToNotify: Bool = false) {
        self.uuid = uuid
        self.readValueOnDiscover = readValueOnDiscover
        self.setToNotify = setToNotify
    }
    
    func communicator(_ communicator: BleDeviceCommunicator, discovered cbCharacteristic: CBCharacteristic) {
        guard self.characteristic == nil else {
            return
        }
        self.characteristic = cbCharacteristic
        communicator.discoverDescriptors(for: self)
        if readValueOnDiscover {
            communicator.readValue(for: self)
        }
        if setToNotify {
            communicator.startNotifications(for: self)
        }
    }
    
    func communicator(_ communicator: BleDeviceCommunicator, discovered cbDescriptor: CBDescriptor, for cbCharacteristic: CBCharacteristic) {
        guard let descriptor = BleDescriptor.create(with: cbDescriptor) else { return }
        
        descriptors[descriptor.uuid] = descriptor
        communicator.readValue(for: descriptor)
    }
    
    func communicator(_ communicator: BleDeviceCommunicator, receivedValueUpdateFor cbCharacteristic: CBCharacteristic) {
        guard let data = cbCharacteristic.value else { return }
        valueBytes = [UInt8](data)
        //TODO: Format this value using the format descriptor (maybe just the exponent
        // self.formattedValue = formattedValue
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


