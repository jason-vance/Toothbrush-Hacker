//
//  DeviceInformationService.swift
//  Toothbrush Hacker
//
//  Created by Jason Vance on 8/29/23.
//

import Foundation
import CoreBluetooth

class DeviceInformationService: BleService {
    
    static let uuid = CBUUID(string: "180A")
    
    var manufacturerNamePublisher: Published<String?>.Publisher { manufacturerNameCharacteristic.$value }
    var modelNumberPublisher: Published<String?>.Publisher { modelNumberCharacteristic.$value }
    var serialNumberPublisher: Published<String?>.Publisher { serialNumberCharacteristic.$value }
    var hardwareRevisionPublisher: Published<String?>.Publisher { hardwareRevisionCharacteristic.$value }
    var firmwareRevisionPublisher: Published<String?>.Publisher { firmwareRevisionCharacteristic.$value }
    var softwareRevisionPublisher: Published<String?>.Publisher { softwareRevisionCharacteristic.$value }
    var systemIdPublisher: Published<Int?>.Publisher { systemIdCharacteristic.$value }
    var ieeeRegulatoryCertificationPublisher: Published<Int?>.Publisher { ieeeRegulatoryCertificationCharacteristic.$value }
    var pnpIdPublisher: Published<Int?>.Publisher { pnpIdCharacteristic.$value }

    private let manufacturerNameCharacteristic: ManufacturerNameCharacteristic
    private let modelNumberCharacteristic: ModelNumberCharacteristic
    private let serialNumberCharacteristic: SerialNumberCharacteristic
    private let hardwareRevisionCharacteristic: HardwareRevisionCharacteristic
    private let firmwareRevisionCharacteristic: FirmwareRevisionCharacteristic
    private let softwareRevisionCharacteristic: SoftwareRevisionCharacteristic
    private let systemIdCharacteristic: SystemIdCharacteristic
    private let ieeeRegulatoryCertificationCharacteristic: IeeeRegulatoryCertificationCharacteristic
    private let pnpIdCharacteristic: PnpIdCharacteristic

    init(communicator: BlePeripheralCommunicator_Published) {
        manufacturerNameCharacteristic = ManufacturerNameCharacteristic(communicator: communicator)
        modelNumberCharacteristic = ModelNumberCharacteristic(communicator: communicator)
        serialNumberCharacteristic = SerialNumberCharacteristic(communicator: communicator)
        hardwareRevisionCharacteristic = HardwareRevisionCharacteristic(communicator: communicator)
        firmwareRevisionCharacteristic = FirmwareRevisionCharacteristic(communicator: communicator)
        softwareRevisionCharacteristic = SoftwareRevisionCharacteristic(communicator: communicator)
        systemIdCharacteristic = SystemIdCharacteristic(communicator: communicator)
        ieeeRegulatoryCertificationCharacteristic = IeeeRegulatoryCertificationCharacteristic(communicator: communicator)
        pnpIdCharacteristic = PnpIdCharacteristic(communicator: communicator)
        
        super.init(
            uuid: Self.uuid,
            bleCharacteristics: [
                manufacturerNameCharacteristic,
                modelNumberCharacteristic,
                serialNumberCharacteristic,
                hardwareRevisionCharacteristic,
                firmwareRevisionCharacteristic,
                softwareRevisionCharacteristic,
                systemIdCharacteristic,
                ieeeRegulatoryCertificationCharacteristic,
                pnpIdCharacteristic,
            ],
            communicator: communicator
        )
    }
}
