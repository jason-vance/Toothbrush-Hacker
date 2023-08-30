//
//  DeviceInformationReader.swift
//  Toothbrush Hacker
//
//  Created by Jason Vance on 8/29/23.
//

import Foundation
import Combine
import CoreBluetooth

protocol DeviceInformationReader {
    var manufacturerNamePublisher: Published<String?>.Publisher { get }
}

class BleDeviceInformationReader: DeviceInformationReader {
    
    @Published var manufacturerName: String? = nil
    var manufacturerNamePublisher: Published<String?>.Publisher { $manufacturerName }
    
    let deviceCommunicator: BleDeviceCommunicator
    let deviceInfoService = DeviceInformationService()
    
    var subs: Set<AnyCancellable> = []
    
    init(device: CBPeripheral) {
        let communicator = BleDeviceCommunicator.getOrCreate(from: device)
        communicator.add(services: [deviceInfoService])
        deviceCommunicator = communicator
        
        setupManufacturerNameSub()
    }
    
    private func setupManufacturerNameSub() {
        deviceInfoService.manufacturerNamePublisher
            .sink { self.manufacturerName = $0 }
            .store(in: &subs)
    }
}
