//
//  BleDescriptor.swift
//  Toothbrush Hacker
//
//  Created by Jason Vance on 8/29/23.
//

import Foundation
import CoreBluetooth
import Combine

class BleDescriptor {
    
    var uuid: CBUUID { cbDescriptor.uuid }
    unowned let cbDescriptor: CBDescriptor
    unowned let bleCharacteristic: BleCharacteristicProtocol
    unowned let communicator: BlePeripheralCommunicator_Published

    @Published var valueBytes: [UInt8]? = nil
    
    private var subs: Set<AnyCancellable> = []
    
    static func create(
        with cbDescriptor: CBDescriptor,
        bleCharacteristic: BleCharacteristicProtocol,
        communicator: BlePeripheralCommunicator_Published
    ) -> BleDescriptor? {
        var bleDescriptor =
            CharacteristicFormatDescriptor(cbDescriptor: cbDescriptor, bleCharacteristic: bleCharacteristic, communicator: communicator) ??
            ClientCharacteristicConfigurationDescriptor(cbDescriptor: cbDescriptor, bleCharacteristic: bleCharacteristic, communicator: communicator) ??
            bleCharacteristic.createDescriptor(with: cbDescriptor, communicator: communicator) ??
            nil
            
        if bleDescriptor == nil {
            bleDescriptor = BleDescriptor(
                cbDescriptor: cbDescriptor,
                bleCharacteristic: bleCharacteristic,
                communicator: communicator
            )
            print("Unknown BleDescriptor with uuid: \(cbDescriptor.uuid) for: \(bleCharacteristic.uuid)")
        }
        return bleDescriptor
    }
    
    init?(
        cbDescriptor: CBDescriptor,
        bleCharacteristic: BleCharacteristicProtocol,
        communicator: BlePeripheralCommunicator_Published)
    {
        self.cbDescriptor = cbDescriptor
        self.bleCharacteristic = bleCharacteristic
        self.communicator = communicator
        
        subscribeToDescriptorPublishers()
    }
    
    private func subscribeToDescriptorPublishers() {
        Task {
            await communicator.$updatedValueDescriptor
                .filter(isMy(descriptor:))
                .sink(receiveValue: updateValue(descriptor:))
                .store(in: &self.subs)
        }
    }
    
    private func isMy(descriptor: (CBDescriptor?, Error?)) -> Bool {
        return descriptor.0?.uuid == uuid
    }
    
    private func updateValue(descriptor: (CBDescriptor?, Error?)) {
        guard let cbDescriptor = descriptor.0 else { return }
        guard let data = cbDescriptor.value as? Data else { return }
        valueBytes = [UInt8](data)
        printValueBytes()
    }
}

extension BleDescriptor: Equatable {
    static func == (lhs: BleDescriptor, rhs: BleDescriptor) -> Bool {
        lhs.uuid == rhs.uuid
    }
}

extension BleDescriptor: Hashable {
    var hashValue: Int { uuid.hashValue }
    
    func hash(into hasher: inout Hasher) {
        uuid.hash(into: &hasher)
    }
}

extension BleDescriptor {
    func printValueBytes() {
        guard let valueBytes = valueBytes else { return }
        print("BleDescriptor(\(uuid)).valueBytes: \(valueBytes.toString())")
    }
}
