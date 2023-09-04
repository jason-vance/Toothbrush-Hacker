//
//  BleService.swift
//  Toothbrush Hacker
//
//  Created by Jason Vance on 8/29/23.
//

import Foundation
import CoreBluetooth
import Combine

class BleService {
    
    let uuid: CBUUID
    let bleCharacteristics: [CBUUID:BleCharacteristicProtocol]
    unowned let communicator: BlePeripheralCommunicator
    private(set) weak var cbService: CBService? = nil
    
    private var subs: Set<AnyCancellable> = []
    
    init(uuid: CBUUID, bleCharacteristics: [BleCharacteristicProtocol], communicator: BlePeripheralCommunicator) {
        var bleCharacteristicsDict: [CBUUID:BleCharacteristicProtocol] = [:]
        bleCharacteristics.forEach {
            bleCharacteristicsDict[$0.uuid] = $0
        }

        self.uuid = uuid
        self.bleCharacteristics = bleCharacteristicsDict
        self.communicator = communicator
        
        bleCharacteristics.forEach {
            $0.onAddedTo(bleService: self)
        }
        subscribeToServicePublishers()
    }
    
    func subscribeToServicePublishers() {
        Task {
            await communicator.$discoveredService
                .filter(isMy(service:))
                .sink(receiveValue: discovered(service:))
                .store(in: &self.subs)
        }
    }
     
    private func isMy(service: (CBService?, Error?)) -> Bool {
        return service.0?.uuid == uuid
    }
        
    private func discovered(service: (CBService?, Error?)) {
        guard cbService == nil else { return }
        cbService = service.0
        Task {
            await communicator.discoverCharacteristics(for: self)
        }
    }
    
    func communicator(_ communicator: BlePeripheralCommunicator, discovered cbService: CBService) {
        discovered(service: (cbService, nil))
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
