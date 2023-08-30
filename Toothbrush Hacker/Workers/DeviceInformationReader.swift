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
    var modelNumberPublisher: Published<String?>.Publisher { get }
}

class BleDeviceInformationReader: DeviceInformationReader {
    
    var manufacturerNamePublisher: Published<String?>.Publisher { deviceInfoService.manufacturerNamePublisher }
    var modelNumberPublisher: Published<String?>.Publisher { deviceInfoService.modelNumberPublisher }
    
    let deviceCommunicator: BleDeviceCommunicator
    let deviceInfoService = DeviceInformationService()
    
    var subs: Set<AnyCancellable> = []
    
    init(device: CBPeripheral) {
        let communicator = BleDeviceCommunicator.getOrCreate(from: device)
        communicator.add(services: [deviceInfoService])
        deviceCommunicator = communicator
    }
}
