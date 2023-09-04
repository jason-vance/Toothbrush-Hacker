//
//  BlePeripheralCommunicator.swift
//  Toothbrush Hacker
//
//  Created by Jason Vance on 8/28/23.
//

import Foundation
import CoreBluetooth

//TODO: Try removing all of the non sub-pub calls to BleService/Characteristic/Descriptor.discovered(blah, blah)
//TODO: See if I can just rely on the published values
actor BlePeripheralCommunicator: NSObject {
    
    private static var communicators: [CBPeripheral:BlePeripheralCommunicator] = [:]
    
    static func getOrCreate(from peripheral: CBPeripheral) -> BlePeripheralCommunicator {
        if !communicators.keys.contains(peripheral) {
            let communicator = BlePeripheralCommunicator(
                connection: BlePeripheralConnection.getOrCreate(from: peripheral)
            )
            communicators[peripheral] = communicator
        }
        
        return communicators[peripheral]!
    }
    
    @Published private(set) var discoveredService: (CBService?, Error?) = (nil, nil)
    @Published private(set) var discoveredCharacteristic: (CBCharacteristic?, Error?) = (nil, nil)
    @Published private(set) var discoveredDescriptor: (CBDescriptor?, Error?) = (nil, nil)
    
    @Published private(set) var updatedValueCharacteristic: (CBCharacteristic?, Error?) = (nil, nil)
    @Published private(set) var updatedValueDescriptor: (CBDescriptor?, Error?) = (nil, nil)

    private let connection: BlePeripheralConnection
    private var peripheral: CBPeripheral {
        connection.peripheral.delegate = self
        return connection.peripheral
    }
    private var peripheralsServiceDict: [CBUUID:CBService] {
        var dict: [CBUUID:CBService] = [:]
        peripheral.services?.forEach { service in
            dict[service.uuid] = service
        }
        return dict
    }
    
    private var serviceUuidsPendingDiscovery: Set<CBUUID> = []
    private var characteristicUuidsPendingDiscovery: [CBUUID:Set<CBUUID>] = [:]

    private init(connection: BlePeripheralConnection) {
        self.connection = connection
        super.init()
    }
    
    func register(bleServices: [BleService]) {
        notify(bleServices, ofAlreadyDiscoveredServices: peripheralsServiceDict)
        discoverNewCbServices(from: bleServices)
    }
    
    private func notify(
        _ bleServices: [BleService],
        ofAlreadyDiscoveredServices alreadyDiscoveredServices: [CBUUID:CBService])
    {
        bleServices.forEach {
            guard let cbService = alreadyDiscoveredServices[$0.uuid] else { return }
            $0.communicator(self, discovered: cbService)
        }
    }
    
    private func discoverNewCbServices(from bleServices: [BleService]) {
        let newServices = bleServices.filter { !serviceUuidsPendingDiscovery.contains($0.uuid) }
        guard !newServices.isEmpty else { return }
        
        add(newServices, to: &serviceUuidsPendingDiscovery)
        peripheral.discoverServices(newServices.map { $0.uuid })
    }
    
    private func add(_ bleServices: [BleService], to serviceUuidSet: inout Set<CBUUID>) {
        serviceUuidSet.formUnion(bleServices.map { $0.uuid })
    }
    
    func discoverCharacteristics(for bleService: BleService) {
        notify(bleService, ofAlreadyDiscoveredCharacteristics: peripheralsServiceDict)
        
        let newCharacteristics = bleService.bleCharacteristics.values
            .map { $0 as BleCharacteristicProtocol }
            .filter { !(characteristicUuidsPendingDiscovery[bleService.uuid] ?? []).contains($0.uuid) }
        guard !newCharacteristics.isEmpty else { return }
        
        guard let cbService = peripheralsServiceDict[bleService.uuid] else { return }
        add(newCharacteristics, to: &characteristicUuidsPendingDiscovery)
        peripheral.discoverCharacteristics(newCharacteristics.map { $0.uuid }, for: cbService)
    }
    
    private func notify(
        _ bleService: BleService,
        ofAlreadyDiscoveredCharacteristics alreadyDiscoveredServices: [CBUUID:CBService])
    {
        bleService.bleCharacteristics.values
            .map { $0 as BleCharacteristicProtocol }
            .forEach { bleChars in
                guard let cbChars = alreadyDiscoveredServices[bleService.uuid]?.characteristics else { return }
                guard let cbChar = (cbChars.first { $0.uuid == bleChars.uuid }) else { return }
                bleChars.communicator(self, discovered: cbChar, for: bleService)
            }
    }
    
    private func add(_ bleCharacteristics: [BleCharacteristicProtocol], to characteristicUuidSets: inout [CBUUID:Set<CBUUID>]) {
        bleCharacteristics.forEach { bleCharacteristic in
            guard let serviceUuid = bleCharacteristic.bleService?.uuid else { return }
            if !characteristicUuidSets.keys.contains(serviceUuid) {
                characteristicUuidSets[serviceUuid] = []
            }
            characteristicUuidSets[serviceUuid]?.insert(bleCharacteristic.uuid)
        }
    }
    
    func discoverDescriptors(for bleCharacteristic: BleCharacteristicProtocol) {
        //TODO: Notify of previously discovered descriptors
        guard let cbCharacteristic = bleCharacteristic.cbCharacteristic else { return }
        peripheral.discoverDescriptors(for: cbCharacteristic)
    }
    
    func readValue(for bleDescriptor: BleDescriptor) {
        peripheral.readValue(for: bleDescriptor.cbDescriptor)
    }
    
    func readValue(for bleCharacteristic: BleCharacteristicProtocol) {
        guard bleCharacteristic.canRead else {
            print("Attempted to readValue(for: \(bleCharacteristic.uuid)), but it's properties do not include .read")
            return
        }
        guard let cbCharacteristic = bleCharacteristic.cbCharacteristic else { return }
        peripheral.readValue(for: cbCharacteristic)
    }
    
    func startNotifications(for bleCharacteristic: BleCharacteristicProtocol) {
        guard bleCharacteristic.canNotify || bleCharacteristic.canIndicate else {
            print("Attempted to setNotifyValue(true, for: \(bleCharacteristic.uuid)), but it's properties do not include .notify")
            return
        }
        guard let cbCharacteristic = bleCharacteristic.cbCharacteristic else { return }
        peripheral.setNotifyValue(true, for: cbCharacteristic)
    }
    
    private func didDiscoverServices(_ error: Error?) {
        peripheral.services?.forEach {
            discoveredService = ($0, error)
        }
    }
    
    private func didDiscoverCharacteristicsFor(_ cbService: CBService, error: Error?) {
        cbService.characteristics?.forEach {
            discoveredCharacteristic = ($0, error)
        }
    }
    
    private func didDiscoverDescriptorsFor(_ cbCharacteristic: CBCharacteristic, error: Error?) {
        cbCharacteristic.descriptors?.forEach {
            discoveredDescriptor = ($0, error)
        }
    }
    
    private func didUpdateValueFor(_ cbCharacteristic: CBCharacteristic, error: Error?) {
        updatedValueCharacteristic = (cbCharacteristic, error)
    }
    
    private func didUpdateValueFor(_ cbDescriptor: CBDescriptor, error: Error?) {
        updatedValueDescriptor = (cbDescriptor, error)
    }
}

extension BlePeripheralCommunicator: CBPeripheralDelegate {
    
    nonisolated func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        Task {
            await didDiscoverServices(error)
        }
    }
    
    nonisolated func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor cbService: CBService, error: Error?) {
        Task {
            await didDiscoverCharacteristicsFor(cbService, error: error)
        }
    }
    
    nonisolated func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor cbCharacteristic: CBCharacteristic, error: Error?) {
        Task {
            await didDiscoverDescriptorsFor(cbCharacteristic, error: error)
        }
    }
    
    nonisolated func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor cbCharacteristic: CBCharacteristic, error: Error?) {
        Task {
            await didUpdateValueFor(cbCharacteristic, error: error)
        }
    }
    
    nonisolated func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor cbDescriptor: CBDescriptor, error: Error?) {
        Task {
            await didUpdateValueFor(cbDescriptor, error: error)
        }
    }
}
