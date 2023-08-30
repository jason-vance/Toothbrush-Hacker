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
    var systemIdPublisher: Published<String?>.Publisher { systemIdCharacteristic.$value }
    var ieeeRegulatoryCertificationPublisher: Published<String?>.Publisher { ieeeRegulatoryCertificationCharacteristic.$value }
    var pnpIdPublisher: Published<String?>.Publisher { pnpIdCharacteristic.$value }

    private let manufacturerNameCharacteristic: ManufacturerNameCharacteristic
    private let modelNumberCharacteristic: ModelNumberCharacteristic
    private let serialNumberCharacteristic: SerialNumberCharacteristic
    private let hardwareRevisionCharacteristic: HardwareRevisionCharacteristic
    private let firmwareRevisionCharacteristic: FirmwareRevisionCharacteristic
    private let softwareRevisionCharacteristic: SoftwareRevisionCharacteristic
    private let systemIdCharacteristic: SystemIdCharacteristic
    private let ieeeRegulatoryCertificationCharacteristic: IeeeRegulatoryCertificationCharacteristic
    private let pnpIdCharacteristic: PnpIdCharacteristic

    init() {
        manufacturerNameCharacteristic = ManufacturerNameCharacteristic()
        modelNumberCharacteristic = ModelNumberCharacteristic()
        serialNumberCharacteristic = SerialNumberCharacteristic()
        hardwareRevisionCharacteristic = HardwareRevisionCharacteristic()
        firmwareRevisionCharacteristic = FirmwareRevisionCharacteristic()
        softwareRevisionCharacteristic = SoftwareRevisionCharacteristic()
        systemIdCharacteristic = SystemIdCharacteristic()
        ieeeRegulatoryCertificationCharacteristic = IeeeRegulatoryCertificationCharacteristic()
        pnpIdCharacteristic = PnpIdCharacteristic()

        super.init(
            uuid: Self.uuid,
            characteristics: [
                manufacturerNameCharacteristic.uuid: manufacturerNameCharacteristic,
                modelNumberCharacteristic.uuid: modelNumberCharacteristic,
                serialNumberCharacteristic.uuid: serialNumberCharacteristic,
                hardwareRevisionCharacteristic.uuid: hardwareRevisionCharacteristic,
                firmwareRevisionCharacteristic.uuid: firmwareRevisionCharacteristic,
                softwareRevisionCharacteristic.uuid: softwareRevisionCharacteristic,
                systemIdCharacteristic.uuid: systemIdCharacteristic,
                ieeeRegulatoryCertificationCharacteristic.uuid: ieeeRegulatoryCertificationCharacteristic,
                pnpIdCharacteristic.uuid: pnpIdCharacteristic,
            ]
        )
    }
}
