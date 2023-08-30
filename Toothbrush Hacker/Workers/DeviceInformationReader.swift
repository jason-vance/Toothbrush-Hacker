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
    var serialNumberPublisher: Published<String?>.Publisher { get }
    var hardwareRevisionPublisher: Published<String?>.Publisher { get }
    var firmwareRevisionPublisher: Published<String?>.Publisher { get }
    var softwareRevisionPublisher: Published<String?>.Publisher { get }
    var systemIdPublisher: Published<String?>.Publisher { get }
    var ieeeRegulatoryCertificationPublisher: Published<String?>.Publisher { get }
    var pnpIdPublisher: Published<String?>.Publisher { get }
}

class BleDeviceInformationReader: DeviceInformationReader {
    
    var manufacturerNamePublisher: Published<String?>.Publisher { deviceInfoService.manufacturerNamePublisher }
    var modelNumberPublisher: Published<String?>.Publisher { deviceInfoService.modelNumberPublisher }
    var serialNumberPublisher: Published<String?>.Publisher { deviceInfoService.serialNumberPublisher }
    var hardwareRevisionPublisher: Published<String?>.Publisher { deviceInfoService.hardwareRevisionPublisher }
    var firmwareRevisionPublisher: Published<String?>.Publisher { deviceInfoService.firmwareRevisionPublisher }
    var softwareRevisionPublisher: Published<String?>.Publisher { deviceInfoService.softwareRevisionPublisher }
    var systemIdPublisher: Published<String?>.Publisher { deviceInfoService.systemIdPublisher }
    var ieeeRegulatoryCertificationPublisher: Published<String?>.Publisher { deviceInfoService.ieeeRegulatoryCertificationPublisher }
    var pnpIdPublisher: Published<String?>.Publisher { deviceInfoService.pnpIdPublisher }

    let deviceCommunicator: BleDeviceCommunicator
    let deviceInfoService = DeviceInformationService()
    
    var subs: Set<AnyCancellable> = []
    
    init(device: CBPeripheral) {
        let communicator = BleDeviceCommunicator.getOrCreate(from: device)
        communicator.add(services: [deviceInfoService])
        deviceCommunicator = communicator
    }
}
