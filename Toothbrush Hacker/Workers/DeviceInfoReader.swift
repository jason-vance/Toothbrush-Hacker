//
//  DeviceInfoReader.swift
//  Toothbrush Hacker
//
//  Created by Jason Vance on 8/29/23.
//

import Foundation
import Combine
import CoreBluetooth

protocol DeviceBasicInfoReader {
    var manufacturerNamePublisher: Published<String?>.Publisher { get }
    var modelNumberPublisher: Published<String?>.Publisher { get }
    var serialNumberPublisher: Published<String?>.Publisher { get }
}

protocol DeviceVersionInfoReader {
    var hardwareRevisionPublisher: Published<String?>.Publisher { get }
    var firmwareRevisionPublisher: Published<String?>.Publisher { get }
    var softwareRevisionPublisher: Published<String?>.Publisher { get }
}

protocol DeviceExtendedInfoReader {
    var systemIdPublisher: Published<Int?>.Publisher { get }
    var ieeeRegulatoryCertificationPublisher: Published<Int?>.Publisher { get }
    var pnpIdPublisher: Published<Int?>.Publisher { get }
}

class BlePeripheralDeviceInfoReader: DeviceBasicInfoReader, DeviceVersionInfoReader, DeviceExtendedInfoReader {
    
    var manufacturerNamePublisher: Published<String?>.Publisher { deviceInfoService.manufacturerNamePublisher }
    var modelNumberPublisher: Published<String?>.Publisher { deviceInfoService.modelNumberPublisher }
    var serialNumberPublisher: Published<String?>.Publisher { deviceInfoService.serialNumberPublisher }
    var hardwareRevisionPublisher: Published<String?>.Publisher { deviceInfoService.hardwareRevisionPublisher }
    var firmwareRevisionPublisher: Published<String?>.Publisher { deviceInfoService.firmwareRevisionPublisher }
    var softwareRevisionPublisher: Published<String?>.Publisher { deviceInfoService.softwareRevisionPublisher }
    var systemIdPublisher: Published<Int?>.Publisher { deviceInfoService.systemIdPublisher }
    var ieeeRegulatoryCertificationPublisher: Published<Int?>.Publisher { deviceInfoService.ieeeRegulatoryCertificationPublisher }
    var pnpIdPublisher: Published<Int?>.Publisher { deviceInfoService.pnpIdPublisher }

    let deviceCommunicator: BlePeripheralCommunicator
    let deviceInfoService = DeviceInformationService()
    
    var subs: Set<AnyCancellable> = []
    
    init(device: CBPeripheral) {
        let communicator = BlePeripheralCommunicator.getOrCreate(from: device)
        communicator.add(bleServices: [deviceInfoService])
        deviceCommunicator = communicator
    }
}
