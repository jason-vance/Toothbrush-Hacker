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
    let batteryMonitor: BatteryMonitor
    let deviceInfoReader: DeviceInfoReader
    let toothbrushPropertyReader: ToothbrushPropertyReader

    var subs: Set<AnyCancellable> = []

    init(
        toothbrushConnection: BlePeripheralConnection,
        batteryMonitor: BatteryMonitor,
        deviceInfoReader: DeviceInfoReader,
        toothbrushPropertyReader: ToothbrushPropertyReader
    ) {
        self.toothbrushConnection = toothbrushConnection
        self.batteryMonitor = batteryMonitor
        self.deviceInfoReader = deviceInfoReader
        self.toothbrushPropertyReader = toothbrushPropertyReader

        setupSubscribers()
    }
    
    private func setupSubscribers() {
        monitorBatteryLevel()
        subscribeToDeviceInfo()
    }
    
    private func monitorBatteryLevel() {
        batteryMonitor.batteryLevelPublisher
            .receive(on: RunLoop.main)
            .sink { self.currentBatteryLevel = $0 }
            .store(in: &subs)
    }
    
    private func subscribeToDeviceInfo() {
        deviceInfoReader.manufacturerNamePublisher
            .receive(on: RunLoop.main)
            .sink { self.manufacturerName = $0 }
            .store(in: &subs)
        deviceInfoReader.modelNumberPublisher
            .receive(on: RunLoop.main)
            .sink { self.modelNumber = $0 }
            .store(in: &subs)
        deviceInfoReader.serialNumberPublisher
            .receive(on: RunLoop.main)
            .sink { self.serialNumber = $0 }
            .store(in: &subs)
        deviceInfoReader.hardwareRevisionPublisher
            .receive(on: RunLoop.main)
            .sink { self.hardwareRevision = $0 }
            .store(in: &subs)
        deviceInfoReader.firmwareRevisionPublisher
            .receive(on: RunLoop.main)
            .sink { self.firmwareRevision = $0 }
            .store(in: &subs)
        deviceInfoReader.softwareRevisionPublisher
            .receive(on: RunLoop.main)
            .sink { self.softwareRevision = $0 }
            .store(in: &subs)
        deviceInfoReader.systemIdPublisher
            .receive(on: RunLoop.main)
            .sink { self.systemId = $0 }
            .store(in: &subs)
        deviceInfoReader.ieeeRegulatoryCertificationPublisher
            .receive(on: RunLoop.main)
            .sink { self.ieeeCertification = $0 }
            .store(in: &subs)
        deviceInfoReader.pnpIdPublisher
            .receive(on: RunLoop.main)
            .sink { self.pnpId = $0 }
            .store(in: &subs)
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
