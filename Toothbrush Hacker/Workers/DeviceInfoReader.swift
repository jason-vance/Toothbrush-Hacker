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
    func fetchBasicInfo()
}

protocol DeviceVersionInfoReader {
    var hardwareRevisionPublisher: Published<String?>.Publisher { get }
    var firmwareRevisionPublisher: Published<String?>.Publisher { get }
    var softwareRevisionPublisher: Published<String?>.Publisher { get }
    func fetchVersionInfo()
}

protocol DeviceExtendedInfoReader {
    var systemIdPublisher: Published<Int?>.Publisher { get }
    var ieeeRegulatoryCertificationPublisher: Published<Int?>.Publisher { get }
    var pnpIdPublisher: Published<Int?>.Publisher { get }
    func fetchExtendedInfo()
}

class BlePeripheralDeviceInfoReader: DeviceBasicInfoReader, DeviceVersionInfoReader, DeviceExtendedInfoReader {
    
    var manufacturerNamePublisher: Published<String?>.Publisher { $manufacturerName }
    var modelNumberPublisher: Published<String?>.Publisher { $modelNumber }
    var serialNumberPublisher: Published<String?>.Publisher { $serialNumber }
    var hardwareRevisionPublisher: Published<String?>.Publisher { $hardwareRevision }
    var firmwareRevisionPublisher: Published<String?>.Publisher { $firmwareRevision }
    var softwareRevisionPublisher: Published<String?>.Publisher { $softwareRevision }
    var systemIdPublisher: Published<Int?>.Publisher { $systemId }
    var ieeeRegulatoryCertificationPublisher: Published<Int?>.Publisher { $ieeeRegulatoryCertification }
    var pnpIdPublisher: Published<Int?>.Publisher { $pnpId }
    
    @Published private(set) var manufacturerName: String? = nil
    @Published private(set) var modelNumber: String? = nil
    @Published private(set) var serialNumber: String? = nil
    @Published private(set) var hardwareRevision: String? = nil
    @Published private(set) var firmwareRevision: String? = nil
    @Published private(set) var softwareRevision: String? = nil
    @Published private(set) var systemId: Int? = nil
    @Published private(set) var ieeeRegulatoryCertification: Int? = nil
    @Published private(set) var pnpId: Int? = nil

    private let deviceCommunicator: BlePeripheralCommunicator
    
    private var subs: Set<AnyCancellable> = []
    
    init(device: CBPeripheral) {
        deviceCommunicator = BlePeripheralCommunicator.getOrCreate(from: device)
    }
    
    func fetchBasicInfo() {
        Task{
            do {
                manufacturerName = try await deviceCommunicator.readCharacteristicValue(
                    ManufacturerNameCharacteristic.uuid,
                    inService: DeviceInformationService.uuid,
                    as: String.self
                )
            } catch {
                print("Error reading manufacturer's name: \(error.localizedDescription)")
            }
            do {
                modelNumber = try await deviceCommunicator.readCharacteristicValue(
                    ModelNumberCharacteristic.uuid,
                    inService: DeviceInformationService.uuid,
                    as: String.self
                )
            } catch {
                print("Error reading model number: \(error.localizedDescription)")
            }
            do {
                serialNumber = try await deviceCommunicator.readCharacteristicValue(
                    SerialNumberCharacteristic.uuid,
                    inService: DeviceInformationService.uuid,
                    as: String.self
                )
            } catch {
                print("Error reading serial number: \(error.localizedDescription)")
            }
        }
    }
    
    func fetchVersionInfo() {
        Task{
            do {
                softwareRevision = try await deviceCommunicator.readCharacteristicValue(
                    SoftwareRevisionCharacteristic.uuid,
                    inService: DeviceInformationService.uuid,
                    as: String.self
                )
            } catch {
                print("Error reading software revision: \(error.localizedDescription)")
            }
            do {
                firmwareRevision = try await deviceCommunicator.readCharacteristicValue(
                    FirmwareRevisionCharacteristic.uuid,
                    inService: DeviceInformationService.uuid,
                    as: String.self
                )
            } catch {
                print("Error reading firmware revision: \(error.localizedDescription)")
            }
            do {
                hardwareRevision = try await deviceCommunicator.readCharacteristicValue(
                    HardwareRevisionCharacteristic.uuid,
                    inService: DeviceInformationService.uuid,
                    as: String.self
                )
            } catch {
                print("Error reading hardware revision: \(error.localizedDescription)")
            }
        }
    }
    
    func fetchExtendedInfo() {
        Task{
            do {
                systemId = try await deviceCommunicator.readCharacteristicValue(
                    SystemIdCharacteristic.uuid,
                    inService: DeviceInformationService.uuid,
                    as: Int.self
                )
            } catch {
                print("Error reading system id: \(error.localizedDescription)")
            }
            do {
                ieeeRegulatoryCertification = try await deviceCommunicator.readCharacteristicValue(
                    IeeeRegulatoryCertificationCharacteristic.uuid,
                    inService: DeviceInformationService.uuid,
                    as: Int.self
                )
            } catch {
                print("Error reading IEEE regulatory Certification: \(error.localizedDescription)")
            }
            do {
                pnpId = try await deviceCommunicator.readCharacteristicValue(
                    PnpIdCharacteristic.uuid,
                    inService: DeviceInformationService.uuid,
                    as: Int.self
                )
            } catch {
                print("Error reading pnp id: \(error.localizedDescription)")
            }
        }
    }
}
