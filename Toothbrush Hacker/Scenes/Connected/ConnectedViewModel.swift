//
//  ConnectedViewModel.swift
//  Toothbrush Hacker
//
//  Created by Jason Vance on 8/27/23.
//

import Foundation
import Combine

@MainActor
class ConnectedViewModel: ObservableObject {
    
    @Published var currentBatteryLevel: Double? = nil
    @Published var isListening01: Bool = false
    @Published var isListening02: Bool = false

    @Published var manufacturerName: String? = nil
    @Published var modelNumber: String? = nil
    @Published var serialNumber: String? = nil
    @Published var hardwareRevision: String? = nil
    @Published var firmwareRevision: String? = nil
    @Published var softwareRevision: String? = nil
    @Published var systemId: Int? = nil
    @Published var ieeeCertification: Int? = nil
    @Published var pnpId: Int? = nil

    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    
    let toothbrushConnection: BlePeripheralConnection
    let batteryMonitor01: BatteryMonitor
    let batteryMonitor02: BatteryMonitor
    let deviceBasicInfoReader: DeviceBasicInfoReader
    let deviceVersionInfoReader: DeviceVersionInfoReader
    let deviceExtendedInfoReader: DeviceExtendedInfoReader
//    let toothbrushPropertyReader: ToothbrushPropertyReader

    var subs: Set<AnyCancellable> = []

    init(toothbrushConnection: BlePeripheralConnection) {
        self.toothbrushConnection = toothbrushConnection
        batteryMonitor01 = BlePeripheralBatteryMonitor(device: toothbrushConnection.peripheral)
        batteryMonitor02 = BlePeripheralBatteryMonitor(device: toothbrushConnection.peripheral)
        deviceBasicInfoReader = BlePeripheralDeviceInfoReader(device: toothbrushConnection.peripheral)
        deviceVersionInfoReader = BlePeripheralDeviceInfoReader(device: toothbrushConnection.peripheral)
        deviceExtendedInfoReader = BlePeripheralDeviceInfoReader(device: toothbrushConnection.peripheral)

        setupSubscribers()
    }
    
    private func setupSubscribers() {
        monitorBatteryLevel()
        subscribeToDeviceInfo()
    }
    
    private func monitorBatteryLevel() {
        batteryMonitor01.batteryLevelPublisher
            .receive(on: RunLoop.main)
            .sink { self.currentBatteryLevel = $0 }
            .store(in: &subs)
        batteryMonitor02.batteryLevelPublisher
            .receive(on: RunLoop.main)
            .sink { self.currentBatteryLevel = $0 }
            .store(in: &subs)
        batteryMonitor01.isListeningPublisher
            .receive(on: RunLoop.main)
            .sink { self.isListening01 = $0 }
            .store(in: &subs)
        batteryMonitor02.isListeningPublisher
            .receive(on: RunLoop.main)
            .sink { self.isListening02 = $0 }
            .store(in: &subs)
    }
    
    private func subscribeToDeviceInfo() {
        deviceBasicInfoReader.manufacturerNamePublisher
            .receive(on: RunLoop.main)
            .sink { self.manufacturerName = $0 }
            .store(in: &subs)
        deviceBasicInfoReader.modelNumberPublisher
            .receive(on: RunLoop.main)
            .sink { self.modelNumber = $0 }
            .store(in: &subs)
        deviceBasicInfoReader.serialNumberPublisher
            .receive(on: RunLoop.main)
            .sink { self.serialNumber = $0 }
            .store(in: &subs)
        deviceVersionInfoReader.hardwareRevisionPublisher
            .receive(on: RunLoop.main)
            .sink { self.hardwareRevision = $0 }
            .store(in: &subs)
        deviceVersionInfoReader.firmwareRevisionPublisher
            .receive(on: RunLoop.main)
            .sink { self.firmwareRevision = $0 }
            .store(in: &subs)
        deviceVersionInfoReader.softwareRevisionPublisher
            .receive(on: RunLoop.main)
            .sink { self.softwareRevision = $0 }
            .store(in: &subs)
        deviceExtendedInfoReader.systemIdPublisher
            .receive(on: RunLoop.main)
            .sink { self.systemId = $0 }
            .store(in: &subs)
        deviceExtendedInfoReader.ieeeRegulatoryCertificationPublisher
            .receive(on: RunLoop.main)
            .sink { self.ieeeCertification = $0 }
            .store(in: &subs)
        deviceExtendedInfoReader.pnpIdPublisher
            .receive(on: RunLoop.main)
            .sink { self.pnpId = $0 }
            .store(in: &subs)
    }
    
    func fetchDeviceBasicInfo() {
        deviceBasicInfoReader.fetchBasicInfo()
    }
    
    func fetchDeviceVersionInfo() {
        deviceVersionInfoReader.fetchVersionInfo()
    }
    
    func fetchDeviceExtendedInfo() {
        deviceExtendedInfoReader.fetchExtendedInfo()
    }
    
    func fetchBatteryLevel01() {
        batteryMonitor01.listenToBatteryLevel()
    }
    
    func fetchBatteryLevel02() {
        batteryMonitor02.listenToBatteryLevel()
    }
    
    func disconnect() {
        Task {
            do {
                try await toothbrushConnection.cancelConnection()
            } catch {
                show(alertMessage: "Error while disconnecting")
            }
        }
    }
    
    func show(alertMessage: String) {
        showAlert = true
        self.alertMessage = alertMessage
    }
}
